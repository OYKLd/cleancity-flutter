import 'package:flutter/material.dart';

/// Primary call-to-action button with a built-in loading state.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    } else {
      content = Text(label);
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: content,
      ),
    );
  }
}
