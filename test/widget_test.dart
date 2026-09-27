import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/screens/auth/login_screen.dart';
import 'package:cleancity/screens/auth/register_screen.dart';
import 'package:cleancity/utils/theme.dart';

// No provider here: form validation fails before any service is called,
// so only the UI and the validation messages are covered.
void main() {
  Widget buildApp(Widget screen) {
    return MaterialApp(theme: AppTheme.light, home: screen);
  }

  testWidgets('login links to the register screen', (tester) async {
    await tester.pumpWidget(buildApp(const LoginScreen()));

    expect(find.text('Connexion'), findsOneWidget);

    final link = find.text('S\'inscrire');
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);
  });

  testWidgets('login shows errors for empty fields', (tester) async {
    await tester.pumpWidget(buildApp(const LoginScreen()));

    final button = find.text('Se connecter');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Veuillez saisir votre adresse email.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
  });

  testWidgets('register flags mismatched passwords', (tester) async {
    await tester.pumpWidget(buildApp(const RegisterScreen()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom complet'),
      'Awa Koné',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse email'),
      'awa.kone@exemple.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'secret1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmation'),
      'secret2',
    );

    final button = find.text('Créer mon compte');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
    expect(find.text('Adresse email invalide.'), findsNothing);
  });
}
