import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signalement.dart';

/// Service des signalements : lecture et écriture dans la collection "signalements".
class SignalementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TODO(Dev 3) : creerSignalement(Signalement s)

  /// Dev 4 : Stream des signalements récents avec filtres optionnels
  Stream<List<Signalement>> getSignalements({String? statut, String? categorie}) {
    Query<Map<String, dynamic>> query = _db.collection('signalements').orderBy('createdAt', descending: true);

    if (statut != null && statut.isNotEmpty && statut != 'tous') {
      query = query.where('statut', isEqualTo: statut);
    }
    if (categorie != null && categorie.isNotEmpty && categorie != 'toutes') {
      query = query.where('categorie', isEqualTo: categorie);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Signalement.fromFirestore(doc)).toList();
    });
  }

  /// Dev 4 : Stream des signalements d'un utilisateur
  Stream<List<Signalement>> getMesSignalements(String userId) {
    return _db
        .collection('signalements')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Signalement.fromFirestore(doc)).toList());
  }

  /// Dev 4 : changerStatut(id, statut) — réservé à l'admin
  Future<void> changerStatut(String id, String nouveauStatut) async {
    await _db.collection('signalements').doc(id).update({
      'statut': nouveauStatut,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}