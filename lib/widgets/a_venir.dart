import 'package:flutter/material.dart';

/// Contenu provisoire des écrans de la Phase 1.
/// Chaque développeur le remplace par le vrai contenu de son écran.
class AVenir extends StatelessWidget {
  final IconData icone;
  final String texte;
  final String responsable; // ex. "Dev 2 — feature/auth"

  const AVenir({
    super.key,
    required this.icone,
    required this.texte,
    required this.responsable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              texte,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'À venir ($responsable)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
