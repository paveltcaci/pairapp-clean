import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chore_spin.dart';
import '../models/chore_task.dart';
import 'functions_service.dart';

/// Сервис для работы с бытовым рандомайзером.
/// Все write-операции идут через Cloud Functions (CF).
/// Read-операции — прямые Firestore-запросы.
class ChoreService {
  ChoreService({
    FirebaseFirestore? firestore,
    FunctionsService? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functions;

  // ── Tasks ─────────────────────────────────────────────────────────────────

  /// Стрим активных бытовых задач пары.
  /// Firestore-запрос только по `coupleId`, фильтрация `isActive` на клиенте.
  Stream<List<ChoreTask>> watchChoreTasks(String coupleId) {
    return _firestore
        .collection('chore_tasks')
        .where('coupleId', isEqualTo: coupleId)
        .snapshots()
        .map((snap) {
      final all = snap.docs.map((d) => ChoreTask.fromFirestore(d)).toList();
      // Фильтруем только активные, сортируем по дате создания (новые первые).
      final active = all.where((t) => t.isActive).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return active;
    });
  }

  /// Создаёт новую бытовую задачу через CF `createChoreTask`.
  Future<String> createChoreTask({
    required String title,
    String? description,
    String? emoji,
    String? category,
    String? intensity,
    int? estimatedMinutes,
  }) async {
    final result = await _functions.call('createChoreTask', {
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (emoji != null && emoji.isNotEmpty) 'emoji': emoji,
      if (category != null && category.isNotEmpty) 'category': category,
      if (intensity != null && intensity.isNotEmpty) 'intensity': intensity,
      if (estimatedMinutes != null) 'estimatedMinutes': estimatedMinutes,
    });
    return result['choreTaskId'] as String;
  }

  /// Мягко удаляет бытовую задачу через CF `softDeleteChoreTask`.
  Future<void> softDeleteChoreTask(String choreTaskId) async {
    await _functions.call('softDeleteChoreTask', {
      'choreTaskId': choreTaskId,
    });
  }

  // ── Spins ─────────────────────────────────────────────────────────────────

  /// Запускает рандомайзер для задачи через CF `spinChoreRandomizer`.
  /// Возвращает UID пользователя, которому выпала задача.
  Future<String> spinChoreRandomizer(String choreTaskId) async {
    final result = await _functions.call('spinChoreRandomizer', {
      'choreTaskId': choreTaskId,
    });
    return result['selectedUserId'] as String;
  }

  /// Стрим последних 20 результатов рандомайзера для пары.
  /// Запрос только по `coupleId`, сортировка на клиенте (не нужен composite index).
  Stream<List<ChoreSpin>> watchRecentSpins(String coupleId) {
    return _firestore
        .collection('chore_spins')
        .where('coupleId', isEqualTo: coupleId)
        .snapshots()
        .map((snap) {
      final all = snap.docs.map((d) => ChoreSpin.fromFirestore(d)).toList()
        ..sort((a, b) => b.spunAt.compareTo(a.spunAt));
      return all.take(20).toList();
    });
  }
}
