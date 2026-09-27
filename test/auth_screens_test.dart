// firebase_auth also exports an AuthProvider class: only User is needed.
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cleancity/providers/auth_provider.dart';
import 'package:cleancity/screens/auth/forgot_password_sheet.dart';
import 'package:cleancity/screens/auth/login_screen.dart';
import 'package:cleancity/screens/auth/register_screen.dart';
import 'package:cleancity/services/auth_exception.dart';
import 'package:cleancity/services/auth_service.dart';
import 'package:cleancity/services/user_service.dart';
import 'package:cleancity/utils/theme.dart';

// Stands in for Firebase Auth: every action fails with [failWith], or the
// password reset succeeds when no code is given. A real [User] cannot be
// built outside Firebase, so successful sign-in is not covered here.
class _FakeAuthService extends AuthService {
  _FakeAuthService({this.failWith});

  final String? failWith;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<User> signIn({required String email, required String password}) =>
      _fail();

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) => _fail();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (failWith != null) throw AuthException.fromCode(failWith!);
  }

  Future<User> _fail() async {
    throw AuthException.fromCode(failWith ?? 'unknown');
  }
}

void main() {
  Widget buildApp(Widget screen, {String? failWith}) {
    return ChangeNotifierProvider(
      create: (_) =>
          AuthProvider(_FakeAuthService(failWith: failWith), UserService()),
      child: MaterialApp(theme: AppTheme.light, home: screen),
    );
  }

  Future<void> fillField(
    WidgetTester tester,
    String label,
    String value, {
    Finder? within,
  }) {
    var field = find.widgetWithText(TextFormField, label);
    if (within != null) field = find.descendant(of: within, matching: field);
    return tester.enterText(field, value);
  }

  // The login screen stays under the sheet, with its own email field.
  final sheet = find.byType(ForgotPasswordSheet);

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('login shows the French message when sign-in fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(const LoginScreen(), failWith: 'invalid-credential'),
    );
    await fillField(tester, 'Adresse email', 'awa.kone@exemple.com');
    await fillField(tester, 'Mot de passe', 'secret1');

    await tapButton(tester, 'Se connecter');

    expect(find.text('Email ou mot de passe incorrect.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('register shows the French message when the email is taken', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(const RegisterScreen(), failWith: 'email-already-in-use'),
    );
    await fillField(tester, 'Nom complet', 'Awa Koné');
    await fillField(tester, 'Adresse email', 'awa.kone@exemple.com');
    await fillField(tester, 'Mot de passe', 'secret1');
    await fillField(tester, 'Confirmation', 'secret1');

    await tapButton(tester, 'Créer mon compte');

    expect(
      find.text('Un compte existe déjà avec cette adresse email.'),
      findsOneWidget,
    );
    expect(find.text('Inscription'), findsOneWidget);
  });

  testWidgets('forgot password closes the sheet and stays neutral', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const LoginScreen()));
    await tapButton(tester, 'Mot de passe oublié ?');
    await fillField(
      tester,
      'Adresse email',
      'awa.kone@exemple.com',
      within: sheet,
    );

    await tapButton(tester, 'Envoyer le lien');

    expect(find.text('Mot de passe oublié'), findsNothing);
    expect(find.textContaining('Si un compte existe'), findsOneWidget);
  });

  testWidgets('forgot password shows the error inside the sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(const LoginScreen(), failWith: 'network-request-failed'),
    );
    await tapButton(tester, 'Mot de passe oublié ?');
    await fillField(
      tester,
      'Adresse email',
      'awa.kone@exemple.com',
      within: sheet,
    );

    await tapButton(tester, 'Envoyer le lien');

    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(
      find.text(
        'Pas de connexion internet. Vérifiez votre réseau et réessayez.',
      ),
      findsOneWidget,
    );
  });
}
