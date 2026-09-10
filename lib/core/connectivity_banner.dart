import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

/// Petit bandeau affiché en haut de l'écran quand l'appareil est hors ligne.
/// Purement informatif : l'app continue de fonctionner normalement grâce au
/// cache local Firestore (lecture ET écriture), ce bandeau sert juste à
/// rassurer l'utilisateur que ses actions seront bien synchronisées.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data;
        final offline = results != null &&
            results.isNotEmpty &&
            results.every((r) => r == ConnectivityResult.none);

        if (!offline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: AtelierProColors.orangeAttente.withValues(alpha: 0.15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 16, color: AtelierProColors.orangeAttente),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mode hors-ligne — tes modifications seront synchronisées à la reconnexion.',
                  style: TextStyle(fontSize: 12, color: AtelierProColors.orangeAttente.withValues(alpha: 0.9)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
