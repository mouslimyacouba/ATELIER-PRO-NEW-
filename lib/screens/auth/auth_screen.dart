import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/contact_actions.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

enum _AuthMethod { email, phone }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMethod _method = _AuthMethod.email;
  final _formKey = GlobalKey<FormState>();

  // Email
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _passwordVisible = false;

  // Téléphone
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _codeSent = false;

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ---------- Email ----------

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();

    if (_isSignUp) {
      // Inscription seule. L'utilisateur sera redirigé vers l'onboarding
      // via le router après connexion s'il n'a pas encore d'atelier.
      final signUpError = await auth.signUp(
          email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      if (!mounted) return;
      if (signUpError != null) {
        setState(() {
          _loading = false;
          _error = signUpError;
        });
        return;
      }

      // Envoi de l'e-mail de confirmation.
      // On conserve la session active afin que le routeur redirige
      // automatiquement l'utilisateur vers l'écran /verify-email.
      await auth.sendEmailVerification();
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    final result = await auth.signIn(
        email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result;
    });
  }

  // ---------- Téléphone ----------

  Future<void> _sendPhoneCode() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Entre ton numéro de téléphone.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = normalizePhone(_phoneCtrl.text.trim());
    final error = await context.read<AuthProvider>().sendPhoneCode(
      phone,
      onCodeSent: () {
        if (!mounted) return;
        setState(() {
          _codeSent = true;
          _loading = false;
        });
      },
      onAutoVerified: (result) {
        // Certains Android valident automatiquement sans code (SMS
        // Retriever) — dans ce cas on saute directement à la connexion.
        if (!mounted) return;
        final (autoError, _) = result;
        setState(() => _loading = false);
        if (autoError == null) {
          context.go('/');
        } else {
          setState(() => _error = autoError);
        }
      },
    );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Future<void> _confirmPhoneCode() async {
    if (_codeCtrl.text.trim().length < 6) {
      setState(() => _error = 'Entre le code à 6 chiffres reçu par SMS.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final (error, _) = await context
        .read<AuthProvider>()
        .confirmPhoneCode(_codeCtrl.text.trim());
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }

    // Nouveau compte ou ancien, dans les deux cas : navigation explicite.
    // Si nouveau (pas d'atelier), le routeur redirige automatiquement vers
    // l'onboarding — pas besoin de dupliquer le formulaire atelier ici.
    setState(() => _loading = false);
    if (mounted) context.go('/');
  }

  // ---------- Google ----------

  Future<void> _submitGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final (error, _) = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }

    setState(() => _loading = false);
    context.go('/');
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();
    bool sending = false;
    bool sent = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !sending,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AtelierProColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_reset_outlined,
                    color: AtelierProColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Mot de passe oublié',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: sent
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF4CAF50).withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Color(0xFF4CAF50), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'E-mail envoyé à ${emailCtrl.text.trim()}\n\nVérifie ta boîte de réception.',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                )
              : Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        "Entre ton adresse e-mail et on t'envoie un lien pour choisir un nouveau mot de passe.",
                        style: TextStyle(
                            fontSize: 13,
                            color: AtelierProColors.onSurfaceVariant,
                            height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: emailCtrl.text.isEmpty,
                        decoration: const InputDecoration(
                          labelText: 'Adresse e-mail',
                          prefixIcon:
                              Icon(Icons.mail_outline, size: 20),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'E-mail invalide'
                            : null,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
          actions: sent
              ? [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Fermer'),
                    ),
                  ),
                ]
              : [
                  TextButton(
                    onPressed:
                        sending ? null : () => Navigator.of(ctx).pop(),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setDialogState(() => sending = true);
                            // Capture du provider avant l'await pour éviter
                            // l'utilisation de context à travers un gap async.
                            final authProvider = context.read<AuthProvider>();
                            final email = emailCtrl.text.trim();
                            final error = await authProvider
                                .resetPasswordForEmail(email);
                            if (!ctx.mounted) return;
                            if (error != null) {
                              setDialogState(() => sending = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor:
                                      AtelierProColors.rougeAlerte,
                                ),
                              );
                            } else {
                              setDialogState(
                                  () => sent = true);
                            }
                          },
                    child: sending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Envoyer le lien'),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtelierProColors.sable,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AtelierPro',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                // Sélecteur Email / Téléphone
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AtelierProColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: _MethodTab(
                        label: 'Email',
                        selected: _method == _AuthMethod.email,
                        onTap: () => setState(() {
                          _method = _AuthMethod.email;
                          _error = null;
                        }),
                      )),
                      Expanded(
                          child: _MethodTab(
                        label: 'Téléphone',
                        selected: _method == _AuthMethod.phone,
                        onTap: () => setState(() {
                          _method = _AuthMethod.phone;
                          _error = null;
                        }),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: _method == _AuthMethod.email
                      ? _buildEmailForm()
                      : _buildPhoneForm(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style:
                          const TextStyle(color: AtelierProColors.rougeAlerte)),
                ],
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OU',
                          style: TextStyle(
                              color: AtelierProColors.onSurfaceMuted,
                              fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _submitGoogle,
                  icon: const Icon(Icons.g_mobiledata,
                      size: 26, color: AtelierProColors.tertiary),
                  label: const Text('Continuer avec Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isSignUp ? 'Créons ton atelier' : 'Bienvenue',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          _isSignUp
              ? 'Un compte, un atelier — en une seule étape'
              : 'Connectez-vous pour gérer votre atelier',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AtelierProColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline, size: 20)),
          validator: (v) =>
              (v == null || !v.contains('@')) ? 'Email invalide' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AtelierProColors.onSurfaceVariant,
              ),
              tooltip: _passwordVisible ? 'Masquer' : 'Afficher',
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
          validator: (v) =>
              (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
        ),
        if (!_isSignUp)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: _forgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: AtelierProColors.primary,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                child: const Text('Mot de passe oublié ?')),
          ),
        if (_isSignUp) ...[
          const SizedBox(height: 8),
          const Text(
            'Tu pourras configurer ton atelier juste après la connexion.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AtelierProColors.onSurfaceMuted),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _submitEmail,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isSignUp
                        ? 'Créer mon compte et mon atelier'
                        : 'Se connecter'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(_isSignUp
              ? 'Déjà un compte ? Se connecter'
              : "Pas encore de compte ? S'inscrire"),
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _codeSent ? 'Code reçu par SMS' : 'Connexion par téléphone',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          _codeSent
              ? 'Entre le code à 6 chiffres envoyé au ${normalizePhone(_phoneCtrl.text.trim())}'
              : 'Compte créé automatiquement à la première connexion',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AtelierProColors.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 20),
        if (!_codeSent) ...[
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '90 12 34 56',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _sendPhoneCode,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Recevoir le code par SMS'),
          ),
        ] else ...[
          TextFormField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, letterSpacing: 8),
            maxLength: 6,
            decoration:
                const InputDecoration(counterText: '', hintText: '••••••'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _confirmPhoneCode,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Vérifier le code'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() {
                      _codeSent = false;
                      _codeCtrl.clear();
                      _error = null;
                    }),
            child: const Text('Modifier le numéro / renvoyer le code'),
          ),
        ],
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AtelierProColors.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AtelierProColors.primary
                : AtelierProColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
