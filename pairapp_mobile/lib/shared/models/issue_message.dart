import 'package:cloud_firestore/cloud_firestore.dart';

/// Backend message types for issue discussions.
enum IssueMessageType {
  comment,
  objection,
  solution,
  agreement,
  checkin,
  reopen,
  unknown;

  static IssueMessageType fromString(String? value) {
    switch (value) {
      case 'comment':
        return IssueMessageType.comment;
      case 'objection':
        return IssueMessageType.objection;
      case 'solution':
        return IssueMessageType.solution;
      case 'agreement':
        return IssueMessageType.agreement;
      case 'checkin':
        return IssueMessageType.checkin;
      case 'reopen':
        return IssueMessageType.reopen;
      default:
        return IssueMessageType.unknown;
    }
  }

  String get backendValue {
    switch (this) {
      case IssueMessageType.comment:
        return 'comment';
      case IssueMessageType.objection:
        return 'objection';
      case IssueMessageType.solution:
        return 'solution';
      case IssueMessageType.agreement:
        return 'agreement';
      case IssueMessageType.checkin:
        return 'checkin';
      case IssueMessageType.reopen:
        return 'reopen';
      case IssueMessageType.unknown:
        return 'unknown';
    }
  }
}

class IssueMessage {
  const IssueMessage({
    required this.id,
    required this.issueId,
    required this.coupleId,
    required this.authorId,
    required this.type,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.readByPartner,
  });

  final String id;
  final String issueId;
  final String coupleId;
  final String authorId;
  final IssueMessageType type;
  final String text;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final bool readByPartner;

  factory IssueMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return IssueMessage.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory IssueMessage.fromMap(Map<String, dynamic> data, {required String id}) {
    return IssueMessage(
      id: (data['id'] as String?)?.isNotEmpty == true
          ? data['id'] as String
          : id,
      issueId: (data['issueId'] as String?) ?? '',
      coupleId: (data['coupleId'] as String?) ?? '',
      authorId: (data['authorId'] as String?) ?? '',
      type: IssueMessageType.fromString(data['type'] as String?),
      text: (data['text'] as String?) ?? '',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      isDeleted: data['isDeleted'] == true,
      readByPartner: data['readByPartner'] == true,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
