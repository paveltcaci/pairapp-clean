/// Тип ответа на вопрос квиза.
enum QuizAnswerType {
  openText,
  choice;

  String get firestoreValue {
    switch (this) {
      case QuizAnswerType.openText:
        return 'open_text';
      case QuizAnswerType.choice:
        return 'choice';
    }
  }

  static QuizAnswerType fromString(String? value) {
    switch (value) {
      case 'choice':
        return QuizAnswerType.choice;
      default:
        return QuizAnswerType.openText;
    }
  }
}

/// Вариант ответа для вопросов типа [QuizAnswerType.choice].
class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;

  Map<String, dynamic> toMap() => {'id': id, 'text': text};
}

/// Категория квиза (встроенная в приложение).
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.gradient,
    this.subtitle = '',
    this.isAdult = false,
  });

  final String id;
  final String title;
  final String emoji;
  final List<int> gradient; // Two ARGB ints
  final String subtitle;
  final bool isAdult;
}

/// Вопрос квиза из локального банка вопросов.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.text,
    required this.answerType,
    this.options,
  });

  final String id;
  final String category;
  final String text;
  final QuizAnswerType answerType;
  final List<QuizOption>? options;
}
