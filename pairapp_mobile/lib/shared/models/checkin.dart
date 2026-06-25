import 'package:cloud_firestore/cloud_firestore.dart';

enum CheckinAnswer {
  yes,
  partially,
  no;

  static CheckinAnswer? fromString(String? value) {
    switch (value) {
      case 'yes':
        return CheckinAnswer.yes;
      case 'partially':
        return CheckinAnswer.partially;
      case 'no':
        return CheckinAnswer.no;
      default:
        return null;
    }
  }

  String get backendValue {
    switch (this) {
      case CheckinAnswer.yes:
        return 'yes';
      case CheckinAnswer.partially:
        return 'partially';
      case CheckinAnswer.no:
        return 'no';
    }
  }
}

enum CheckinStatus {
  pending,
  partial,
  completed,
  unknown;

  static CheckinStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return CheckinStatus.pending;
      case 'partial':
        return CheckinStatus.partial;
      case 'completed':
        return CheckinStatus.completed;
      default:
        return CheckinStatus.unknown;
    }
  }
}

enum CheckinResult {
  success,
  partial,
  failed,
  unknown;

  static CheckinResult? fromString(String? value) {
    switch (value) {
      case 'success':
        return CheckinResult.success;
      case 'partial':
        return CheckinResult.partial;
      case 'failed':
        return CheckinResult.failed;
      default:
        return null;
    }
  }
}

class Checkin {
  const Checkin({
    required this.id,
    required this.agreementId,
    required this.issueId,
    required this.coupleId,
    required this.scheduledAt,
    required this.partnerAAnswer,
    required this.partnerBAnswer,
    required this.partnerAAnsweredAt,
    required this.partnerBAnsweredAt,
    required this.status,
    required this.result,
    required this.createdAt,
    required this.completedAt,
    required this.notifiedAt,
  });

  final String id;
  final String agreementId;
  final String? issueId;
  final String coupleId;
  final DateTime? scheduledAt;
  final CheckinAnswer? partnerAAnswer;
  final CheckinAnswer? partnerBAnswer;
  final DateTime? partnerAAnsweredAt;
  final DateTime? partnerBAnsweredAt;
  final CheckinStatus status;
  final CheckinResult? result;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? notifiedAt;

  bool get isOpen =>
      status == CheckinStatus.pending || status == CheckinStatus.partial;

  bool get isCompleted => status == CheckinStatus.completed;

  factory Checkin.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Checkin.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Checkin.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    final dataId = _stringOrNull(data['id']);

    return Checkin(
      id: dataId?.isNotEmpty == true ? dataId! : id,
      agreementId: _stringOrNull(data['agreementId']) ?? '',
      issueId: _stringOrNull(data['issueId']),
      coupleId: _stringOrNull(data['coupleId']) ?? '',
      scheduledAt: _toDateTime(data['scheduledAt']),
      partnerAAnswer: CheckinAnswer.fromString(
        _stringOrNull(data['partnerAAnswer']),
      ),
      partnerBAnswer: CheckinAnswer.fromString(
        _stringOrNull(data['partnerBAnswer']),
      ),
      partnerAAnsweredAt: _toDateTime(data['partnerAAnsweredAt']),
      partnerBAnsweredAt: _toDateTime(data['partnerBAnsweredAt']),
      status: CheckinStatus.fromString(_stringOrNull(data['status'])),
      result: CheckinResult.fromString(_stringOrNull(data['result'])),
      createdAt: _toDateTime(data['createdAt']),
      completedAt: _toDateTime(data['completedAt']),
      notifiedAt: _toDateTime(data['notifiedAt']),
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value is String) return value;
    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
