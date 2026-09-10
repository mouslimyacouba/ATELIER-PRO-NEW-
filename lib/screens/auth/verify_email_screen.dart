import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;
  int _resendCooldown = 0;
  String? _message;

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _message = verified
          ? null
          : "Toujours pas vérifié — vérifie ta boîte de réception (et les spams).";
    });
    // Si vérifié, le routeur redirige automatiquement vers le tableau de
    // bord dès que emailVerified passe à true (notifyListeners() déjà
    // déclenché par checkEmailVerified ci-dessus).
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    setState(() => _resending = true);
    final error = await context.read<AuthProvider>().sendEmailVerification();
    if (!mounted) return;
    setState(() {
      _resending = false;
      _message = error ?? "E-mail renvoyé.";
      _resendCooldown = 30;
    });
    _tickCooldown();
  }

  void _tickCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _resendCooldown <= 0) return;
      setState(() => _resendCooldown--);
      if (_resendCooldown > 0) _tickCooldown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().user?.email ?? '';

    return Scaffold(
      backgroundColor: AtelierProColors.sable,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Vérifie ton e-mail',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'On a envoyé un lien de confirmation à $email. '
                  'Clique dessus, puis reviens ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AtelierProColors.onSurfaceVariant),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(_message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13)),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _checking ? null : _checkVerified,
                  child: _checking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("J'ai vérifié — actualiser"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      (_resending || _resendCooldown > 0) ? null : _resend,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Renvoyer l\'e-mail (${_resendCooldown}s)'
                        : "Renvoyer l'e-mail",
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  child: const Text('Se déconnecter',
                      style: TextStyle(color: AtelierProColors.onSurfaceMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
