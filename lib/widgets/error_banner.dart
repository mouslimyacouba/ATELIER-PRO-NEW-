import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bandeau d'erreur affiché quand un provider a une erreur de chargement
/// (ex: index Firestore manquant, permission refusée). Avant ce widget,
/// ces erreurs échouaient silencieusement — l'écran restait juste vide,
/// sans aucune indication du problème, ce qui rendait le diagnostic
/// impossible pour quelqu'un testant l'app en dehors d'un terminal de
/// développement (APK installé, pas de console visible).
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AtelierProColors.rougeAlerte.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AtelierProColors.rougeAlerte.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AtelierProColors.rougeAlerte),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AtelierProColors.rougeAlerte),
            ),
          ),
        ],
      ),
    );
  }
}
