import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;
  String? _phoneVerificationId;

  User? _user;
  bool _loading = true;
  String? _error;

  /// Alias conservé pour compat avec le routeur, qui ne teste que
  /// `session != null` (peu importe le type exact de session/utilisateur).
  User? get session => _user;
  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  /// Vrai si connecté et l'e-mail est vérifié — toujours vrai pour Google
  /// (Google a déjà vérifié l'e-mail) et pour un compte téléphone (pas
  /// d'e-mail à vérifier dans ce cas). Ne se met à jour qu'après un appel à
  /// `checkEmailVerified()` (Firebase ne pousse pas ce changement tout seul).
  bool get emailVerified {
    if (_user == null) return true;
    if (_user!.email == null) return true; // compte téléphone, pas d'email
    return _user!.emailVerified;
  }

  AuthProvider() {
    _user = _auth.currentUser;
    _loading = false;
    _sub = _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _messageFor(FirebaseAuthException e) {
    // FirebaseAuthException.message est souvent en anglais et technique ;
    // on traduit les cas les plus courants pour rester cohérent avec le
    // reste de l'app (en français, orienté utilisateur non-technique).
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
        return 'Aucun compte avec cet e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet e-mail.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'requires-recent-login':
        return 'Pour ta sécurité, déconnecte-toi puis reconnecte-toi avant de changer ton mot de passe.';
      case 'network-request-failed':
        return 'Problème de connexion réseau. Réessaie.';
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide. Inclus l\'indicatif pays (ex: +227...).';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessaie dans quelques minutes.';
      case 'invalid-verification-code':
        return 'Code incorrect.';
      case 'session-expired':
        return 'Le code a expiré — redemande un SMS.';
      case 'quota-exceeded':
        return 'Trop de SMS envoyés aujourd\'hui — réessaie plus tard.';
      default:
        return e.message ?? 'Une erreur est survenue.';
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      _error = null;
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _messageFor(e);
      notifyListeners();
      return _error;
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      _error = null;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _messageFor(e);
      notifyListeners();
      return _error;
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    }
  }

  /// Envoie l'e-mail de réinitialisation de mot de passe Firebase standard.
  /// Le lien ouvre par défaut une page web hébergée par Firebase — pas de
  /// configuration de deep-link nécessaire côté mobile pour cette étape.
  Future<String?> resetPasswordForEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    }
  }

  /// Envoie l'e-mail de vérification au compte actuellement connecté.
  Future<String?> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    }
  }

  /// Recharge les infos du compte (ex: `emailVerified`), qui ne se mettent
  /// PAS à jour automatiquement tant qu'on ne le redemande pas à Firebase —
  /// nécessaire après que l'utilisateur ait cliqué le lien reçu par e-mail.
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
    } catch (_) {
      // Session possiblement invalidée entre-temps — pas bloquant ici.
    }
    _user = _auth.currentUser;
    notifyListeners();
    return emailVerified;
  }

  /// Connexion via Google. Retourne (erreur, estNouveauCompte). Si l'erreur
  /// est non-null, l'utilisateur n'est PAS connecté. `estNouveauCompte` sert
  /// à savoir si c'est la toute première connexion — dans ce cas, l'atelier
  /// n'existe pas encore et le routeur redirigera automatiquement vers
  /// l'onboarding (même logique que pour un compte email/mot de passe créé
  /// sans atelier).
  Future<(String?, bool)> signInWithGoogle() async {
    try {
      _error = null;
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return ('Connexion annulée.', false); // l'utilisateur a fermé la fenêtre Google
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      return (null, isNewUser);
    } on FirebaseAuthException catch (e) {
      _error = _messageFor(e);
      notifyListeners();
      return (_error, false);
    } catch (e) {
      return ('Connexion Google impossible. Vérifie ta connexion et réessaie.', false);
    }
  }

  /// Étape 1 de la connexion par téléphone : envoie le SMS. `phoneNumber`
  /// doit être au format international (ex: +22790123456). Retourne un
  /// message d'erreur si l'envoi échoue immédiatement (numéro invalide...),
  /// sinon null et `codeSent` est appelé — l'appelant doit alors afficher
  /// l'écran de saisie du code.
  ///
  /// Sur certains Android, Firebase peut valider automatiquement sans code
  /// (SMS Retriever) — dans ce cas `onAutoVerified` est appelé directement
  /// et il n'y a pas besoin de saisie manuelle.
  Future<String?> sendPhoneCode(
    String phoneNumber, {
    required void Function() onCodeSent,
    required void Function((String? error, bool isNewUser)) onAutoVerified,
  }) async {
    final completer = Completer<String?>();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
            onAutoVerified((null, isNewUser));
          } on FirebaseAuthException catch (e) {
            onAutoVerified((_messageFor(e), false));
          }
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) completer.complete(_messageFor(e));
        },
        codeSent: (verificationId, resendToken) {
          _phoneVerificationId = verificationId;
          if (!completer.isCompleted) completer.complete(null);
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _phoneVerificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!completer.isCompleted) completer.complete(_messageFor(e));
    }
    return completer.future;
  }

  /// Étape 2 : confirme le code SMS reçu. Retourne (erreur, estNouveauCompte).
  Future<(String?, bool)> confirmPhoneCode(String smsCode) async {
    if (_phoneVerificationId == null) {
      return ('Code expiré — redemande un SMS.', false);
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _phoneVerificationId!,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      return (null, isNewUser);
    } on FirebaseAuthException catch (e) {
      return (_messageFor(e), false);
    }
  }

  Future<void> signOut() async {
    // Déconnecte aussi de Google si la session venait de là — sans quoi
    // Google reconnecterait automatiquement le même compte au prochain essai
    // sans même demander confirmation. Sans effet si la session n'était pas
    // une session Google (ne lève pas d'erreur).
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // ignore — pas grave si l'utilisateur n'était pas connecté via Google
    }
    await _auth.signOut();
  }
}
