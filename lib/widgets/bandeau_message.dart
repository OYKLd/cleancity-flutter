import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum TypeBandeau { erreur, succes, info }

/// Inline banner for form-level feedback, shown above the fields.
class BandeauMessage extends StatelessWidget {
  final String texte;
  final TypeBandeau type;
  final VoidCallback? onFermer;

  const BandeauMessage({
    super.key,
    required this.texte,
    this.type = TypeBandeau.erreur,
    this.onFermer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = theme.colorScheme;

    final (Color fond, Color encre, IconData icone) = switch (type) {
      TypeBandeau.erreur => (
        couleurs.errorContainer,
        couleurs.onErrorContainer,
        Icons.error_outline,
      ),
      TypeBandeau.succes => (
        couleurs.primaryContainer,
        couleurs.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      TypeBandeau.info => (
        couleurs.secondaryContainer,
        couleurs.onSecondaryContainer,
        Icons.info_outline,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: encre, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  right: onFermer == null ? 6 : 0,
                ),
                child: Text(
                  texte,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: encre,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            if (onFermer != null)
              IconButton(
                tooltip: 'Fermer',
                icon: const Icon(Icons.close, size: 20),
                color: encre,
                visualDensity: VisualDensity.compact,
                onPressed: onFermer,
              ),
          ],
        ),
      ),
    );
  }
}
