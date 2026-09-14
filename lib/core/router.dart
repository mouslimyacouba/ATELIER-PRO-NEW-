import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/atelier_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/auth/verify_email_screen.dart';
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
import '../screens/modeles/modeles_screen.dart';
import '../screens/modeles/modele_form_screen.dart';
import '../screens/debug/metier_debug_screen.dart';
import '../screens/historique/commandes_historique_screen.dart';
import '../screens/historique/paiements_historique_screen.dart';
import '../screens/calendrier/calendrier_screen.dart';

GoRouter buildRouter(BuildContext context) {
  final auth = context.read<AuthProvider>();
  final atelierProvider = context.read<AtelierProvider>();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([auth, atelierProvider]),
    redirect: (context, state) {
      final loggedIn = auth.session != null;
      final loggingIn = state.matchedLocation == '/auth';
      final onboarding = state.matchedLocation == '/onboarding';
      final verifyingEmail = state.matchedLocation == '/verify-email';

      if (!loggedIn) return loggingIn ? null : '/auth';

      if (!auth.emailVerified) return verifyingEmail ? null : '/verify-email';
      if (loggingIn || verifyingEmail) return '/';

      if (loggedIn &&
          !atelierProvider.loading &&
          atelierProvider.atelier == null &&
          !onboarding) {
        return '/onboarding';
      }
      if (loggedIn && atelierProvider.atelier != null && onboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
          path: '/verify-email',
          builder: (context, state) => const VerifyEmailScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(
              path: '/debug/metier', builder: (context, state) => const MetierDebugScreen()),
          GoRoute(
              path: '/clients',
              builder: (context, state) => const ClientsScreen()),
          GoRoute(
            path: '/clients/:clientId',
            builder: (context, state) =>
                ClientDetailScreen(clientId: state.pathParameters['clientId']!),
          ),
          GoRoute(
              path: '/commandes',
              builder: (context, state) => const OrdersScreen()),
          GoRoute(
            path: '/commandes/nouvelle',
            builder: (context, state) => NewOrderScreen(
                initialClientId: state.uri.queryParameters['clientId']),
          ),
          GoRoute(
            path: '/commandes/:orderId',
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          ),
          GoRoute(
              path: '/mesures',
              builder: (context, state) => const MesuresScreen()),
          GoRoute(
              path: '/parametres',
              builder: (context, state) => const SettingsScreen()),
          GoRoute(
              path: '/modeles',
              builder: (context, state) => const ModelesScreen()),
          GoRoute(
              path: '/modeles/nouveau',
              builder: (context, state) => const ModeleFormScreen()),
          GoRoute(
            path: '/modeles/:modeleId',
            builder: (context, state) => ModeleFormScreen(
                modeleId: state.pathParameters['modeleId']),
          ),
          GoRoute(
            path: '/historique/commandes',
            builder: (context, state) => const CommandesHistoriqueScreen(),
          ),
          GoRoute(
            path: '/historique/paiements',
            builder: (context, state) => const PaiementsHistoriqueScreen(),
          ),
          GoRoute(
            path: '/calendrier',
            builder: (context, state) => const CalendrierScreen(),
          ),
        ],
      ),
    ],
  );
}
