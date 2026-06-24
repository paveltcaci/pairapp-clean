import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/agreement.dart';
import 'functions_service.dart';

/// Service for reading and mutating agreement documents.
///
/// Firestore collection: `agreements`.
/// Backend functions: `proposeAgreement`, `acceptAgreement`.
class AgreementService {
  AgreementService({
    FirebaseFirestore? firestore,
    FunctionsService? functionsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functionsService = functionsService ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functionsService;

  CollectionReference<Map<String, dynamic>> get _agreementsRef =>
      _firestore.collection('agreements');

  /// Watches all agreements for a given [issueId].
  ///
  /// Pass [coupleId] whenever possible. Firestore rules allow reads through
  /// `coupleId`, so querying only by `issueId` can fail with permission-denied.
  /// Sorted by createdAt descending on the client to avoid index requirements.
  Stream<List<Agreement>> watchIssueAgreements(
    String issueId, {
    String? coupleId,
  }) {
    final trimmedIssueId = issueId.trim();
    if (trimmedIssueId.isEmpty) {
      return Stream.value(const <Agreement>[]);
    }

    Query<Map<String, dynamic>> query = _agreementsRef.where(
      'issueId',
      isEqualTo: trimmedIssueId,
    );

    final trimmedCoupleId = coupleId?.trim();
    if (trimmedCoupleId != null && trimmedCoupleId.isNotEmpty) {
      query = query.where('coupleId', isEqualTo: trimmedCoupleId);
    }

    return query.snapshots().map(_mapAndSortSnapshot);
  }

  /// Watches all agreements for a given [coupleId].
  /// Sorted by createdAt descending on the client to avoid index requirements.
  Stream<List<Agreement>> watchCoupleAgreements(String coupleId) {
    final trimmedCoupleId = coupleId.trim();
    if (trimmedCoupleId.isEmpty) {
      return Stream.value(const <Agreement>[]);
    }

    return _agreementsRef
        .where('coupleId', isEqualTo: trimmedCoupleId)
        .snapshots()
        .map(_mapAndSortSnapshot);
  }

  /// Fetches a single agreement by [agreementId].
  /// Returns null if the document does not exist.
  Future<Agreement?> getAgreement(String agreementId) async {
    final trimmed = agreementId.trim();
    if (trimmed.isEmpty) return null;

    final doc = await _agreementsRef.doc(trimmed).get();
    if (!doc.exists) return null;
    return Agreement.fromFirestore(doc);
  }

  /// Calls the backend `proposeAgreement` Cloud Function.
  ///
  /// Backend input:
  /// - issueId?: string | null
  /// - title: string
  /// - description?: string | null
  /// - checkIntervalDays?: 1 | 3 | 7 | 14 | 30 | null
  /// - customCheckDate?: ISO string | null
  ///
  /// At least one of [checkIntervalDays] or [customCheckDate] is required.
  /// Returns the new agreementId.
  Future<String> proposeAgreement({
    String? issueId,
    required String title,
    String? description,
    int? checkIntervalDays,
    DateTime? customCheckDate,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw const AgreementServiceException('Введите текст договорённости.');
    }

    if (checkIntervalDays == null && customCheckDate == null) {
      throw const AgreementServiceException(
        'Выберите дату проверки договорённости.',
      );
    }

    if (checkIntervalDays != null &&
        !const <int>[1, 3, 7, 14, 30].contains(checkIntervalDays)) {
      throw const AgreementServiceException(
        'Недопустимый интервал проверки договорённости.',
      );
    }

    final payload = <String, dynamic>{
      'title': trimmedTitle,
    };

    final trimmedIssueId = issueId?.trim();
    if (trimmedIssueId != null && trimmedIssueId.isNotEmpty) {
      payload['issueId'] = trimmedIssueId;
    }

    final trimmedDescription = description?.trim();
    if (trimmedDescription != null && trimmedDescription.isNotEmpty) {
      payload['description'] = trimmedDescription;
    }

    if (checkIntervalDays != null) {
      payload['checkIntervalDays'] = checkIntervalDays;
    }

    if (customCheckDate != null) {
      payload['customCheckDate'] = customCheckDate.toIso8601String();
    }

    try {
      final data = await _functionsService.call('proposeAgreement', payload);
      final agreementId = data['agreementId'] ?? data['id'];

      if (agreementId is String && agreementId.isNotEmpty) {
        return agreementId;
      }

      throw AgreementServiceException(
        'Backend returned invalid proposeAgreement response: $data',
      );
    } on FunctionsCallException catch (e) {
      throw AgreementServiceException(e.message, code: e.code, cause: e);
    } catch (e) {
      if (e is AgreementServiceException) rethrow;
      throw AgreementServiceException(
        'Не удалось предложить договорённость.',
        cause: e,
      );
    }
  }

  /// Calls the backend `acceptAgreement` Cloud Function.
  Future<void> acceptAgreement(String agreementId) async {
    final trimmed = agreementId.trim();
    if (trimmed.isEmpty) {
      throw const AgreementServiceException('agreementId is required.');
    }

    try {
      await _functionsService.call('acceptAgreement', {
        'agreementId': trimmed,
      });
    } on FunctionsCallException catch (e) {
      throw AgreementServiceException(e.message, code: e.code, cause: e);
    } catch (e) {
      if (e is AgreementServiceException) rethrow;
      throw AgreementServiceException(
        'Не удалось принять договорённость.',
        cause: e,
      );
    }
  }

  List<Agreement> _mapAndSortSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = snapshot.docs.map(Agreement.fromFirestore).toList();
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return list;
  }
}

class AgreementServiceException implements Exception {
  const AgreementServiceException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final codePart = code == null ? '' : '[$code] ';
    return 'AgreementServiceException: $codePart$message';
  }
}
