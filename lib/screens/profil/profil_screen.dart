import 'package:flutter/material.dart';

import '../../widgets/a_venir.dart';

/// Onglet « Profil » : nom, email, nombre de signalements, déconnexion.
/// À compléter par Dev 2 (feature/auth). Après la déconnexion, inutile de
/// naviguer : SplashScreen bascule tout seul vers l'écran de connexion.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const AVenir(
        icone: Icons.person,
        texte: 'Nom, email, nombre de signalements et déconnexion',
        responsable: 'Dev 2 — feature/auth',
      ),
    );
  }
}
