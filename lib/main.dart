import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/atelier_provider.dart';
import 'providers/clients_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/fiches_mesures_provider.dart';
import 'providers/modeles_provider.dart';
import 'providers/metier_provider.dart';
import 'providers/stock_provider.dart';
import 'core/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('fr_FR');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const AtelierProApp());
}

class AtelierProApp extends StatelessWidget {
  const AtelierProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AtelierProvider()),
        ChangeNotifierProvider(create: (_) => ClientsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => FichesMesuresProvider()),
        ChangeNotifierProvider(create: (_) => ModelesProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProxyProvider<AtelierProvider, MetierProvider>(
          create: (context) => MetierProvider(context.read<AtelierProvider>()),
          update: (context, atelier, previous) => previous ?? MetierProvider(atelier),
        ),
      ],
      child: Builder(
        builder: (context) {
          return const _AtelierProRouter();
        },
      ),
    );
  }
}

class _AtelierProRouter extends StatefulWidget {
  const _AtelierProRouter();

  @override
  State<_AtelierProRouter> createState() => _AtelierProRouterState();
}

class _AtelierProRouterState extends State<_AtelierProRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AtelierPro',
      debugShowCheckedModeBanner: false,
      theme: AtelierProTheme.light,
      routerConfig: _router,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }
}
