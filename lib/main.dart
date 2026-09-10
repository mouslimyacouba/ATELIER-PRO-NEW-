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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charge les clés Firebase depuis .env (jamais commité). Ces clés sont
  // propres à AtelierPro — ne jamais les mélanger avec NiyaJobs.
  await dotenv.load(fileName: '.env');

  // Nécessaire pour tout DateFormat utilisant des noms de mois/jours en
  // français (ex: DateFormat('MMMM', 'fr_FR')) — sans ça, ça plante avec
  // une LocaleDataException au premier appel.
  await initializeDateFormatting('fr_FR');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Mode hors-ligne : la persistance locale est activée par défaut sur
  // mobile, mais on le rend explicite ici (et on retire la limite de
  // taille du cache par défaut ~40 Mo, utile si beaucoup de photos/logos
  // sont mis en cache) — les lectures fonctionnent depuis le cache local
  // sans réseau, et les écritures faites hors ligne sont automatiquement
  // mises en file d'attente et synchronisées au retour de la connexion.
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
