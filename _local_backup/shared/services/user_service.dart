import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'functions_service.dart';

/// Handles reading the Firestore user profile and calling the
/// `completeUserProfile` callable function.
class UserService {
  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FunctionsService? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FunctionsService _functions;

  // ── Internal helpers ──────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  String? get _uid => _auth.currentUser?.uid;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Real-time stream of the signed-in user's Firestore profile.
  /// Emits `null` when no user is signed in or the document is missing.
  Stream<AppUser?> watchCurrentUserProfile() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _userDoc(uid)
        .snapshots()
        .map((snap) => snap.exists ? AppUser.fromFirestore(snap) : null);
  }

  /// One-shot fetch of the signed-in user's Firestore profile.
  Future<AppUser?> getCurrentUserProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    final snap = await _userDoc(uid).get();
    return snap.exists ? AppUser.fromFirestore(snap) : null;
  }

  /// Calls the `completeUserProfile` Cloud Function.
  ///
  /// Because the Firebase Auth `onCreate` trigger that creates the Firestore
  /// document runs asynchronously, the document may not exist yet immediately
  /// after registration. This method retries up to [_maxRetries] times with a
  /// [_retryDelay] between attempts before giving up.
  Future<void> completeUserProfile({
    required String displayName,
    required String gender,
    required String birthDate,
    required String language,
  }) async {
    const maxRetries = 5;
    const retryDelay = Duration(milliseconds: 500);

    final payload = <String, dynamic>{
      'displayName': displayName,
      'gender': gender,
      'birthDate': birthDate,
      'language': language,
      'acceptedTermsOfUse': true,
      'acceptedPrivacyPolicy': true,
    };

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _functions.call('completeUserProfile', payload);
        return; // success
      } on FunctionsCallException catch (e) {
        if (e.code == 'not-found' && attempt < maxRetries) {
          await Future<void>.delayed(retryDelay);
          continue;
        }
        // Either a different error, or we've exhausted retries.
        if (e.code == 'not-found') {
          throw FunctionsCallException(
            code: 'not-found',
            message:
                'User profile was not created in time. '
                'Please try again in a moment.',
            original: e.original,
          );
        }
        rethrow;
      }
    }
  }
}
