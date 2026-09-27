import 'package:flutter/material.dart';

/// Screen heading: a title with an optional subtitle.
class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centered;

  /// Smaller title, for dialogs and bottom sheets.
  final bool compact;

  const ScreenTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.centered = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: compact
              ? theme.textTheme.headlineSmall
              : theme.textTheme.headlineMedium,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: textAlign,
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
