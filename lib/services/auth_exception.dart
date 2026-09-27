import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Error raised by the auth and profile services. [message] is in French and
/// ready to be shown to the user; [code] is the original Firebase code.
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.message, {this.code = 'unknown'});

  /// Translates a Firebase Auth or Firestore error code.
  factory AuthException.fromCode(String code) {
    final normalized = code.toLowerCase().replaceAll('_', '-');
    return AuthException(
      _messages[normalized] ?? genericMessage,
      code: normalized,
    );
  }

  factory AuthException.unknown() => const AuthException(genericMessage);

  static const String genericMessage =
      'Une erreur est survenue. Veuillez réessayer.';

  static const String _badCredentials = 'Email ou mot de passe incorrect.';

  static const Map<String, String> _messages = {
    // Sign-in. With email enumeration protection enabled on the project,
    // Firebase reports every credential problem as "invalid-credential".
    'invalid-email': 'Adresse email invalide.',
    'user-disabled': 'Ce compte a été désactivé.',
    'user-not-found': _badCredentials,
    'wrong-password': _badCredentials,
    'invalid-credential': _badCredentials,
    'invalid-login-credentials': _badCredentials,
    // Sign-up
    'email-already-in-use': 'Un compte existe déjà avec cette adresse email.',
    'weak-password':
        'Mot de passe trop faible : utilisez au moins 6 caractères.',
    'operation-not-allowed':
        'La connexion par email n\'est pas activée. Contactez l\'équipe.',
    // Session
    'requires-recent-login':
        'Par sécurité, reconnectez-vous avant de refaire cette action.',
    'user-token-expired': 'Votre session a expiré. Reconnectez-vous.',
    // Network and quotas
    'network-request-failed':
        'Pas de connexion internet. Vérifiez votre réseau et réessayez.',
    'too-many-requests': 'Trop de tentatives. Réessayez dans quelques minutes.',
    // Firestore (profile document)
    'permission-denied': 'Accès refusé par les règles de sécurité.',
    'not-found': 'Profil introuvable. Reconnectez-vous et réessayez.',
    'unavailable': 'Service momentanément indisponible. Réessayez plus tard.',
    'deadline-exceeded': 'Le serveur met trop de temps à répondre. Réessayez.',
  };

  @override
  String toString() => 'AuthException($code): $message';
}

/// Runs [action] and converts any error into an [AuthException], so screens
/// only have to handle one exception type.
Future<T> translateFirebaseErrors<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on AuthException {
    rethrow;
  } on FirebaseException catch (e) {
    throw AuthException.fromCode(e.code);
  } catch (e) {
    debugPrint('Unexpected error in a Firebase call: $e');
    throw AuthException.unknown();
  }
}
