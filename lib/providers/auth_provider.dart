import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;

  User? _user;
  bool _loading = true;
  String? _error;

  /// Alias conservé pour compat avec le routeur, qui ne teste que
  /// `session != null` (peu importe le type exact de session/utilisateur).
  User? get session => _user;
  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

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
      case 'network-request-failed':
        return 'Problème de connexion réseau. Réessaie.';
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

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
