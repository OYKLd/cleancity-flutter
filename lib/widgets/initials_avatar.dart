import 'package:flutter/material.dart';

/// Circular avatar showing the initials of a name (no profile pictures yet).
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialsAvatar({super.key, required this.name, this.radius = 32});

  /// "Awa Koné" -> "AK", "awa" -> "A", "" -> "?".
  static String initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);
    if (words.isEmpty) return '?';
    final first = words.first.substring(0, 1);
    final last = words.length > 1 ? words.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Avatar de $name',
      excludeSemantics: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: colors.primaryContainer,
        child: Text(
          initials(name),
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.w600,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}
