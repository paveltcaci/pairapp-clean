import 'package:cloud_firestore/cloud_firestore.dart';

/// Сохранённая идея из Firestore activity_history.
/// Парсит snapshot-документы source == "local_builtin".
/// Null-safe для старых записей acceptActivity (у них нет snapshot-полей).
class SavedActivity {
  const SavedActivity({
    required this.historyId,
    required this.coupleId,
    this.localIdeaId,
    this.title,
    this.description,
    this.emoji,
    this.categories = const [],
    this.budgetLevel,
    this.locationType,
    this.vibe,
    this.preparation,
    this.savedBy,
    this.savedAt,
    // ── legacy acceptActivity поля ──
    this.activityId,
    this.chosenBy,
    this.chosenAt,
    this.source,
  });

  final String historyId;
  final String coupleId;

  // ── Snapshot поля (local_builtin) ──
  final String? localIdeaId;
  final String? title;
  final String? description;
  final String? emoji;
  final List<String> categories;
  final String? budgetLevel;
  final String? locationType;
  final String? vibe;
  final String? preparation;
  final String? savedBy;
  final DateTime? savedAt;

  // ── Legacy acceptActivity поля ──
  final String? activityId;
  final String? chosenBy;
  final DateTime? chosenAt;
  final String? source;

  /// True если это snapshot локальной идеи (а не старая acceptActivity запись).
  bool get isLocalSnapshot => source == 'local_builtin' && localIdeaId != null;

  /// Отображаемое имя идеи (fallback для старых записей).
  String get displayTitle => title ?? 'Активность';

  /// Дата для отображения.
  DateTime? get displayDate => savedAt ?? chosenAt;

  factory SavedActivity.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SavedActivity(
      historyId: doc.id,
      coupleId: (d['coupleId'] as String?) ?? '',
      localIdeaId: d['localIdeaId'] as String?,
      title: d['title'] as String?,
      description: d['description'] as String?,
      emoji: d['emoji'] as String?,
      categories: _parseStringList(d['categories']),
      budgetLevel: d['budgetLevel'] as String?,
      locationType: d['locationType'] as String?,
      vibe: d['vibe'] as String?,
      preparation: d['preparation'] as String?,
      savedBy: d['savedBy'] as String?,
      savedAt: _tsToDateTime(d['savedAt']),
      activityId: d['activityId'] as String?,
      chosenBy: d['chosenBy'] as String?,
      chosenAt: _tsToDateTime(d['chosenAt']),
      source: d['source'] as String?,
    );
  }

  static DateTime? _tsToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }
}
