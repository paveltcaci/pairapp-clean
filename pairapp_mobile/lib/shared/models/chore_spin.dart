import 'package:cloud_firestore/cloud_firestore.dart';

/// Документ из коллекции `chore_spins`.
/// Хранит результат одного запуска рандомайзера для бытовой задачи.
class ChoreSpin {
  const ChoreSpin({
    required this.id,
    required this.choreTaskId,
    required this.coupleId,
    required this.selectedUserId,
    this.titleSnapshot,
    this.emojiSnapshot,
    this.categorySnapshot,
    required this.spunAt,
    required this.partnerARecentCount,
    required this.partnerBRecentCount,
  });

  final String id;
  final String choreTaskId;
  final String coupleId;

  /// UID пользователя, которому выпала задача.
  final String selectedUserId;

  /// Снапшот названия задачи на момент спина (не зависит от soft-delete).
  final String? titleSnapshot;

  /// Снапшот emoji задачи на момент спина.
  final String? emojiSnapshot;

  /// Снапшот категории задачи на момент спина.
  final String? categorySnapshot;

  final DateTime spunAt;

  /// Количество раз, которое выпал partnerA за последние N спинов.
  final int partnerARecentCount;

  /// Количество раз, которое выпал partnerB за последние N спинов.
  final int partnerBRecentCount;

  /// Создаёт [ChoreSpin] из Firestore DocumentSnapshot.
  /// Null-safe для всех необязательных полей.
  factory ChoreSpin.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChoreSpin(
      id: doc.id,
      choreTaskId: (data['choreTaskId'] as String?) ?? '',
      coupleId: (data['coupleId'] as String?) ?? '',
      selectedUserId: (data['selectedUserId'] as String?) ?? '',
      titleSnapshot: data['titleSnapshot'] as String?,
      emojiSnapshot: data['emojiSnapshot'] as String?,
      categorySnapshot: data['categorySnapshot'] as String?,
      spunAt: _tsToDateTime(data['spunAt']) ?? DateTime.now(),
      partnerARecentCount: (data['partnerARecentCount'] as int?) ?? 0,
      partnerBRecentCount: (data['partnerBRecentCount'] as int?) ?? 0,
    );
  }

  /// Отображаемое название: сначала снапшот, fallback — choreTaskId.
  String get displayTitle => titleSnapshot ?? 'Задача';

  /// Отображаемое emoji: сначала снапшот, fallback — 🧹.
  String get displayEmoji => emojiSnapshot ?? '🧹';

  static DateTime? _tsToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
