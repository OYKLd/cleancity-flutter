import 'package:flutter/material.dart';

import '../../widgets/a_venir.dart';

/// Onglet « Accueil » : fil des signalements en temps réel avec filtres.
/// À compléter par Dev 4 (feature/liste) avec un StreamBuilder branché sur
/// SignalementService. Un appui sur une carte ouvre DetailSignalementScreen.
class FilSignalementsScreen extends StatelessWidget {
  const FilSignalementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CleanCity')),
      body: const AVenir(
        icone: Icons.dynamic_feed,
        texte: 'Fil des signalements récents\n(filtres par statut et catégorie)',
        responsable: 'Dev 4 — feature/liste',
      ),
    );
  }
}
