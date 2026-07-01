import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint('WATCH_ISSUE_MESSAGES_START issueId=$trimmedIssueId');

    if (trimmedIssueId.isEmpty) {
      return Stream.value(const <IssueMessage>[]);
    }

    late final StreamController<List<IssueMessage>> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
        issueSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
        messagesSubscription;
    var lifecycleVersion = 0;
    var messagesSubscriptionVersion = 0;

    Future<void> cancelCurrentSubscriptions() async {
      final issueToCancel = issueSubscription;
      final messagesToCancel = messagesSubscription;
      issueSubscription = null;
      messagesSubscription = null;

      await issueToCancel?.cancel();
      await messagesToCancel?.cancel();
    }

    Future<void> replaceMessagesSubscription(
      String? coupleId,
      int listenVersion,
    ) async {
      final messageVersion = ++messagesSubscriptionVersion;
      final previousSubscription = messagesSubscription;
      messagesSubscription = null;

      await previousSubscription?.cancel();

      final isCurrentListener =
          listenVersion == lifecycleVersion && controller.hasListener;
      final isCurrentMessageSubscription =
          messageVersion == messagesSubscriptionVersion;
      if (controller.isClosed ||
          !isCurrentListener ||
          !isCurrentMessageSubscription) {
        return;
      }

      final trimmedCoupleId = coupleId?.trim();
      if (trimmedCoupleId == null || trimmedCoupleId.isEmpty) {
        controller.add(const <IssueMessage>[]);
        return;
      }

      debugPrint(
        'WATCH_ISSUE_MESSAGES_QUERY_START '
        'issueId=$trimmedIssueId coupleId=$trimmedCoupleId',
      );

      messagesSubscription = _issueMessagesRef
          .where('coupleId', isEqualTo: trimmedCoupleId)
          .where('issueId', isEqualTo: trimmedIssueId)
          .snapshots()
          .listen(
        (snapshot) {
          if (controller.isClosed ||
              !controller.hasListener ||
              listenVersion != lifecycleVersion ||
              messageVersion != messagesSubscriptionVersion) {
            return;
          }

          final messages = snapshot.docs
              .map(IssueMessage.fromFirestore)
              .where((message) => !message.isDeleted)
              .toList();

          messages.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aDate.compareTo(bDate);
          });

          debugPrint('WATCH_ISSUE_MESSAGES_COUNT count=${messages.length}');

          if (!controller.isClosed) {
            controller.add(messages);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('WATCH_ISSUE_MESSAGES_ERROR error=$error');
          if (!controller.isClosed &&
              controller.hasListener &&
              listenVersion == lifecycleVersion &&
              messageVersion == messagesSubscriptionVersion) {
            controller.addError(error, stackTrace);
          }
        },
      );
    }

    controller = StreamController<List<IssueMessage>>.broadcast(
      onListen: () {
        final listenVersion = ++lifecycleVersion;
        messagesSubscriptionVersion++;
        debugPrint('WATCH_ISSUE_MESSAGES_ON_LISTEN issueId=$trimmedIssueId');
        unawaited(cancelCurrentSubscriptions());

        issueSubscription = _issuesRef.doc(trimmedIssueId).snapshots().listen(
          (issueDoc) {
            if (controller.isClosed ||
                !controller.hasListener ||
                listenVersion != lifecycleVersion) {
              return;
            }

            debugPrint(
              'WATCH_ISSUE_MESSAGES_DOC_UPDATE issueId=$trimmedIssueId',
            );

            if (!issueDoc.exists) {
              unawaited(replaceMessagesSubscription(null, listenVersion));
              return;
            }

            final issue = Issue.fromFirestore(issueDoc);
            unawaited(
              replaceMessagesSubscription(issue.coupleId, listenVersion),
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('WATCH_ISSUE_MESSAGES_ERROR error=$error');
            unawaited(replaceMessagesSubscription(null, listenVersion));
            if (!controller.isClosed &&
                controller.hasListener &&
                listenVersion == lifecycleVersion) {
              controller.addError(error, stackTrace);
            }
          },
        );
      },
      onCancel: () {
        lifecycleVersion++;
        messagesSubscriptionVersion++;
        debugPrint('WATCH_ISSUE_MESSAGES_ON_CANCEL issueId=$trimmedIssueId');
        unawaited(cancelCurrentSubscriptions());
      },
    );

    return controller.stream;
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
