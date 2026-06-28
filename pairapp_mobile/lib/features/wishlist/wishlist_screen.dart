import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/data/wishlist_categories_data.dart';
import '../../shared/models/wishlist_item.dart';
import '../../shared/services/functions_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/services/wishlist_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _userService = UserService();
  final _wishlistService = WishlistService();

  String? _coupleId;
  String? _currentUserId;
  bool _loadingProfile = true;

  // Filters
  WishlistStatus? _statusFilter; // null = все
  String _categoryFilter = 'все';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (!mounted) return;
      setState(() {
        _coupleId = user?.currentCoupleId;
        _currentUserId = uid;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProfile = false);
    }
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<WishlistItem> _applyFilters(List<WishlistItem> all) {
    return all.where((item) {
      // Archived hidden by default unless explicitly selected.
      if (_statusFilter == null && item.isArchived) return false;
      if (_statusFilter != null && item.status != _statusFilter) return false;
      if (_categoryFilter != 'все' && item.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _markDone(WishlistItem item) async {
    try {
      await _wishlistService.updateWishlistItemStatus(item.id, 'done');
    } on FunctionsCallException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Не удалось обновить статус');
    }
  }

  Future<void> _markActive(WishlistItem item) async {
    try {
      await _wishlistService.updateWishlistItemStatus(item.id, 'active');
    } on FunctionsCallException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Не удалось обновить статус');
    }
  }

  Future<void> _archiveItem(WishlistItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Архивировать желание?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: Text(
          '«${item.title}» будет перемещено в архив.',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Архивировать',
                style: TextStyle(color: AppColors.roseAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _wishlistService.archiveWishlistItem(item.id);
    } on FunctionsCallException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Не удалось архивировать');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.bgCardLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  // ── Add bottom sheet ──────────────────────────────────────────────────────

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddWishlistItemSheet(
        onAdd: ({
          required String title,
          String? description,
          required String emoji,
          required String category,
          required String priority,
          required String budgetLevel,
        }) async {
          try {
            await _wishlistService.createWishlistItem(
              title: title,
              description: description,
              emoji: emoji,
              category: category,
              priority: priority,
              budgetLevel: budgetLevel,
            );
          } on FunctionsCallException catch (e) {
            _showError(e.message);
          } catch (_) {
            _showError('Не удалось добавить желание');
          }
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatusFilters(),
              _buildCategoryFilters(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Список желаний',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const Text(
                  'Мечты и планы на будущее',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _coupleId != null ? _openAddSheet : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text('Добавить',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final filters = <(WishlistStatus?, String)>[
      (null, 'Все'),
      (WishlistStatus.active, 'Активные'),
      (WishlistStatus.done, 'Выполненные'),
      (WishlistStatus.archived, 'Архив'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (status, label) = filters[i];
          final selected = _statusFilter == status;
          return GestureDetector(
            onTap: () => setState(() => _statusFilter = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.purple
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected ? AppColors.purple : AppColors.bgCardLight,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        itemCount: kWishlistCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final cat = kWishlistCategories[i];
          final selected = _categoryFilter == cat;
          return GestureDetector(
            onTap: () => setState(() => _categoryFilter = cat),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.pinkPurple.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.pinkPurple
                      : AppColors.bgCardLight,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? AppColors.pinkPurple
                      : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingProfile) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.purple));
    }

    final coupleId = _coupleId;
    if (coupleId == null || coupleId.isEmpty) {
      return _buildNoCouple();
    }

    return StreamBuilder<List<WishlistItem>>(
      stream: _wishlistService.watchWishlistItems(coupleId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.purple));
        }
        if (snap.hasError) {
          return _buildEmptyState(
            emoji: '⚠️',
            title: 'Ошибка загрузки',
            subtitle: 'Потяните вниз, чтобы обновить',
          );
        }
        final all = snap.data ?? [];
        final filtered = _applyFilters(all);
        if (filtered.isEmpty) {
          return _buildEmptyState(
            emoji: '💫',
            title: 'Список желаний пуст',
            subtitle: all.isEmpty
                ? 'Добавьте первое желание,\nкоторое хотите сделать вместе'
                : 'Нет желаний с выбранными фильтрами',
          );
        }
        return RefreshIndicator(
          onRefresh: _loadProfile,
          color: AppColors.purple,
          backgroundColor: AppColors.bgCard,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _WishlistItemCard(
              item: filtered[i],
              currentUserId: _currentUserId,
              onMarkDone: () => _markDone(filtered[i]),
              onMarkActive: () => _markActive(filtered[i]),
              onArchive: () => _archiveItem(filtered[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoCouple() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8A65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('💞', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Сначала создайте пару',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Список желаний появится, когда вы объединитесь с партнёром',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wishlist Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistItemCard extends StatelessWidget {
  const _WishlistItemCard({
    required this.item,
    required this.currentUserId,
    required this.onMarkDone,
    required this.onMarkActive,
    required this.onArchive,
  });

  final WishlistItem item;
  final String? currentUserId;
  final VoidCallback onMarkDone;
  final VoidCallback onMarkActive;
  final VoidCallback onArchive;

  Color get _statusColor {
    switch (item.status) {
      case WishlistStatus.active:
        return AppColors.purple;
      case WishlistStatus.done:
        return AppColors.statusResolved;
      case WishlistStatus.archived:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: item.isArchived
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Archive icon
              if (!item.isArchived)
                GestureDetector(
                  onTap: onArchive,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.archive_outlined,
                        size: 18, color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Chips row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(item.category, AppColors.purple.withValues(alpha: 0.15),
                  AppColors.lavender),
              _chip(item.priorityLabel,
                  _priorityColor().withValues(alpha: 0.15), _priorityColor()),
              _chip(item.budgetLabel,
                  AppColors.pinkPurple.withValues(alpha: 0.12),
                  AppColors.pinkPurple),
              _chip(
                item.statusLabel,
                _statusColor.withValues(alpha: 0.12),
                _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Footer
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                item.createdBy == currentUserId ? 'Вы' : 'Партнёр',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.access_time_rounded,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatDate(item.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
              const Spacer(),
              if (item.isActive)
                GestureDetector(
                  onTap: onMarkDone,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.statusResolved.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.statusResolved
                              .withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded,
                            size: 13,
                            color: AppColors.statusResolved),
                        SizedBox(width: 4),
                        Text(
                          'Выполнено',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.statusResolved,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (item.isDone)
                GestureDetector(
                  onTap: onMarkActive,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              AppColors.purple.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 13, color: AppColors.lavender),
                        SizedBox(width: 4),
                        Text(
                          'Вернуть',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.lavender,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: fg),
      ),
    );
  }

  Color _priorityColor() {
    switch (item.priority) {
      case WishlistPriority.high:
        return AppColors.roseAccent;
      case WishlistPriority.medium:
        return AppColors.statusDiscussion;
      case WishlistPriority.low:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Сегодня';
    if (diff.inDays == 1) return 'Вчера';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Wishlist Item Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

typedef _OnAddCallback = Future<void> Function({
  required String title,
  String? description,
  required String emoji,
  required String category,
  required String priority,
  required String budgetLevel,
});

class _AddWishlistItemSheet extends StatefulWidget {
  const _AddWishlistItemSheet({required this.onAdd});

  final _OnAddCallback onAdd;

  @override
  State<_AddWishlistItemSheet> createState() => _AddWishlistItemSheetState();
}

class _AddWishlistItemSheetState extends State<_AddWishlistItemSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _emojiController = TextEditingController(text: '✨');

  String _category = 'другое';
  String _priority = 'medium';
  String _budgetLevel = 'free';
  bool _submitting = false;
  bool _showTemplates = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _applyTemplate(WishlistTemplate t) {
    setState(() {
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _emojiController.text = t.emoji;
      _category = t.category;
      _showTemplates = false;
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название желания')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onAdd(
        title: title,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        emoji: _emojiController.text.trim().isEmpty
            ? '✨'
            : _emojiController.text.trim(),
        category: _category,
        priority: _priority,
        budgetLevel: _budgetLevel,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Новое желание',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(
                        () => _showTemplates = !_showTemplates),
                    child: Text(
                      _showTemplates ? 'Скрыть шаблоны' : 'Шаблоны',
                      style: const TextStyle(
                          color: AppColors.lavender, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // Templates
                  if (_showTemplates) ...[
                    const Text(
                      'Быстрый выбор',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kWishlistTemplates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final t = kWishlistTemplates[i];
                          return GestureDetector(
                            onTap: () => _applyTemplate(t),
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.bgCardLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        AppColors.purple.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.emoji,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Emoji + Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji picker (simple text field)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _emojiController,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          maxLength: 200,
                          maxLines: 2,
                          minLines: 1,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Название *',
                            labelStyle: const TextStyle(
                                color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.bgCardLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    maxLength: 2000,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Описание (необязательно)',
                      labelStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.bgCardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  const Text('Категория',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kWishlistCategoriesForCreate.map((cat) {
                      final sel = _category == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.purple.withValues(alpha: 0.2)
                                : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? AppColors.purple
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              color: sel
                                  ? AppColors.lavender
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  const Text('Приоритет',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _priorityChip('low', 'Низкий', AppColors.textSecondary),
                      const SizedBox(width: 8),
                      _priorityChip('medium', 'Средний',
                          AppColors.statusDiscussion),
                      const SizedBox(width: 8),
                      _priorityChip(
                          'high', 'Высокий', AppColors.roseAccent),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Budget
                  const Text('Бюджет',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      ('free', 'Бесплатно'),
                      ('low', 'Недорого'),
                      ('medium', 'Средне'),
                      ('high', 'Дорого'),
                    ].map(((String, String) b) {
                      final sel = _budgetLevel == b.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _budgetLevel = b.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.pinkPurple.withValues(alpha: 0.2)
                                : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? AppColors.pinkPurple
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            b.$2,
                            style: TextStyle(
                              fontSize: 13,
                              color: sel
                                  ? AppColors.pinkPurple
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.purple.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Добавить желание',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String value, String label, Color color) {
    final sel = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.2) : AppColors.bgCardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? color : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: sel ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
