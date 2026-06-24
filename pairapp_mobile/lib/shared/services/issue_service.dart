import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/issue.dart';
import '../models/issue_message.dart';
import 'functions_service.dart';

class IssueService {
  IssueService({
    FirebaseFirestore? firestore,
    FunctionsService? functionsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functionsService = functionsService ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functionsService;

  CollectionReference<Map<String, dynamic>> get _issuesRef =>
      _firestore.collection('issues');

  CollectionReference<Map<String, dynamic>> get _issueMessagesRef =>
      _firestore.collection('issue_messages');

  Stream<List<Issue>> watchCoupleIssues(String coupleId) {
    final trimmedCoupleId = coupleId.trim();
    if (trimmedCoupleId.isEmpty) {
      return Stream.value(const <Issue>[]);
    }

    return _issuesRef
        .where('coupleId', isEqualTo: trimmedCoupleId)
        .snapshots()
        .map((snapshot) {
      final issues = snapshot.docs.map(Issue.fromFirestore).toList();
      issues.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return issues;
    });
  }

  Future<Issue?> getIssue(String issueId) async {
    final trimmedIssueId = issueId.trim();
    if (trimmedIssueId.isEmpty) return null;

    final doc = await _issuesRef.doc(trimmedIssueId).get();
    if (!doc.exists) return null;
    return Issue.fromFirestore(doc);
  }

  Future<String> createIssue({
    required String title,
    String? description,
    List<String> feelings = const <String>[],
    required int importanceLevel,
    String? desiredOutcome,
    required String category,
  }) async {
    try {
      final data = await _functionsService.call('createIssue', {
        'title': title.trim(),
        'description': _nullableTrimmed(description),
        'feelings': feelings,
        'importanceLevel': importanceLevel,
        'desiredOutcome': _nullableTrimmed(desiredOutcome),
        'category': category,
      });

      final issueId = data['issueId'] ?? data['id'];
      if (issueId is String && issueId.isNotEmpty) {
        return issueId;
      }

      throw IssueServiceException(
        'Backend returned invalid createIssue response: $data',
      );
    } on FunctionsCallException catch (e) {
      throw IssueServiceException(e.message, code: e.code, cause: e);
    } catch (e) {
      if (e is IssueServiceException) rethrow;
      throw IssueServiceException('Failed to create issue.', cause: e);
    }
  }

  Stream<List<IssueMessage>> watchIssueMessages(String issueId) {
    final trimmedIssueId = issueId.trim();
    if (trimmedIssueId.isEmpty) {
      return Stream.value(const <IssueMessage>[]);
    }

    return _issuesRef.doc(trimmedIssueId).snapshots().asyncExpand((issueDoc) {
      if (!issueDoc.exists) {
        return Stream.value(const <IssueMessage>[]);
      }

      final issue = Issue.fromFirestore(issueDoc);
      final coupleId = issue.coupleId.trim();
      if (coupleId.isEmpty) {
        return Stream.value(const <IssueMessage>[]);
      }

      return _issueMessagesRef
          .where('coupleId', isEqualTo: coupleId)
          .where('issueId', isEqualTo: trimmedIssueId)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map(IssueMessage.fromFirestore)
            .where((message) => !message.isDeleted)
            .toList();

        messages.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });

        return messages;
      });
    });
  }

  Future<String> createIssueMessage({
    required String issueId,
    required String text,
    String type = 'comment',
  }) async {
    final trimmedIssueId = issueId.trim();
    final trimmedText = text.trim();
    final resolvedType = _resolveUserMessageType(type);

    if (trimmedIssueId.isEmpty) {
      throw const IssueServiceException('issueId is required.');
    }
    if (trimmedText.isEmpty) {
      throw const IssueServiceException('Message text cannot be empty.');
    }

    try {
      final data = await _functionsService.call('createIssueMessage', {
        'issueId': trimmedIssueId,
        'text': trimmedText,
        'type': resolvedType.backendValue,
      });

      final messageId = data['messageId'] ?? data['id'];
      if (messageId is String && messageId.isNotEmpty) {
        return messageId;
      }

      throw IssueServiceException(
        'Backend returned invalid createIssueMessage response: $data',
      );
    } on FunctionsCallException catch (e) {
      throw IssueServiceException(e.message, code: e.code, cause: e);
    } catch (e) {
      if (e is IssueServiceException) rethrow;
      throw IssueServiceException('Failed to send message.', cause: e);
    }
  }

  IssueMessageType _resolveUserMessageType(String? type) {
    switch (type?.trim()) {
      case 'objection':
        return IssueMessageType.objection;
      case 'solution':
        return IssueMessageType.solution;
      case 'comment':
      default:
        return IssueMessageType.comment;
    }
  }

  String? _nullableTrimmed(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class IssueServiceException implements Exception {
  const IssueServiceException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final codePart = code == null ? '' : '[$code] ';
    return 'IssueServiceException: $codePart$message';
  }
}
