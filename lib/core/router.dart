import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/atelier_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_detail_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/new_order_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/mesures/mesures_screen.dart';
import '../screens/settings/settings_screen.dart';

GoRouter buildRouter(BuildContext context) {
  final auth = context.watch<AuthProvider>();
  final atelierProvider = context.watch<AtelierProvider>();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.session != null;
      final loggingIn = state.matchedLocation == '/auth';
      final onboarding = state.matchedLocation == '/onboarding';

      if (!loggedIn) return loggingIn ? null : '/auth';
      if (loggedIn && loggingIn) return '/';

      if (loggedIn && !atelierProvider.loading && atelierProvider.atelier == null && !onboarding) {
        return '/onboarding';
      }
      if (loggedIn && atelierProvider.atelier != null && onboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/clients', builder: (context, state) => const ClientsScreen()),
          GoRoute(
            path: '/clients/:clientId',
            builder: (context, state) =>
                ClientDetailScreen(clientId: state.pathParameters['clientId']!),
          ),
          GoRoute(path: '/commandes', builder: (context, state) => const OrdersScreen()),
          GoRoute(
            path: '/commandes/nouvelle',
            builder: (context, state) =>
                NewOrderScreen(initialClientId: state.uri.queryParameters['clientId']),
          ),
          GoRoute(
            path: '/commandes/:orderId',
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          ),
          GoRoute(path: '/mesures', builder: (context, state) => const MesuresScreen()),
          GoRoute(path: '/parametres', builder: (context, state) => const SettingsScreen()),
        ],
      ),
    ],
  );
}
