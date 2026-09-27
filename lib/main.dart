import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'utils/theme.dart';

Future<void> main() async {
  // Obligatoire avant tout appel asynchrone précédant runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Connexion au projet Firebase (fichier généré par `flutterfire configure`)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Dates affichées en français partout (ex. « 26 sept. 2026 »)
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';

  runApp(const CleanCityApp());
}

class CleanCityApp extends StatelessWidget {
  const CleanCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider est placé au-dessus de MaterialApp : tous les écrans
    // peuvent donc savoir qui est connecté avec context.watch<AuthProvider>().
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthService(), UserService()),
      child: MaterialApp(
        title: 'CleanCity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
