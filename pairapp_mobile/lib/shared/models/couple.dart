import 'package:cloud_firestore/cloud_firestore.dart';

class Couple {
  final String id;
  final String partnerAId;
  final String? partnerBId;
  final String inviteCode;
  final bool inviteCodeUsed;
  final String status;

  const Couple({
    required this.id,
    required this.partnerAId,
    this.partnerBId,
    required this.inviteCode,
    this.inviteCodeUsed = false,
    required this.status,
  });

  /// True when the couple record has status 'active'.
  bool get isActive => status == 'active';

  /// True when a second partner has joined.
  bool get hasBothPartners =>
      partnerBId != null && partnerBId!.isNotEmpty;

  factory Couple.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Couple(
      id: doc.id,
      partnerAId: (data['partnerAId'] as String?) ?? '',
      partnerBId: data['partnerBId'] as String?,
      inviteCode: (data['inviteCode'] as String?) ?? '',
      inviteCodeUsed: (data['inviteCodeUsed'] as bool?) ?? false,
      status: (data['status'] as String?) ?? '',
    );
  }
}
