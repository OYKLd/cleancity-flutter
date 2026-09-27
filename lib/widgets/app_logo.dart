import 'package:flutter/material.dart';

/// App logo: leaf icon on a mint disc, optionally followed by the two-tone
/// wordmark and the tagline.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showName;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showName = true,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      label: 'CleanCity',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_rounded,
              size: size * 0.55,
              color: colors.primary,
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Clean',
                    style: TextStyle(color: colors.primary),
                  ),
                  TextSpan(
                    text: 'City',
                    style: TextStyle(color: colors.secondary),
                  ),
                ],
              ),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
          if (showTagline) ...[
            const SizedBox(height: 6),
            Text(
              'Une ville plus propre,\nc\'est possible',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                letterSpacing: 1.2,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
