import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/checkin.dart';
import 'functions_service.dart';

class CheckinService {
  CheckinService({
    FirebaseFirestore? firestore,
    FunctionsService? functionsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functionsService = functionsService ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functionsService;

  CollectionReference<Map<String, dynamic>> get _checkinsRef =>
      _firestore.collection('checkins');

  Stream<List<Checkin>> watchCoupleCheckins(String coupleId) {
    final trimmedCoupleId = coupleId.trim();
    if (trimmedCoupleId.isEmpty) {
      return Stream.value(const <Checkin>[]);
    }

    return _checkinsRef
        .where('coupleId', isEqualTo: trimmedCoupleId)
        .snapshots()
        .map(_mapAndSortSnapshot);
  }

  Future<SubmitCheckinAnswerResult> submitCheckinAnswer({
    required String checkinId,
    required CheckinAnswer answer,
  }) async {
    final trimmedCheckinId = checkinId.trim();
    if (trimmedCheckinId.isEmpty) {
      throw const CheckinServiceException('checkinId is required.');
    }

    try {
      final data = await _functionsService.call('submitCheckinAnswer', {
        'checkinId': trimmedCheckinId,
        'answer': answer.backendValue,
      });

      return SubmitCheckinAnswerResult.fromMap(data);
    } on FunctionsCallException catch (e) {
      throw CheckinServiceException(e.message, code: e.code, cause: e);
    } catch (e) {
      if (e is CheckinServiceException) rethrow;
      throw CheckinServiceException(
        'Не удалось отправить ответ на check-in.',
        cause: e,
      );
    }
  }

  List<Checkin> _mapAndSortSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = snapshot.docs.map(Checkin.fromFirestore).toList();
    list.sort((a, b) {
      final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return list;
  }
}

class SubmitCheckinAnswerResult {
  const SubmitCheckinAnswerResult({
    required this.bothAnswered,
    required this.result,
  });

  final bool bothAnswered;
  final CheckinResult? result;

  factory SubmitCheckinAnswerResult.fromMap(Map<String, dynamic> data) {
    return SubmitCheckinAnswerResult(
      bothAnswered: data['bothAnswered'] == true,
      result: CheckinResult.fromString(data['result'] as String?),
    );
  }
}

class CheckinServiceException implements Exception {
  const CheckinServiceException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final codePart = code == null ? '' : '[$code] ';
    return 'CheckinServiceException: $codePart$message';
  }
}
