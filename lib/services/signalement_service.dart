import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signalement.dart';
import '../utils/constants.dart';

/// Service des signalements : lecture et écriture dans la collection "signalements".
class SignalementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TODO(Dev 3) : creerSignalement(Signalement s)

  /// Dev 4 : Stream des signalements récents avec filtres optionnels
  Stream<List<Signalement>> getSignalements({
    String? statut,
    String? categorie,
  }) {
    // Dans Firestore, on garde seulement l'ordre par date pour éviter l'index composite
    return _db
        .collection(kCollectionSignalements)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => Signalement.fromFirestore(doc))
          .toList();

      // Filtrage dynamique en Dart
      if (statut != null && statut.isNotEmpty && statut != 'tous') {
        list = list.where((s) => s.statut == statut).toList();
      }
      if (categorie != null && categorie.isNotEmpty && categorie != 'toutes') {
        list = list.where((s) => s.categorie == categorie).toList();
      }

      return list;
    });
  }

  /// Dev 4 : Stream des signalements d'un utilisateur
  Stream<List<Signalement>> getMesSignalements(String userId) {
    return _db
        .collection(kCollectionSignalements)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Signalement.fromFirestore(doc))
          .toList();

      // Tri sécurisé en Dart avec vérification du caractère nul de createdAt
      list.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return list;
    });
  }

  /// Dev 4 : changerStatut(id, statut) — réservé à l'admin
  Future<void> changerStatut(String id, String nouveauStatut) async {
    await _db.collection(kCollectionSignalements).doc(id).update({
      'statut': nouveauStatut,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}