import 'package:flutter/material.dart';

/// Primary call-to-action button with a built-in loading state.
class BoutonPrincipal extends StatelessWidget {
  final String libelle;
  final VoidCallback? onPressed;
  final bool enCours;
  final IconData? icone;

  const BoutonPrincipal({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.enCours = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    // While loading, the button is disabled but keeps its normal colours so
    // the spinner reads as "in progress" rather than "unavailable".
    final style = enCours
        ? FilledButton.styleFrom(
            disabledBackgroundColor: couleurs.primary,
            disabledForegroundColor: couleurs.onPrimary,
          )
        : null;

    final Widget contenu;
    if (enCours) {
      contenu = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: couleurs.onPrimary,
          semanticsLabel: 'Chargement en cours',
        ),
      );
    } else if (icone != null) {
      contenu = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 20),
          const SizedBox(width: 8),
          Text(libelle),
        ],
      );
    } else {
      contenu = Text(libelle);
    }

    return FilledButton(
      onPressed: enCours ? null : onPressed,
      style: style,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: contenu,
      ),
    );
  }
}
