import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';
import 'auth_exception.dart';

/// Reads and writes the users/{uid} profile documents in Firestore, and
/// counts the reports of a user. Throws [AuthException] on failure.
class UserService {
  UserService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  // Resolved lazily so widget tests can build screens without Firebase.
  FirebaseFirestore get _db => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(kCollectionUsers);

  /// Creates the profile with the "citoyen" role when it does not exist yet.
  /// An existing document is left untouched, so an admin keeps their role.
  Future<void> createUserIfMissing({
    required String uid,
    required String name,
    required String email,
  }) {
    return translateFirebaseErrors(() async {
      final doc = _users.doc(uid);
      final snapshot = await doc.get();
      if (snapshot.exists) return;
      await doc.set(AppUser(uid: uid, nom: name, email: email).toMap());
    });
  }

  /// Real-time profile; emits null while the document does not exist.
  Stream<AppUser?> watchUser(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists ? AppUser.fromFirestore(snapshot) : null,
        );
  }

  Future<void> updateName({required String uid, required String name}) {
    return translateFirebaseErrors(() => _users.doc(uid).update({'nom': name}));
  }

  /// Server-side aggregation: the documents (and their photos) are never
  /// downloaded just to count them.
  Future<int> countReports(String uid) {
    return translateFirebaseErrors(() async {
      final snapshot = await _db
          .collection(kCollectionSignalements)
          .where('userId', isEqualTo: uid)
          .count()
          .get();
      return snapshot.count ?? 0;
    });
  }
}
