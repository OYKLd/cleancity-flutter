import 'package:firebase_auth/firebase_auth.dart';

import 'auth_exception.dart';

/// Only place in the app that talks to Firebase Auth. Every method throws an
/// [AuthException] with a French message on failure.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _injectedAuth = auth;

  final FirebaseAuth? _injectedAuth;

  // Resolved lazily so widget tests can build screens without Firebase.
  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  /// Emits the signed-in account, or null after sign-out. SplashScreen
  /// listens to it to choose between the login and home screens.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return translateFirebaseErrors(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user ?? (throw AuthException.unknown());
      await _setDisplayNameQuietly(user, name);
      return user;
    });
  }

  Future<User> signIn({required String email, required String password}) {
    return translateFirebaseErrors(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user ?? (throw AuthException.unknown());
    });
  }

  Future<void> signOut() => translateFirebaseErrors(_auth.signOut);

  /// Firebase sends the email itself; with email enumeration protection on,
  /// it succeeds even when no account matches, so callers must stay neutral.
  Future<void> sendPasswordResetEmail(String email) {
    return translateFirebaseErrors(() async {
      await _auth.setLanguageCode('fr');
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  Future<void> updateDisplayName(String name) {
    return translateFirebaseErrors(() async {
      final user = _auth.currentUser;
      if (user != null) await _setDisplayNameQuietly(user, name);
    });
  }

  // The display name is only a fallback for the Firestore profile: a failure
  // here must not turn a successful sign-up into an error.
  Future<void> _setDisplayNameQuietly(User user, String name) async {
    try {
      await user.updateDisplayName(name);
    } on FirebaseAuthException {
      // Ignored on purpose, see above.
    }
  }
}
