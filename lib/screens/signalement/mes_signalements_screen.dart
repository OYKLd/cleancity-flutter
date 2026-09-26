import 'package:flutter/material.dart';

import '../../widgets/a_venir.dart';

/// Onglet « Mes signalements » : signalements de l'utilisateur connecté.
/// À compléter par Dev 4 (feature/liste).
class MesSignalementsScreen extends StatelessWidget {
  const MesSignalementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes signalements')),
      body: const AVenir(
        icone: Icons.list_alt,
        texte: 'Liste de mes signalements et leur statut',
        responsable: 'Dev 4 — feature/liste',
      ),
    );
  }
}
