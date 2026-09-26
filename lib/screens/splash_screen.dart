import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

/// Premier écran affiché : choisit la destination selon l'état de connexion.
/// Comme il « écoute » AuthProvider, il se reconstruit tout seul à chaque
/// connexion ou déconnexion : aucun Navigator n'est nécessaire pour ça.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.initialise) {
      return const _EcranChargement();
    }
    return auth.estConnecte ? const HomeScreen() : const LoginScreen();
  }
}

class _EcranChargement extends StatelessWidget {
  const _EcranChargement();

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 80, color: couleurs.primary),
            const SizedBox(height: 16),
            Text(
              'CleanCity',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: couleurs.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
