import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_exception.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Exposes the signed-in user to every screen (`context.watch<AuthProvider>()`)
/// and runs the auth actions. Screens never call the services directly.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._userService) {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthService _authService;
  final UserService _userService;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _profileSubscription;

  User? _user;
  AppUser? _profile;
  bool _initialise = false;

  /// Firebase Auth account, or null when signed out.
  User? get user => _user;

  /// Firestore profile (name, role). Null until loaded or if the document
  /// is missing: use [displayName] and [isAdmin], which handle that case.
  AppUser? get profile => _profile;

  bool get estConnecte => _user != null;

  /// False until Firebase has restored the saved session at startup; the
  /// splash screen shows a loader in the meantime.
  bool get initialise => _initialise;

  bool get isAdmin => _profile?.estAdmin ?? false;

  /// Name to show, with fallbacks: Firestore profile, Firebase account,
  /// then the start of the email address.
  String get displayName {
    final profileName = _profile?.nom.trim() ?? '';
    if (profileName.isNotEmpty) return profileName;
    final accountName = _user?.displayName?.trim() ?? '';
    if (accountName.isNotEmpty) return accountName;
    return nameFromEmail(_user?.email);
  }

  String get email => _profile?.email ?? _user?.email ?? '';

  static String nameFromEmail(String? email) {
    final localPart = email?.split('@').first.trim() ?? '';
    return localPart.isEmpty ? 'Utilisateur CleanCity' : localPart;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );
    await _ensureProfile(user, name: name);
  }

  Future<void> signIn({required String email, required String password}) async {
    final user = await _authService.signIn(email: email, password: password);
    await _ensureProfile(user);
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> updateName(String name) async {
    final user = _user;
    if (user == null) {
      throw const AuthException(
        'Vous n\'êtes plus connecté.',
        code: 'not-signed-in',
      );
    }
    await _userService.updateName(uid: user.uid, name: name);
    await _authService.updateDisplayName(name);
  }

  Future<int> countReports() {
    final user = _user;
    return user == null ? Future.value(0) : _userService.countReports(user.uid);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    _initialise = true;
    _watchProfile(user?.uid);
    notifyListeners();
  }

  void _watchProfile(String? uid) {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _profile = null;
    if (uid == null) return;
    _profileSubscription = _userService
        .watchUser(uid)
        .listen(
          (profile) {
            _profile = profile;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Profile stream error for $uid: $error');
          },
        );
  }

  // Creates users/{uid} when missing (first sign-in of an account created in
  // the console, or a write that failed at sign-up). Never throws: the
  // account already exists, so the user is signed in either way.
  Future<void> _ensureProfile(User user, {String? name}) async {
    try {
      await _userService.createUserIfMissing(
        uid: user.uid,
        name: name ?? user.displayName ?? nameFromEmail(user.email),
        email: user.email ?? '',
      );
    } on AuthException catch (e) {
      debugPrint('Profile not created for ${user.uid}: ${e.code}');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
