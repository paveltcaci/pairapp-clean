import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quiz_round.dart';
import 'functions_service.dart';

/// Сервис для квизов V1 (один вопрос — один раунд).
/// Read: прямые Firestore-запросы по coupleId.
/// Write: через Cloud Functions.
class QuizService {
  QuizService({
    FirebaseFirestore? firestore,
    FunctionsService? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functions;

  static const String _collection = 'quiz_rounds';

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Стрим активного раунда пары (waiting_both или waiting_partner).
  /// Возвращает null если нет активного раунда.
  Stream<QuizRound?> watchActiveRound(String coupleId) {
    return _firestore
        .collection(_collection)
        .where('coupleId', isEqualTo: coupleId)
        .where('status', whereIn: ['waiting_both', 'waiting_partner'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return QuizRound.fromFirestore(snap.docs.first);
        });
  }

  /// Стрим последних завершённых раундов пары (для истории).
  Stream<List<QuizRound>> watchCompletedRounds(String coupleId,
      {int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('coupleId', isEqualTo: coupleId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuizRound.fromFirestore(d)).toList());
  }

  /// Стрим одного конкретного раунда по id.
  Stream<QuizRound?> watchRound(String roundId) {
    return _firestore
        .collection(_collection)
        .doc(roundId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return QuizRound.fromFirestore(snap);
    });
  }

  // ── Cloud Function calls ──────────────────────────────────────────────────

  /// Создаёт новый раунд с одним вопросом.
  Future<String> createQuizRound({
    required String category,
    required String questionId,
    required String questionText,
    required String answerType,
    List<Map<String, String>>? options,
  }) async {
    final result = await _functions.call('createQuizRound', {
      'category': category,
      'questionId': questionId,
      'questionText': questionText,
      'answerType': answerType,
      if (options != null && options.isNotEmpty) 'options': options,
    });
    return result['roundId'] as String;
  }

  /// Отправляет ответ текущего пользователя.
  Future<Map<String, dynamic>> submitQuizAnswer({
    required String roundId,
    required String answer,
  }) async {
    return _functions.call('submitQuizAnswer', {
      'roundId': roundId,
      'answer': answer,
    });
  }
}
