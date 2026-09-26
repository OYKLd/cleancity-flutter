import 'package:flutter/material.dart';

import '../../widgets/a_venir.dart';

/// Écran d'inscription (nom, email, mot de passe).
/// À compléter par Dev 2 (feature/auth). Après l'inscription, penser à
/// fermer cet écran (Navigator.pop) : SplashScreen affichera alors l'accueil.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Column(
        children: [
          const Expanded(
            child: AVenir(
              icone: Icons.person_add_alt_1,
              texte: 'Formulaire d\'inscription',
              responsable: 'Dev 2 — feature/auth',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Déjà un compte ? Se connecter'),
            ),
          ),
        ],
      ),
    );
  }
}
