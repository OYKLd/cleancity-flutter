import 'package:flutter/material.dart';

/// Circular avatar showing the initials of a name (no profile pictures yet).
class AvatarInitiales extends StatelessWidget {
  final String nom;
  final double rayon;

  const AvatarInitiales({super.key, required this.nom, this.rayon = 32});

  /// "Awa Koné" -> "AK", "awa" -> "A", "" -> "?".
  static String initiales(String nom) {
    final mots = nom.trim().split(RegExp(r'\s+'))
      ..removeWhere((mot) => mot.isEmpty);
    if (mots.isEmpty) return '?';
    final premiere = mots.first.substring(0, 1);
    final derniere = mots.length > 1 ? mots.last.substring(0, 1) : '';
    return (premiere + derniere).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Avatar de $nom',
      excludeSemantics: true,
      child: CircleAvatar(
        radius: rayon,
        backgroundColor: couleurs.primaryContainer,
        child: Text(
          initiales(nom),
          style: TextStyle(
            fontSize: rayon * 0.75,
            fontWeight: FontWeight.w600,
            color: couleurs.primary,
          ),
        ),
      ),
    );
  }
}
