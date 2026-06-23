import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/couple.dart';
import 'functions_service.dart';

// ── Result types ─────────────────────────────────────────────────────────────

/// Returned by [CoupleService.createCouple].
class CreateCoupleResult {
  const CreateCoupleResult({
    required this.coupleId,
    required this.inviteCode,
  });

  final String coupleId;
  final String inviteCode;
}

/// Returned by [CoupleService.joinCoupleByInviteCode].
class JoinCoupleResult {
  const JoinCoupleResult({required this.coupleId});

  final String coupleId;
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Handles couple creation, joining, and real-time Firestore observation.
class CoupleService {
  CoupleService({
    FirebaseFirestore? firestore,
    FunctionsService? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functions;

  // ── Internal helpers ──────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _coupleDoc(String coupleId) =>
      _firestore.collection('couples').doc(coupleId);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Creates a new couple and returns the couple ID and invite code.
  Future<CreateCoupleResult> createCouple() async {
    final result = await _functions.call('createCouple');
    return CreateCoupleResult(
      coupleId: result['coupleId'] as String,
      inviteCode: result['inviteCode'] as String,
    );
  }

  /// Joins an existing couple via an invite code.
  ///
  /// The code is trimmed and upper-cased before being sent to the backend.
  Future<JoinCoupleResult> joinCoupleByInviteCode(String inviteCode) async {
    final normalized = inviteCode.trim().toUpperCase();
    final result = await _functions.call(
      'joinCoupleByInviteCode',
      {'inviteCode': normalized},
    );
    return JoinCoupleResult(coupleId: result['coupleId'] as String);
  }

  /// Real-time stream of a couple document.
  /// Emits `null` when the document does not exist.
  Stream<Couple?> watchCouple(String coupleId) =>
      _coupleDoc(coupleId)
          .snapshots()
          .map((snap) => snap.exists ? Couple.fromFirestore(snap) : null);

  /// One-shot fetch of a couple document.
  Future<Couple?> getCouple(String coupleId) async {
    final snap = await _coupleDoc(coupleId).get();
    return snap.exists ? Couple.fromFirestore(snap) : null;
  }
}
