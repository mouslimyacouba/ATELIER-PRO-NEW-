import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/connectivity_banner.dart';
import '../../core/theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    ('/', Icons.storefront_outlined, Icons.storefront, 'Atelier'),
    ('/clients', Icons.people_outline, Icons.people, 'Clients'),
    ('/commandes', Icons.receipt_long_outlined, Icons.receipt_long, 'Commandes'),
    ('/mesures', Icons.description_outlined, Icons.description, 'Fiches'),
    ('/parametres', Icons.settings_outlined, Icons.settings, 'Réglages'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => t.$1 == location);
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else if (currentIndex != 0) {
          context.go('/');
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ConnectivityBanner(),
              Expanded(child: child),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => context.go(_tabs[i].$1),
          backgroundColor: AtelierProColors.surfaceContainer,
          indicatorColor: AtelierProColors.secondaryContainer,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: Icon(tab.$2, color: AtelierProColors.onSurfaceVariant),
                selectedIcon: Icon(tab.$3, color: AtelierProColors.primary),
                label: tab.$4,
              ),
          ],
        ),
      ),
    );
  }
}
