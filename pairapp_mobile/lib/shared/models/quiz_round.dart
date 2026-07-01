import 'package:cloud_firestore/cloud_firestore.dart';

/// Статус раунда квиза (один вопрос для двух партнёров).
enum QuizRoundStatus {
  waitingBoth,    // Никто ещё не ответил
  waitingPartner, // Текущий пользователь ответил, ждём партнёра
  completed;      // Оба ответили — можно показывать reveal

  static QuizRoundStatus fromString(String? value) {
    switch (value) {
      case 'waiting_partner':
        return QuizRoundStatus.waitingPartner;
      case 'completed':
        return QuizRoundStatus.completed;
      default:
        return QuizRoundStatus.waitingBoth;
    }
  }
}

/// Один раунд квиза — один вопрос, два партнёра.
class QuizRound {
  const QuizRound({
    required this.id,
    required this.coupleId,
    required this.createdBy,
    required this.category,
    required this.questionId,
    required this.questionText,
    required this.answerType,
    required this.options,
    required this.answers,
    required this.status,
    required this.matched,
    required this.partnerAId,
    required this.partnerBId,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String coupleId;
  final String createdBy;
  final String category;
  final String questionId;
  final String questionText;
  final String answerType; // "open_text" | "choice"
  final List<Map<String, String>> options;
  /// uid → текст ответа
  final Map<String, String> answers;
  final QuizRoundStatus status;
  final bool? matched;
  final String partnerAId;
  final String partnerBId;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => status == QuizRoundStatus.completed;

  /// Ответил ли данный [uid].
  bool hasAnswered(String uid) => answers.containsKey(uid);

  /// Ответ данного [uid] (null если ещё не ответил).
  String? answerOf(String uid) => answers[uid];

  /// Id партнёра для данного [uid].
  String partnerOf(String uid) => uid == partnerAId ? partnerBId : partnerAId;

  factory QuizRound.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawAnswers = data['answers'] as Map<String, dynamic>? ?? {};
    final answers = rawAnswers.map((k, v) => MapEntry(k, v.toString()));

    final rawOptions = data['options'];
    final options = <Map<String, String>>[];
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        if (opt is Map) {
          options.add({
            'id': opt['id']?.toString() ?? '',
            'text': opt['text']?.toString() ?? '',
          });
        }
      }
    }

    return QuizRound(
      id: doc.id,
      coupleId: data['coupleId'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      category: data['category'] as String? ?? '',
      questionId: data['questionId'] as String? ?? '',
      questionText: data['questionText'] as String? ?? '',
      answerType: data['answerType'] as String? ?? 'open_text',
      options: options,
      answers: answers,
      status: QuizRoundStatus.fromString(data['status'] as String?),
      matched: data['matched'] as bool?,
      partnerAId: data['partnerAId'] as String? ?? '',
      partnerBId: data['partnerBId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
