import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _resending = false;
  int _resendCooldown = 0;
  String? _message;
  Timer? _autoCheckTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Vérification automatique périodique
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerified(silent: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Dès que l'artisan revient dans l'application après avoir cliqué sur le lien e-mail
    if (state == AppLifecycleState.resumed) {
      _checkVerified(silent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified({bool silent = false}) async {
    if (_checking) return;
    if (!silent) {
      setState(() => _checking = true);
    }
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _checking = false;
        _message = verified
            ? null
            : 'Toujours pas vérifié — vérifie ta boîte de réception (et les spams).';
      });
    } else if (verified) {
      setState(() => _message = null);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _resending) return;
    setState(() => _resending = true);
    final error = await context.read<AuthProvider>().sendEmailVerification();
    if (!mounted) return;
    setState(() {
      _resending = false;
      _message = error ?? 'E-mail renvoyé avec succès.';
      if (error == null) {
        _resendCooldown = 30;
      }
    });
    if (error == null) {
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 1) {
          _resendCooldown--;
        } else {
          _resendCooldown = 0;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().user?.email ?? '';

    return Scaffold(
      backgroundColor: AtelierProColors.sable,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                  'Clique dessus, puis reviens ici — la page se mettra à jour automatiquement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AtelierProColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                // Indicateur de vérification automatique en cours
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AtelierProColors.terracotta,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Vérification automatique en cours…',
                      style: TextStyle(
                        fontSize: 12,
                        color: AtelierProColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(_message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13)),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _checking ? null : () => _checkVerified(silent: false),
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
