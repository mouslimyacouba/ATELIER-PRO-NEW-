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
          decoration: BoxDecoration(
            color: AtelierProColors.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mode hors-ligne — Vos modifications sont enregistrées localement et seront synchronisées.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
