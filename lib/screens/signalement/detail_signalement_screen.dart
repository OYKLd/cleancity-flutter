import 'package:flutter/material.dart';

import '../../models/signalement.dart';
import '../../utils/constants.dart';
import '../../widgets/a_venir.dart';

/// Détail d'un signalement : photo, infos, bouton « Voir sur la carte »,
/// changement de statut si l'utilisateur est admin.
/// À compléter par Dev 4 (feature/liste).
///
/// Utilisation :
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DetailSignalementScreen(signalement: s)));
class DetailSignalementScreen extends StatelessWidget {
  final Signalement signalement;

  const DetailSignalementScreen({super.key, required this.signalement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(libelleCategorie(signalement.categorie))),
      body: const AVenir(
        icone: Icons.article_outlined,
        texte: 'Détail du signalement',
        responsable: 'Dev 4 — feature/liste',
      ),
    );
  }
}
