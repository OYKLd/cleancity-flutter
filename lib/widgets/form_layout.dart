import 'package:flutter/material.dart';

import 'leaf_backdrop.dart';

/// Scrollable page body for forms: keyboard-friendly, centred and capped in
/// width so the layout also looks right on tablets and in landscape.
class FormLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  /// Paints decorative leaves in the corners, behind the content.
  final bool leaves;

  const FormLayout({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 32),
    this.maxWidth = 440,
    this.leaves = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
    if (!leaves) return body;

    return Stack(
      children: [
        const Positioned.fill(child: LeafBackdrop()),
        body,
      ],
    );
  }
}
