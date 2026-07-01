import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/activity_ideas_data.dart';
import '../models/activity_idea.dart';
import '../models/saved_activity.dart';
import 'functions_service.dart';

/// Результат попытки сохранить идею.
enum SaveIdeaResult {
  /// Идея успешно сохранена.
  saved,

  /// Идея уже была сохранена ранее.
  alreadySaved,

  /// Ошибка (сеть, CF и т.п.).
  error,
}

/// Сервис для работы с builtin activity ideas и saved activities.
class ActivityService {
  ActivityService({
    FirebaseFirestore? firestore,
    FunctionsService? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functions;

  // ── Локальные идеи ────────────────────────────────────────────────────────

  /// Возвращает случайную идею. Если передан [category] — фильтрует по нему.
  /// [excludeId] предотвращает повтор последней показанной идеи.
  ActivityIdea randomIdea({String? category, String? excludeId}) {
    var pool = kBuiltinActivityIdeas;

    if (category != null && category.isNotEmpty) {
      pool = pool.where((e) => e.categories.contains(category)).toList();
    }

    if (pool.isEmpty) pool = kBuiltinActivityIdeas;

    // Убираем последнюю показанную идею, если в пуле больше одной.
    final filtered =
        pool.length > 1 ? pool.where((e) => e.id != excludeId).toList() : pool;

    final idx = Random().nextInt(filtered.length);
    return filtered[idx];
  }

  /// Список всех категорий.
  List<String> get allCategories => kActivityCategories;

  // ── Cloud Functions ────────────────────────────────────────────────────────

  /// Сохраняет идею для текущей пары через CF `saveActivityIdeaSnapshot`.
  /// Не делает прямого write в Firestore.
  Future<SaveIdeaResult> saveIdea(ActivityIdea idea) async {
    try {
      final result = await _functions.call(
        'saveActivityIdeaSnapshot',
        idea.toSavePayload(),
      );
      if (result['alreadySaved'] == true) {
        return SaveIdeaResult.alreadySaved;
      }
      return SaveIdeaResult.saved;
    } catch (_) {
      return SaveIdeaResult.error;
    }
  }

  /// Удаляет сохранённую идею через CF `removeSavedActivityIdea`.
  Future<bool> removeSaved(String historyId) async {
    try {
      await _functions.call(
        'removeSavedActivityIdea',
        {'historyId': historyId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Firestore stream ───────────────────────────────────────────────────────

  /// Стрим сохранённых идей пары из `activity_history`.
  ///
  /// Query только по coupleId (без нового индекса).
  /// Фильтрация source == "local_builtin" выполняется на клиенте.
  Stream<List<SavedActivity>> watchSavedIdeas(String coupleId) {
    return _firestore
        .collection('activity_history')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map(SavedActivity.fromFirestore)
            .where((a) => a.isLocalSnapshot)
            .toList());
  }
}
