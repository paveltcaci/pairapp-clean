import 'package:flutter/material.dart';

import '../../shared/models/couple.dart';
import '../../shared/models/relationship_counter.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/relationship_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';

/// Экран «Настройки пары».
/// Получает начальный снимок [initialCouple] и подписывается на live-поток
/// через [CoupleService.watchCouple] для автоматического обновления после
/// вызовов Cloud Functions.
class CoupleSettingsScreen extends StatefulWidget {
  const CoupleSettingsScreen({
    super.key,
    required this.initialCouple,
    required this.currentUserId,
  });

  final Couple initialCouple;
  final String currentUserId;

  @override
  State<CoupleSettingsScreen> createState() => _CoupleSettingsScreenState();
}

class _CoupleSettingsScreenState extends State<CoupleSettingsScreen> {
  final _coupleService = CoupleService();
  final _relationshipService = RelationshipService();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Couple?>(
      stream: _coupleService.watchCouple(widget.initialCouple.id),
      initialData: widget.initialCouple,
      builder: (context, snapshot) {
        final couple = snapshot.data ?? widget.initialCouple;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildRelationshipSection(context, couple),
                          // Задел под будущие секции:
                          // const SizedBox(height: 20),
                          // _buildInviteCodeSection(context, couple),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Настройки пары',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    );
  }

  // ── Relationship date section ─────────────────────────────────────────────

  Widget _buildRelationshipSection(BuildContext context, Couple couple) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Дата начала отношений'),
        const SizedBox(height: 10),
        couple.relationshipStartDate == null
            ? _buildNoDateCard(context)
            : _buildDateCard(context, couple),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      ),
    );
  }

  // ── No date card ──────────────────────────────────────────────────────────

  Widget _buildNoDateCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.favorite_border,
                color: Colors.white, size: 26),
          ),
          const SizedBox(height: 14),
          const Text(
            'Дата не указана',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Укажите дату, чтобы видеть сколько\nвы вместе и отмечать годовщины',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            icon: Icons.calendar_today_outlined,
            label: 'Указать дату',
            onTap: () => _pickAndSetDate(context),
          ),
        ],
      ),
    );
  }

  // ── Date card (date is set) ───────────────────────────────────────────────

  Widget _buildDateCard(BuildContext context, Couple couple) {
    final startDate = couple.relationshipStartDate!;
    final breakdown = RelationshipBreakdown.compute(startDate);

    final bool selfIsA = couple.partnerAId == widget.currentUserId;
    final bool selfConfirmed = selfIsA
        ? couple.relationshipStartConfirmedByA
        : couple.relationshipStartConfirmedByB;
    final bool fullyConfirmed = couple.isDateFullyConfirmed;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date row ───────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.lavender),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Начало отношений',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(startDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.bgCardLight, height: 1),
          const SizedBox(height: 16),

          // ── Counter ────────────────────────────────────────────────────
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) =>
                    AppColors.purpleGradient.createShader(b),
                child: const Icon(Icons.favorite,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Мы вместе',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            breakdown.durationLabel,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Всего ${_pluralDays(breakdown.totalDays)} вместе',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // ── Anniversary chip ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined,
                    size: 15, color: AppColors.lavender),
                const SizedBox(width: 8),
                Text(
                  breakdown.daysUntilAnniversary == 0
                      ? 'Сегодня годовщина! 🎉'
                      : 'До годовщины: ${_pluralDays(breakdown.daysUntilAnniversary)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.lavender,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Confirmation status ────────────────────────────────────────
          if (!fullyConfirmed) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.bgCardLight, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ожидаем подтверждения партнёра',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            if (!selfConfirmed) ...[
              const SizedBox(height: 12),
              _buildPrimaryButton(
                icon: Icons.check_circle_outline,
                label: 'Подтвердить дату',
                onTap: () => _confirmDate(context),
              ),
            ],
          ],

          if (fullyConfirmed) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.bgCardLight, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 14, color: AppColors.statusResolved),
                const SizedBox(width: 8),
                const Text(
                  'Оба партнёра подтвердили дату',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.statusResolved,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          // ── Change date ────────────────────────────────────────────────
          const SizedBox(height: 16),
          _buildSecondaryButton(
            icon: Icons.edit_calendar_outlined,
            label: 'Изменить дату',
            onTap: () => _pickAndSetDate(context),
          ),
        ],
      ),
    );
  }

  // ── Reusable buttons ──────────────────────────────────────────────────────

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.lavender, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.lavender,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickAndSetDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1970),
      lastDate: now,
      helpText: 'Дата начала отношений',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.purple,
            onPrimary: Colors.white,
            surface: AppColors.bgCard,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: AppColors.bgSurface,
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    if (!context.mounted) return;

    try {
      await _relationshipService.updateStartDate(picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Дата сохранена ✓'),
            backgroundColor: AppColors.purple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${_friendlyError(e)}'),
            backgroundColor: AppColors.roseAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _confirmDate(BuildContext context) async {
    try {
      await _relationshipService.confirmStartDate();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Дата подтверждена ✓'),
            backgroundColor: AppColors.purple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${_friendlyError(e)}'),
            backgroundColor: AppColors.roseAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _formatDate(DateTime d) {
    const months = [
      '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  static String _pluralDays(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return '$n день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return '$n дня';
    }
    return '$n дней';
  }

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('failed-precondition')) {
      return 'Условие не выполнено';
    }
    if (msg.contains('unauthenticated')) return 'Необходима авторизация';
    if (msg.contains('not-found')) return 'Пара не найдена';
    return 'Попробуйте ещё раз';
  }
}