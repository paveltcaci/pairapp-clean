import 'package:cloud_firestore/cloud_firestore.dart';

/// Интенсивность / неприятность задачи.
enum ChoreIntensity {
  easy,
  medium,
  annoying;

  String get label {
    switch (this) {
      case ChoreIntensity.easy:
        return 'Лёгкая';
      case ChoreIntensity.medium:
        return 'Обычная';
      case ChoreIntensity.annoying:
        return 'Бесячая';
    }
  }

  static ChoreIntensity fromString(String? value) {
    switch (value) {
      case 'easy':
        return ChoreIntensity.easy;
      case 'annoying':
        return ChoreIntensity.annoying;
      default:
        return ChoreIntensity.medium;
    }
  }
}

/// Документ из коллекции `chore_tasks`.
class ChoreTask {
  const ChoreTask({
    required this.id,
    required this.coupleId,
    required this.title,
    this.description,
    required this.emoji,
    required this.category,
    required this.intensity,
    this.estimatedMinutes,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String coupleId;
  final String title;
  final String? description;
  final String emoji;
  final String category;
  final ChoreIntensity intensity;
  final int? estimatedMinutes;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Создаёт [ChoreTask] из Firestore DocumentSnapshot.
  /// Null-safe: все поля защищены от отсутствия в документе.
  factory ChoreTask.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChoreTask(
      id: doc.id,
      coupleId: (data['coupleId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: data['description'] as String?,
      emoji: (data['emoji'] as String?) ?? '🧹',
      category: (data['category'] as String?) ?? 'другое',
      intensity: ChoreIntensity.fromString(data['intensity'] as String?),
      estimatedMinutes: data['estimatedMinutes'] as int?,
      isActive: (data['isActive'] as bool?) ?? true,
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: _tsToDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _tsToDateTime(data['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _tsToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  /// Строка времени выполнения для UI.
  String? get estimatedLabel {
    final mins = estimatedMinutes;
    if (mins == null) return null;
    if (mins < 60) return '~$mins мин';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '~$h ч' : '~$h ч $m мин';
  }
}
