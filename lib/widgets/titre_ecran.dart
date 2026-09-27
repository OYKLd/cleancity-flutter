import 'package:flutter/material.dart';

/// Screen heading: a title with an optional subtitle.
class TitreEcran extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final bool centre;

  /// Smaller title, for dialogs and bottom sheets.
  final bool compact;

  const TitreEcran({
    super.key,
    required this.titre,
    this.sousTitre,
    this.centre = false,
    this.compact = false,
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
          style: compact
              ? theme.textTheme.headlineSmall
              : theme.textTheme.headlineMedium,
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
