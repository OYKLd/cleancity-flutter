import 'package:flutter/material.dart';

import '../../widgets/a_venir.dart';
import 'register_screen.dart';

/// Écran de connexion (email / mot de passe).
/// À compléter par Dev 2 (feature/auth). Après une connexion réussie,
/// inutile de naviguer : SplashScreen bascule tout seul vers l'accueil.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Column(
        children: [
          const Expanded(
            child: AVenir(
              icone: Icons.login,
              texte: 'Formulaire de connexion',
              responsable: 'Dev 2 — feature/auth',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('Pas encore de compte ? S\'inscrire'),
            ),
          ),
        ],
      ),
    );
  }
}
