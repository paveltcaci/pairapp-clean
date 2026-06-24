import 'package:cloud_firestore/cloud_firestore.dart';

/// Backend agreement statuses.
/// Source of truth: pairapp-backend/functions/src/types/common.ts.
enum AgreementStatus {
  proposed,
  acceptedByOne,
  acceptedByBoth,
  active,
  failed,
  completed,
  archived,
  unknown;

  static AgreementStatus fromString(String? value) {
    switch (value) {
      case 'proposed':
        return AgreementStatus.proposed;
      case 'accepted_by_one':
        return AgreementStatus.acceptedByOne;
      case 'accepted_by_both':
        return AgreementStatus.acceptedByBoth;
      case 'active':
        return AgreementStatus.active;
      case 'failed':
        return AgreementStatus.failed;
      case 'completed':
        return AgreementStatus.completed;
      case 'archived':
        return AgreementStatus.archived;
      default:
        return AgreementStatus.unknown;
    }
  }

  String get backendValue {
    switch (this) {
      case AgreementStatus.proposed:
        return 'proposed';
      case AgreementStatus.acceptedByOne:
        return 'accepted_by_one';
      case AgreementStatus.acceptedByBoth:
        return 'accepted_by_both';
      case AgreementStatus.active:
        return 'active';
      case AgreementStatus.failed:
        return 'failed';
      case AgreementStatus.completed:
        return 'completed';
      case AgreementStatus.archived:
        return 'archived';
      case AgreementStatus.unknown:
        return 'unknown';
    }
  }
}

/// Represents an agreement document from the Firestore `agreements` collection.
/// Source of truth: pairapp-backend/functions/src/types/agreement.ts.
class Agreement {
  const Agreement({
    required this.id,
    required this.coupleId,
    required this.issueId,
    required this.title,
    required this.description,
    required this.proposedBy,
    required this.acceptedByPartnerA,
    required this.acceptedByPartnerB,
    required this.status,
    required this.checkIntervalDays,
    required this.checkDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String coupleId;
  final String? issueId;
  final String title;
  final String? description;
  final String proposedBy;
  final bool acceptedByPartnerA;
  final bool acceptedByPartnerB;
  final AgreementStatus status;

  /// null means "custom date" — checkDate is still expected to be set.
  final int? checkIntervalDays;
  final DateTime? checkDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending =>
      status == AgreementStatus.proposed ||
      status == AgreementStatus.acceptedByOne;

  bool get isAccepted =>
      status == AgreementStatus.acceptedByBoth ||
      status == AgreementStatus.active;

  bool get isCompleted => status == AgreementStatus.completed;

  bool get isFailed => status == AgreementStatus.failed;

  bool get isActive => status == AgreementStatus.active;

  factory Agreement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Agreement.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Agreement.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    final dataId = _stringOrNull(data['id']);

    return Agreement(
      id: dataId?.isNotEmpty == true ? dataId! : id,
      coupleId: _stringOrNull(data['coupleId']) ?? '',
      issueId: _stringOrNull(data['issueId']),
      title: _stringOrNull(data['title']) ?? '',
      description: _stringOrNull(data['description']),
      proposedBy: _stringOrNull(data['proposedBy']) ?? '',
      acceptedByPartnerA: _boolOrFalse(data['acceptedByPartnerA']),
      acceptedByPartnerB: _boolOrFalse(data['acceptedByPartnerB']),
      status: AgreementStatus.fromString(_stringOrNull(data['status'])),
      checkIntervalDays: _intOrNull(data['checkIntervalDays']),
      checkDate: _toDateTime(data['checkDate']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value is String) return value;
    return null;
  }

  static bool _boolOrFalse(dynamic value) {
    if (value is bool) return value;
    return false;
  }

  static int? _intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
