import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          final router = buildRouter(context);
          return MaterialApp.router(
            title: 'AtelierPro',
            debugShowCheckedModeBanner: false,
            theme: AtelierProTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
