import 'package:flutter/material.dart';

/// Screen heading: a title with an optional subtitle.
class TitreEcran extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final bool centre;

  const TitreEcran({
    super.key,
    required this.titre,
    this.sousTitre,
    this.centre = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignementTexte = centre ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: centre
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          textAlign: alignementTexte,
          style: theme.textTheme.headlineMedium,
        ),
        if (sousTitre != null) ...[
          const SizedBox(height: 8),
          Text(
            sousTitre!,
            textAlign: alignementTexte,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}
