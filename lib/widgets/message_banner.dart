import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum BannerType { error, success, info }

/// Inline banner for form-level feedback, shown above the fields.
class MessageBanner extends StatelessWidget {
  final String text;
  final BannerType type;
  final VoidCallback? onClose;

  const MessageBanner({
    super.key,
    required this.text,
    this.type = BannerType.error,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (Color background, Color foreground, IconData icon) = switch (type) {
      BannerType.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline,
      ),
      BannerType.success => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      BannerType.info => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.info_outline,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  right: onClose == null ? 6 : 0,
                ),
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            if (onClose != null)
              IconButton(
                tooltip: 'Fermer',
                icon: const Icon(Icons.close, size: 20),
                color: foreground,
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
