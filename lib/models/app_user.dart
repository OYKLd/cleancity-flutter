import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

/// Utilisateur de l'application, stocké dans users/{uid}.
class AppUser {
  final String uid;
  final String nom;
  final String email;
  final String role; // "citoyen" ou "admin"
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.nom,
    required this.email,
    this.role = kRoleCitoyen,
    this.createdAt,
  });

  bool get estAdmin => role == kRoleAdmin;

  /// Construit un AppUser à partir d'un document Firestore.
  /// Les valeurs par défaut évitent un crash si un champ manque.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      nom: data['nom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? kRoleCitoyen,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Données à écrire dans Firestore (l'uid est l'id du document, pas un champ).
  /// createdAt est fixé par le serveur Firebase à la création.
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
