import 'package:firebase_auth/firebase_auth.dart';

/// Service d'authentification : seul point de contact avec Firebase Auth.
/// Base posée en Phase 1 ; inscription / connexion / déconnexion
/// à compléter par Dev 2 (feature/auth).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Émet l'utilisateur connecté, ou null s'il est déconnecté.
  /// Utilisé par l'écran de démarrage pour rediriger.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get utilisateurActuel => _auth.currentUser;

  // TODO(Dev 2) : inscrire(nom, email, motDePasse) -> crée aussi users/{uid}
  // TODO(Dev 2) : connecter(email, motDePasse)
  // TODO(Dev 2) : deconnecter()
  // TODO(Dev 2) : traduire les FirebaseAuthException en messages français
}
