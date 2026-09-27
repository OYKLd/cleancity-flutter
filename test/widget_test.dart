import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/screens/auth/login_screen.dart';
import 'package:cleancity/utils/theme.dart';

// Test minimal sans Firebase : on vérifie seulement que l'écran de connexion
// s'affiche et que le lien mène bien à l'inscription.
void main() {
  testWidgets('La connexion mène à l\'inscription', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.clair, home: const LoginScreen()),
    );

    expect(find.text('Connexion'), findsOneWidget);

    final lien = find.text('S\'inscrire');
    await tester.ensureVisible(lien);
    await tester.tap(lien);
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);
  });
}
