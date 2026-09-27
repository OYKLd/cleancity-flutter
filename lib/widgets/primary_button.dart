import 'package:flutter/material.dart';

/// Primary call-to-action button: pill shape, soft shadow and a built-in
/// loading state. [icon] goes before the label, [trailingIcon] after it.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isActive = onPressed != null || isLoading;

    // While loading, the button is disabled but keeps its normal colours so
    // the spinner reads as "in progress" rather than "unavailable".
    final style = isLoading
        ? FilledButton.styleFrom(
            disabledBackgroundColor: colors.primary,
            disabledForegroundColor: colors.onPrimary,
          )
        : null;

    final Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colors.onPrimary,
          semanticsLabel: 'Chargement en cours',
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 20),
          ],
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: content,
        ),
      ),
    );
  }
}
