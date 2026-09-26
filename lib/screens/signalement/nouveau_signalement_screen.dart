import 'package:flutter/material.dart';

import '../../widgets/a_venir.dart';

/// Création d'un signalement : photo, analyse IA, GPS ou commune, envoi.
/// À compléter par Dev 3 (feature/signalement), avec l'appel à IaService
/// fourni par Dev 5 (feature/ia).
class NouveauSignalementScreen extends StatelessWidget {
  const NouveauSignalementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau signalement')),
      body: const AVenir(
        icone: Icons.add_a_photo_outlined,
        texte: 'Photo, catégorie, urgence, description et position',
        responsable: 'Dev 3 — feature/signalement',
      ),
    );
  }
}
