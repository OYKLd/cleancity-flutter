import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/signalement.dart';
import '../utils/constants.dart';

/// Service des signalements : lecture et écriture dans la collection
/// "signalements" de Firestore.
/// creerSignalement complété par Dev 3. Le reste (lecture, statuts) reste
/// à compléter par Dev 4.
class SignalementService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection(kCollectionSignalements);

  /// Crée un nouveau signalement dans Firestore.
  /// Le statut est toujours "en_attente" à la création (voir modèle
  /// Signalement et règles de sécurité Firestore).
  Future<void> creerSignalement(Signalement signalement) async {
    await _collection.add(signalement.toMap());
  }

  // TODO(Dev 4) : Stream des signalements récents (avec filtres statut / catégorie)
  // TODO(Dev 4) : Stream des signalements d'un utilisateur
  // TODO(Dev 4) : changerStatut(id, statut) — réservé à l'admin
}