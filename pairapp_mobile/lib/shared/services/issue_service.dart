import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/issue.dart';
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
