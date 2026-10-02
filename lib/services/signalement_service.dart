import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/signalement.dart';
import '../utils/constants.dart';

/// Service de gestion des signalements Firestore.
class SignalementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crée un nouveau signalement dans Firestore.
  Future<void> creerSignalement(Signalement signalement) async {
    await _db.collection(kCollectionSignalements).add(signalement.toMap());
  }

  /// Récupère les signalements récents avec filtres optionnels.
  Stream<List<Signalement>> getSignalements({
    String? statut,
    String? categorie,
  }) {
    return _db
        .collection(kCollectionSignalements)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs
              .map((doc) => Signalement.fromFirestore(doc))
              .toList();

          // Filtrage du statut en Dart.
          if (statut != null && statut.isNotEmpty && statut != 'tous') {
            list = list.where((s) => s.statut == statut).toList();
          }

          // Filtrage de la catégorie en Dart.
          if (categorie != null &&
              categorie.isNotEmpty &&
              categorie != 'toutes') {
            list = list.where((s) => s.categorie == categorie).toList();
          }

          return list;
        });
  }

  /// Récupère les signalements d'un utilisateur.
  Stream<List<Signalement>> getMesSignalements(String userId) {
    return _db
        .collection(kCollectionSignalements)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Signalement.fromFirestore(doc))
              .toList();

          // Tri du plus récent au plus ancien.
          list.sort((a, b) {
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;

            return b.createdAt!.compareTo(a.createdAt!);
          });

          return list;
        });
  }

  /// Change le statut d'un signalement.
  ///
  /// Cette opération doit être protégée par les règles
  /// Firestore afin d'être accessible uniquement à l'admin.
  Future<void> changerStatut(
    String id,
    String nouveauStatut,
  ) async {
    await _db.collection(kCollectionSignalements).doc(id).update({
      'statut': nouveauStatut,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
