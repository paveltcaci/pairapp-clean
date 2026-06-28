import 'package:flutter/material.dart';

import '../../shared/models/saved_activity.dart';
import '../../shared/services/activity_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';
import '../randomizer/randomizer_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _userService = UserService();
  final _activityService = ActivityService();

  String? _coupleId;
  bool _loadingProfile = true;
  final Set<String> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      if (!mounted) return;
      setState(() {
        _coupleId = user?.currentCoupleId;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _removeIdea(String historyId) async {
    setState(() => _removingIds.add(historyId));
    final ok = await _activityService.removeSaved(historyId);
    if (!mounted) return;
    setState(() => _removingIds.remove(historyId));
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Не удалось удалить. Попробуйте ещё раз'),
          backgroundColor: AppColors.bgCardLight,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadProfile,
            color: AppColors.purple,
            backgroundColor: AppColors.bgCard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Активности',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Что бы вы хотели сделать вместе?',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildActivityCards(context),
                  const SizedBox(height: 28),
                  _buildSavedIdeasSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCards(BuildContext context) {
    final cards = [
      _ActivityCardData(
        icon: Icons.shuffle_rounded,
        title: 'Идеи для нас',
        subtitle: 'Случайная идея для вас двоих',
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFC), Color(0xFF9D7FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RandomizerScreen()),
        ),
      ),
      _ActivityCardData(
        icon: Icons.home_outlined,
        title: 'Бытовой рандомайзер',
        subtitle: 'Кто что делает сегодня дома',
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {},
      ),
      _ActivityCardData(
        icon: Icons.quiz_outlined,
        title: 'Квизы для пары',
        subtitle: 'Насколько вы знаете друг друга?',
        gradient: const LinearGradient(
          colors: [Color(0xFFD46FFF), Color(0xFFE040FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {},
      ),
      _ActivityCardData(
        icon: Icons.favorite_border_rounded,
        title: 'Список желаний',
        subtitle: 'Мечты и планы на будущее',
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {},
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: cards.map(_buildActivityCard).toList(),
    );
  }

  Widget _buildActivityCard(_ActivityCardData card) {
    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: card.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: card.gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(card.icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Saved Ideas Section ───────────────────────────────────────────────────

  Widget _buildSavedIdeasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Сохранённые идеи',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            const Text('❤️', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        _buildSavedIdeasBody(),
      ],
    );
  }

  Widget _buildSavedIdeasBody() {
    if (_loadingProfile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: AppColors.purple),
        ),
      );
    }

    final coupleId = _coupleId;
    if (coupleId == null || coupleId.isEmpty) {
      return _buildEmptyState(
        emoji: '👫',
        title: 'Создайте пару',
        subtitle: 'Сохранённые идеи появятся, когда вы пригласите партнёра',
      );
    }

    return StreamBuilder<List<SavedActivity>>(
      stream: _activityService.watchSavedIdeas(coupleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: AppColors.purple),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            emoji: '⚠️',
            title: 'Ошибка загрузки',
            subtitle: 'Потяните вниз, чтобы обновить',
          );
        }

        final ideas = snapshot.data ?? [];
        if (ideas.isEmpty) {
          return _buildEmptyState(
            emoji: '💡',
            title: 'Пока нет сохранённых идей',
            subtitle:
                'Откройте «Идеи для нас» и сохраните что-нибудь понравившееся',
          );
        }

        return Column(
          children: ideas
              .map((saved) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSavedIdeaCard(saved),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildSavedIdeaCard(SavedActivity saved) {
    final isRemoving = _removingIds.contains(saved.historyId);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                saved.emoji ?? '💡',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saved.displayTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (saved.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    saved.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (saved.categories.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: saved.categories
                        .take(2)
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.lavender,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                if (saved.displayDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(saved.displayDate!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          if (isRemoving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textMuted,
              ),
            )
          else
            GestureDetector(
              onTap: () => _confirmRemove(saved),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmRemove(SavedActivity saved) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Удалить идею?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: Text(
          '"${saved.displayTitle}" будет удалена из сохранённых для вашей пары.',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeIdea(saved.historyId);
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: AppColors.roseAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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

class _ActivityCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActivityCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}
