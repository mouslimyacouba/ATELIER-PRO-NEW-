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

  String? configurationError;

  try {
    await dotenv.load(fileName: '.env', isOptional: true);
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseConfigurationException catch (error) {
    configurationError = error.message;
  } on FirebaseException catch (error) {
    configurationError =
        'Firebase n’a pas pu démarrer : ${error.message ?? error.code}. '
        'Vérifie les variables de configuration.';
  }

  if (configurationError != null) {
    runApp(FirebaseSetupRequiredApp(message: configurationError));
    return;
  }

  await initializeDateFormatting('fr_FR');
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

/// Écran volontairement minimal affiché lorsque Firebase n'est pas configuré.
///
/// Cela permet au workflow et aux tests de démarrer sans connexion Firebase,
/// tout en empêchant l'application de fonctionner silencieusement avec de
/// fausses valeurs.
class FirebaseSetupRequiredApp extends StatelessWidget {
  const FirebaseSetupRequiredApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtelierPro — configuration requise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.settings, size: 48, color: Colors.orange),
                  const SizedBox(height: 24),
                  Text(
                    'Configuration Firebase requise',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 16),
                  const Text(
                    'Ajoute les valeurs dans les secrets ou variables '
                    'd’environnement Replit, puis redémarre le workflow.',
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
