import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/signalement.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

/// Carte réutilisable pour afficher un signalement dans une liste.
class SignalementCard extends StatelessWidget {
  final Signalement signalement;
  final VoidCallback? onTap;

  const SignalementCard({
    super.key,
    required this.signalement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (signalement.photoBase64.isNotEmpty)
              _PhotoSignalement(
                photoBase64: signalement.photoBase64,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategorieIcon(
                        categorie: signalement.categorie,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          libelleCategorie(signalement.categorie),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        statut: signalement.statut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    signalement.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (signalement.commune != null &&
                          signalement.commune!.isNotEmpty)
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: signalement.commune!,
                        ),
                      _InfoChip(
                        icon: Icons.priority_high_rounded,
                        label: libelleUrgence(signalement.urgence),
                        color: couleurUrgence(signalement.urgence),
                      ),
                      if (signalement.createdAt != null)
                        _InfoChip(
                          icon: Icons.schedule_outlined,
                          label: _formatDate(signalement.createdAt!),
                        ),
                    ],
                  ),
                  if (signalement.userNom.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.primaryContainer,
                          child: Text(
                            _initiales(signalement.userNom),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            signalement.userNom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  static String _initiales(String nom) {
    final morceaux = nom
        .trim()
        .split(RegExp(r'\s+'))
        .where((morceau) => morceau.isNotEmpty)
        .toList();

    if (morceaux.isEmpty) {
      return '?';
    }

    if (morceaux.length == 1) {
      return morceaux.first.substring(0, 1).toUpperCase();
    }

    return '${morceaux.first.substring(0, 1)}'
            '${morceaux.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _PhotoSignalement extends StatelessWidget {
  final String photoBase64;

  const _PhotoSignalement({
    required this.photoBase64,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final Uint8List bytes = base64Decode(photoBase64);

      return SizedBox(
        width: double.infinity,
        height: 180,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
        ),
      );
    } catch (_) {
      return const _PhotoPlaceholder();
    }
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 180,
      color: colors.surfaceContainerHigh,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 42,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

class _CategorieIcon extends StatelessWidget {
  final String categorie;

  const _CategorieIcon({
    required this.categorie,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        kCategorieIcones[categorie] ?? Icons.help_outline,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: chipColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
