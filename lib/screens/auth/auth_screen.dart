import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final result = _isSignUp
        ? await auth.signUp(email: _emailCtrl.text.trim(), password: _passwordCtrl.text)
        : await auth.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result;
    });
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();
    bool sending = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Mot de passe oublié'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "On t'envoie un lien par e-mail pour choisir un nouveau mot de passe.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
            TextButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => sending = true);
                      final error = await context
                          .read<AuthProvider>()
                          .resetPasswordForEmail(emailCtrl.text.trim());
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? "E-mail envoyé — vérifie ta boîte de réception."),
                          ),
                        );
                      }
                    },
              child: sending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Envoyer'),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AtelierProColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.checkroom, size: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AtelierPro',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const Text(
                    'Bienvenue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connectez-vous pour gérer votre atelier',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline, size: 20),
                    ),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline, size: 20),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
                  ),
                  if (!_isSignUp) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AtelierProColors.rougeAlerte)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isSignUp ? "S'inscrire" : 'Se connecter'),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
