import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/screens/auth/login_screen.dart';
import 'package:cleancity/screens/auth/register_screen.dart';
import 'package:cleancity/utils/theme.dart';

// Tests sans Firebase : les écrans de connexion et d'inscription n'appellent
// aucun service, on vérifie donc uniquement l'interface et la validation.
void main() {
  Widget appAvec(Widget ecran) {
    return MaterialApp(theme: AppTheme.clair, home: ecran);
  }

  testWidgets('La connexion mène à l\'inscription', (tester) async {
    await tester.pumpWidget(appAvec(const LoginScreen()));

    expect(find.text('Connexion'), findsOneWidget);

    final lien = find.text('S\'inscrire');
    await tester.ensureVisible(lien);
    await tester.tap(lien);
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);
  });

  testWidgets('La connexion affiche les erreurs des champs vides', (
    tester,
  ) async {
    await tester.pumpWidget(appAvec(const LoginScreen()));

    final bouton = find.text('Se connecter');
    await tester.ensureVisible(bouton);
    await tester.tap(bouton);
    await tester.pump();

    expect(find.text('Veuillez saisir votre adresse email.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
  });

  testWidgets('L\'inscription signale des mots de passe différents', (
    tester,
  ) async {
    await tester.pumpWidget(appAvec(const RegisterScreen()));

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

    final bouton = find.text('Créer mon compte');
    await tester.ensureVisible(bouton);
    await tester.tap(bouton);
    await tester.pump();

    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
    expect(find.text('Adresse email invalide.'), findsNothing);
  });
}
