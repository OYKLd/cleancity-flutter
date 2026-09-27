import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cleancity/services/auth_exception.dart';

void main() {
  group('AuthException.fromCode', () {
    test('translates known Firebase Auth codes into French', () {
      expect(
        AuthException.fromCode('email-already-in-use').message,
        'Un compte existe déjà avec cette adresse email.',
      );
      expect(
        AuthException.fromCode('network-request-failed').message,
        'Pas de connexion internet. Vérifiez votre réseau et réessayez.',
      );
      expect(
        AuthException.fromCode('permission-denied').message,
        'Accès refusé par les règles de sécurité.',
      );
    });

    test('uses one message for every wrong-credentials code', () {
      const expected = 'Email ou mot de passe incorrect.';
      for (final code in [
        'user-not-found',
        'wrong-password',
        'invalid-credential',
        'INVALID_LOGIN_CREDENTIALS',
      ]) {
        expect(AuthException.fromCode(code).message, expected, reason: code);
      }
    });

    test('falls back to a generic message and keeps the code', () {
      final exception = AuthException.fromCode('something-new');
      expect(exception.message, AuthException.genericMessage);
      expect(exception.code, 'something-new');
    });
  });

  group('translateFirebaseErrors', () {
    test('returns the value when the action succeeds', () async {
      expect(await translateFirebaseErrors(() async => 42), 42);
    });

    test('converts a FirebaseAuthException', () async {
      await expectLater(
        translateFirebaseErrors<void>(() async {
          throw FirebaseAuthException(code: 'weak-password');
        }),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Mot de passe trop faible : utilisez au moins 6 caractères.',
          ),
        ),
      );
    });

    test('lets an AuthException through unchanged', () async {
      const original = AuthException('Message custom', code: 'custom');
      await expectLater(
        translateFirebaseErrors<void>(() async => throw original),
        throwsA(same(original)),
      );
    });

    test('wraps any other error into the generic message', () async {
      await expectLater(
        translateFirebaseErrors<void>(() async => throw StateError('boom')),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            AuthException.genericMessage,
          ),
        ),
      );
    });
  });
}
