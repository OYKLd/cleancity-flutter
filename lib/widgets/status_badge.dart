import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Badge réutilisable pour afficher le statut d'un signalement.
class StatusBadge extends StatelessWidget {
  final String statut;

  const StatusBadge({
    super.key,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = couleurStatut(statut);
    final libelle = libelleStatut(statut);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: couleur.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: couleur,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            libelle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
