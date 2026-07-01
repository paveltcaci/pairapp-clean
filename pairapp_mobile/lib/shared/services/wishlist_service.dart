import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wishlist_item.dart';
import 'functions_service.dart';

/// Сервис для работы со списком желаний пары.
/// Все write-операции идут через Cloud Functions.
/// Read — прямые Firestore-запросы по coupleId (фильтрация на клиенте).
class WishlistService {
  WishlistService({
    FirebaseFirestore? firestore,
    FunctionsService? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FunctionsService();

  final FirebaseFirestore _firestore;
  final FunctionsService _functions;

  /// Стрим всех желаний пары (не фильтруем archived по умолчанию — UI сам фильтрует).
  /// Запрос только по `coupleId`, сортировка на клиенте.
  Stream<List<WishlistItem>> watchWishlistItems(String coupleId) {
    return _firestore
        .collection('wishlist_items')
        .where('coupleId', isEqualTo: coupleId)
        .snapshots()
        .map((snap) {
      final items =
          snap.docs.map((d) => WishlistItem.fromFirestore(d)).toList();

      // Сортировка: active → done → archived; внутри каждой группы — updatedAt desc.
      const order = {
        WishlistStatus.active: 0,
        WishlistStatus.done: 1,
        WishlistStatus.archived: 2,
      };
      items.sort((a, b) {
        final cmp = (order[a.status] ?? 0).compareTo(order[b.status] ?? 0);
        if (cmp != 0) return cmp;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return items;
    });
  }

  /// Создаёт новое желание через CF `createWishlistItem`.
  Future<String> createWishlistItem({
    required String title,
    String? description,
    String? emoji,
    String? category,
    String? priority,
    String? budgetLevel,
  }) async {
    final result = await _functions.call('createWishlistItem', {
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (emoji != null && emoji.isNotEmpty) 'emoji': emoji,
      if (category != null && category.isNotEmpty) 'category': category,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (budgetLevel != null && budgetLevel.isNotEmpty)
        'budgetLevel': budgetLevel,
    });
    return result['itemId'] as String;
  }

  /// Меняет статус желания через CF `updateWishlistItemStatus`.
  Future<void> updateWishlistItemStatus(String itemId, String status) async {
    await _functions.call('updateWishlistItemStatus', {
      'itemId': itemId,
      'status': status,
    });
  }

  /// Архивирует (soft-delete) желание через CF `deleteWishlistItem`.
  Future<void> archiveWishlistItem(String itemId) async {
    await _functions.call('deleteWishlistItem', {
      'itemId': itemId,
    });
  }
}
