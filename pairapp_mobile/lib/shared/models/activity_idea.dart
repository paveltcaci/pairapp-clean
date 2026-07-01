/// Вид локации: дома, на улице/вне дома, любой.
enum ActivityLocationType { home, outside, any }

/// Вайб/настроение активности.
enum ActivityVibe { calm, fun, romantic, deep, spontaneous, cozy }

/// Уровень бюджета.
enum ActivityBudget { free, low, medium }

/// Локальная builtin-идея для пары.
/// Хранится в памяти приложения, не в Firestore.
class ActivityIdea {
  const ActivityIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.categories,
    required this.durationMinutes,
    required this.budget,
    required this.locationType,
    required this.vibe,
    this.preparation,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<String> categories;
  final int durationMinutes;
  final ActivityBudget budget;
  final ActivityLocationType locationType;
  final ActivityVibe vibe;
  final String? preparation;

  /// Локализованная строка бюджета.
  String get budgetLabel {
    switch (budget) {
      case ActivityBudget.free:
        return 'Бесплатно';
      case ActivityBudget.low:
        return 'Недорого';
      case ActivityBudget.medium:
        return 'Средний бюджет';
    }
  }

  /// Локализованная строка вайба.
  String get vibeLabel {
    switch (vibe) {
      case ActivityVibe.calm:
        return 'Спокойно';
      case ActivityVibe.fun:
        return 'Весело';
      case ActivityVibe.romantic:
        return 'Романтика';
      case ActivityVibe.deep:
        return 'Глубоко';
      case ActivityVibe.spontaneous:
        return 'Спонтанно';
      case ActivityVibe.cozy:
        return 'Уютно';
    }
  }

  /// Строка длительности.
  String get durationLabel {
    if (durationMinutes < 60) return '${durationMinutes} мин';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h} ч' : '${h} ч ${m} мин';
  }

  /// Сериализация для передачи в Cloud Function saveActivityIdeaSnapshot.
  Map<String, dynamic> toSavePayload() {
    return {
      'localIdeaId': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'categories': categories,
      'durationMinutes': durationMinutes,
      'budgetLevel': _budgetToString(budget),
      'locationType': _locationToString(locationType),
      'vibe': _vibeToString(vibe),
      if (preparation != null) 'preparation': preparation,
    };
  }

  static String _budgetToString(ActivityBudget b) {
    switch (b) {
      case ActivityBudget.free:
        return 'free';
      case ActivityBudget.low:
        return 'low';
      case ActivityBudget.medium:
        return 'medium';
    }
  }

  static String _locationToString(ActivityLocationType l) {
    switch (l) {
      case ActivityLocationType.home:
        return 'home';
      case ActivityLocationType.outside:
        return 'outside';
      case ActivityLocationType.any:
        return 'any';
    }
  }

  static String _vibeToString(ActivityVibe v) {
    switch (v) {
      case ActivityVibe.calm:
        return 'calm';
      case ActivityVibe.fun:
        return 'fun';
      case ActivityVibe.romantic:
        return 'romantic';
      case ActivityVibe.deep:
        return 'deep';
      case ActivityVibe.spontaneous:
        return 'spontaneous';
      case ActivityVibe.cozy:
        return 'cozy';
    }
  }
}
