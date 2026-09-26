import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Rend l'utilisateur connecté accessible à tous les écrans via Provider.
/// Les écrans font : `context.watch<AuthProvider>().user`
/// Le profil complet (nom, rôle admin) sera ajouté par Dev 2.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _abonnement;

  User? _user;
  User? get user => _user;
  bool get estConnecte => _user != null;

  // Au lancement, Firebase met un court instant à retrouver la session
  // enregistrée sur le téléphone. Tant que ce n'est pas fait, on ne sait pas
  // encore si l'utilisateur est connecté : le splash affiche un chargement.
  bool _initialise = false;
  bool get initialise => _initialise;

  AuthProvider(this._authService) {
    _user = _authService.utilisateurActuel;
    // On écoute les changements (connexion / déconnexion) pour
    // mettre à jour automatiquement l'interface.
    _abonnement = _authService.authStateChanges.listen((user) {
      _user = user;
      _initialise = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    super.dispose();
  }
}
