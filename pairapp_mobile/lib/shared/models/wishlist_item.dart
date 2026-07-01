import 'package:cloud_firestore/cloud_firestore.dart';

/// Статус желания.
enum WishlistStatus {
  active,
  done,
  archived;

  String get label {
    switch (this) {
      case WishlistStatus.active:
        return 'Активное';
      case WishlistStatus.done:
        return 'Выполнено';
      case WishlistStatus.archived:
        return 'Архив';
    }
  }

  static WishlistStatus fromString(String? value) {
    switch (value) {
      case 'done':
        return WishlistStatus.done;
      case 'archived':
        return WishlistStatus.archived;
      default:
        return WishlistStatus.active;
    }
  }
}

/// Приоритет желания.
enum WishlistPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case WishlistPriority.low:
        return 'Низкий';
      case WishlistPriority.medium:
        return 'Средний';
      case WishlistPriority.high:
        return 'Высокий';
    }
  }

  static WishlistPriority fromString(String? value) {
    switch (value) {
      case 'low':
        return WishlistPriority.low;
      case 'high':
        return WishlistPriority.high;
      default:
        return WishlistPriority.medium;
    }
  }
}

/// Уровень бюджета желания.
enum WishlistBudget {
  free,
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case WishlistBudget.free:
        return 'Бесплатно';
      case WishlistBudget.low:
        return 'Недорого';
      case WishlistBudget.medium:
        return 'Средне';
      case WishlistBudget.high:
        return 'Дорого';
    }
  }

  static WishlistBudget fromString(String? value) {
    switch (value) {
      case 'low':
        return WishlistBudget.low;
      case 'medium':
        return WishlistBudget.medium;
      case 'high':
        return WishlistBudget.high;
      default:
        return WishlistBudget.free;
    }
  }
}

/// Документ коллекции `wishlist_items`.
class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.coupleId,
    required this.title,
    this.description,
    required this.emoji,
    required this.category,
    required this.priority,
    required this.budgetLevel,
    required this.status,
    required this.createdBy,
    this.completedBy,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String coupleId;
  final String title;
  final String? description;
  final String emoji;
  final String category;
  final WishlistPriority priority;
  final WishlistBudget budgetLevel;
  final WishlistStatus status;
  final String createdBy;
  final String? completedBy;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == WishlistStatus.active;
  bool get isDone => status == WishlistStatus.done;
  bool get isArchived => status == WishlistStatus.archived;

  String get priorityLabel => priority.label;
  String get budgetLabel => budgetLevel.label;
  String get statusLabel => status.label;

  factory WishlistItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WishlistItem(
      id: doc.id,
      coupleId: (data['coupleId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: data['description'] as String?,
      emoji: (data['emoji'] as String?) ?? '✨',
      category: (data['category'] as String?) ?? 'другое',
      priority: WishlistPriority.fromString(data['priority'] as String?),
      budgetLevel: WishlistBudget.fromString(data['budgetLevel'] as String?),
      status: WishlistStatus.fromString(data['status'] as String?),
      createdBy: (data['createdBy'] as String?) ?? '',
      completedBy: data['completedBy'] as String?,
      completedAt: _tsToDateTime(data['completedAt']),
      createdAt: _tsToDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _tsToDateTime(data['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _tsToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
