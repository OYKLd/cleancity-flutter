import 'package:flutter/material.dart';

/// App logo: leaf icon on a mint disc, optionally followed by the app name.
class LogoCleanCity extends StatelessWidget {
  final double taille;
  final bool avecNom;

  const LogoCleanCity({super.key, this.taille = 72, this.avecNom = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = theme.colorScheme;

    return Semantics(
      label: 'CleanCity',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: taille,
            height: taille,
            decoration: BoxDecoration(
              color: couleurs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_rounded,
              size: taille * 0.55,
              color: couleurs.primary,
            ),
          ),
          if (avecNom) ...[
            const SizedBox(height: 12),
            Text(
              'CleanCity',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: couleurs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
