import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

/// Un signalement de problème urbain, stocké dans signalements/{id}.
class Signalement {
  final String id;
  final String userId;
  final String userNom;
  final String description;
  final String photoBase64; // photo JPEG compressée, encodée en base64
  final String categorie; // ordures | caniveau | eau_stagnante | autre
  final String urgence; // faible | moyenne | elevee
  final String statut; // en_attente | en_cours | resolu
  // Position GPS, ou commune + repère si le GPS n'est pas disponible
  final double? latitude;
  final double? longitude;
  final String? commune;
  final String? repere;
  final bool analyseIA; // true si la catégorie a été proposée par l'IA
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Signalement({
    this.id = '',
    required this.userId,
    required this.userNom,
    required this.description,
    required this.photoBase64,
    required this.categorie,
    required this.urgence,
    this.statut = kStatutEnAttente,
    this.latitude,
    this.longitude,
    this.commune,
    this.repere,
    this.analyseIA = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get aDesCoordonnees => latitude != null && longitude != null;

  /// Construit un Signalement à partir d'un document Firestore.
  factory Signalement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Signalement(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userNom: data['userNom'] as String? ?? '',
      description: data['description'] as String? ?? '',
      photoBase64: data['photoBase64'] as String? ?? '',
      categorie: data['categorie'] as String? ?? 'autre',
      urgence: data['urgence'] as String? ?? 'moyenne',
      statut: data['statut'] as String? ?? kStatutEnAttente,
      // Firestore peut renvoyer un int ou un double : "num" couvre les deux
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      commune: data['commune'] as String?,
      repere: data['repere'] as String?,
      analyseIA: data['analyseIA'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Données à écrire dans Firestore (l'id est l'id du document, pas un champ).
  /// Les dates absentes sont fixées par le serveur Firebase.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userNom': userNom,
      'description': description,
      'photoBase64': photoBase64,
      'categorie': categorie,
      'urgence': urgence,
      'statut': statut,
      'latitude': latitude,
      'longitude': longitude,
      'commune': commune,
      'repere': repere,
      'analyseIA': analyseIA,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
