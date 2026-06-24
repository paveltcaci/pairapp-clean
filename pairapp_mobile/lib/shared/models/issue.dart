import 'package:cloud_firestore/cloud_firestore.dart';

/// Backend issue statuses.
/// Source of truth: pairapp-backend/functions/src/types/common.ts.
enum IssueStatus {
  open,
  inDiscussion,
  agreementProposed,
  agreed,
  solved,
  reopened,
  archived,
  unknown;

  static IssueStatus fromString(String? value) {
    switch (value) {
      case 'open':
        return IssueStatus.open;
      case 'in_discussion':
        return IssueStatus.inDiscussion;
      case 'agreement_proposed':
        return IssueStatus.agreementProposed;
      case 'agreed':
        return IssueStatus.agreed;
      case 'solved':
        return IssueStatus.solved;
      case 'reopened':
        return IssueStatus.reopened;
      case 'archived':
        return IssueStatus.archived;
      default:
        return IssueStatus.unknown;
    }
  }

  String get backendValue {
    switch (this) {
      case IssueStatus.open:
        return 'open';
      case IssueStatus.inDiscussion:
        return 'in_discussion';
      case IssueStatus.agreementProposed:
        return 'agreement_proposed';
      case IssueStatus.agreed:
        return 'agreed';
      case IssueStatus.solved:
        return 'solved';
      case IssueStatus.reopened:
        return 'reopened';
      case IssueStatus.archived:
        return 'archived';
      case IssueStatus.unknown:
        return 'unknown';
    }
  }
}

class Issue {
  const Issue({
    required this.id,
    required this.coupleId,
    required this.authorId,
    required this.title,
    required this.description,
    required this.feelings,
    required this.importanceLevel,
    required this.desiredOutcome,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.solvedAt,
    required this.reopenedAt,
    required this.archivedAt,
    required this.messageCount,
    required this.lastMessageAt,
  });

  final String id;
  final String coupleId;
  final String authorId;
  final String title;
  final String? description;
  final List<String> feelings;
  final int importanceLevel;
  final String? desiredOutcome;
  final String category;
  final IssueStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? solvedAt;
  final DateTime? reopenedAt;
  final DateTime? archivedAt;
  final int messageCount;
  final DateTime? lastMessageAt;

  bool get isOpen => status == IssueStatus.open;
  bool get isSolved => status == IssueStatus.solved;
  bool get isInDiscussion => status == IssueStatus.inDiscussion;
  bool get isAgreementProposed => status == IssueStatus.agreementProposed;
  bool get isAgreed => status == IssueStatus.agreed;
  bool get isReopened => status == IssueStatus.reopened;
  bool get isArchived => status == IssueStatus.archived;

  factory Issue.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Issue.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory Issue.fromMap(Map<String, dynamic> data, {required String id}) {
    return Issue(
      id: (data['id'] as String?)?.isNotEmpty == true
          ? data['id'] as String
          : id,
      coupleId: (data['coupleId'] as String?) ?? '',
      authorId: (data['authorId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: data['description'] as String?,
      feelings: _stringList(data['feelings']),
      importanceLevel: _intValue(data['importanceLevel'], fallback: 1),
      desiredOutcome: data['desiredOutcome'] as String?,
      category: (data['category'] as String?) ?? 'other',
      status: IssueStatus.fromString(data['status'] as String?),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      solvedAt: _toDateTime(data['solvedAt']),
      reopenedAt: _toDateTime(data['reopenedAt']),
      archivedAt: _toDateTime(data['archivedAt']),
      messageCount: _intValue(data['messageCount']),
      lastMessageAt: _toDateTime(data['lastMessageAt']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value.whereType<String>().toList(growable: false);
    }
    return const <String>[];
  }

  static int _intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
