import 'package:flutter/material.dart';

/// Scrollable page body for forms: keyboard-friendly, centred and capped in
/// width so the layout also looks right on tablets and in landscape.
class CadreFormulaire extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double largeurMax;

  const CadreFormulaire({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 32),
    this.largeurMax = 440,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: largeurMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
