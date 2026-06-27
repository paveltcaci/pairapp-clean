import 'package:flutter/material.dart';

import '../create_issue/create_issue_screen.dart';
import '../../shared/models/agreement.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/checkin.dart';
import '../../shared/models/couple.dart';
import '../../shared/models/issue.dart';
import '../../shared/models/relationship_counter.dart';
import '../../shared/services/agreement_service.dart';
import '../../shared/services/checkin_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/issue_service.dart';
import '../../shared/services/relationship_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService();
  final _coupleService = CoupleService();
  final _issueService = IssueService();
  final _agreementService = AgreementService();
  final _checkinService = CheckinService();
  final _relationshipService = RelationshipService();

  Stream<_HomeData?> _watchHomeData() {
    return _userService.watchCurrentUserProfile().asyncExpand((currentUser) {
      if (currentUser == null) {
        return Stream<_HomeData?>.value(null);
      }

      final coupleId = currentUser.currentCoupleId;
      if (coupleId == null || coupleId.isEmpty) {
        return Stream<_HomeData?>.value(
          _HomeData(currentUser: currentUser, couple: null, partner: null),
        );
      }

      return _coupleService.watchCouple(coupleId).asyncMap((couple) async {
        if (couple == null) {
          return _HomeData(
            currentUser: currentUser,
            couple: null,
            partner: null,
          );
        }

        final partnerId = couple.partnerAId == currentUser.id
            ? couple.partnerBId
            : couple.partnerAId;

        AppUser? partner;
        if (partnerId != null && partnerId.isNotEmpty) {
          partner = await _userService.getUserProfile(partnerId);
        }

        return _HomeData(
          currentUser: currentUser,
          couple: couple,
          partner: partner,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_HomeData?>(
      stream: _watchHomeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.bgGradient),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.purple),
              ),
            ),
          );
        }

        final data = snapshot.data;
        final currentUser = data?.currentUser;
        final partner = data?.partner;

        final currentName = _displayName(currentUser, fallback: 'Вы');
        final partnerName = _displayName(partner, fallback: 'Партнёр');
        final title = partner != null
            ? '$currentName & $partnerName'
            : currentUser != null
            ? currentName
            : 'PairApp';

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(context, title),
                    const SizedBox(height: 32),
                    _buildHeartSection(partner != null),
                    const SizedBox(height: 16),
                    _buildRelationshipCounter(context, data),
                    const SizedBox(height: 20),
                    _buildDashboardSection(context, data),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _displayName(AppUser? user, {required String fallback}) {
    final name = user?.displayName?.trim();
    return name == null || name.isEmpty ? fallback : name;
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Добрый вечер 🌙',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.roseAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDeep, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeartSection(bool hasPartner) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.heartGlow,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.purpleGradient.createShader(bounds),
              child: const Icon(
                Icons.favorite,
                size: 96,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Мы вместе',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasPartner ? 'Пара подключена ✨' : 'Ожидаем партнёра ✨',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Relationship Counter ──────────────────────────────────────────────────

  Widget _buildRelationshipCounter(BuildContext context, _HomeData? data) {
    final couple = data?.couple;
    final currentUser = data?.currentUser;

    // No couple yet — nothing to show.
    if (couple == null) return const SizedBox.shrink();

    final startDate = couple.relationshipStartDate;

    // No date set → CTA card.
    if (startDate == null) {
      return _buildRelationshipCta(context);
    }

    // Date set → show counter.
    final breakdown = RelationshipBreakdown.compute(startDate);

    // Determine confirmation status for the current user.
    final bool selfIsA = couple.partnerAId == currentUser?.id;
    final bool selfConfirmed =
    selfIsA ? couple.relationshipStartConfirmedByA : couple.relationshipStartConfirmedByB;
    final bool fullyConfirmed = couple.isDateFullyConfirmed;

    return _buildRelationshipCard(
      context,
      breakdown: breakdown,
      fullyConfirmed: fullyConfirmed,
      selfConfirmed: selfConfirmed,
    );
  }

  /// CTA shown when no date has been set yet.
  Widget _buildRelationshipCta(BuildContext context) {
    return AppCard(
      onTap: () => _pickAndSetDate(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_border,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Укажите дату начала отношений',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Мы посчитаем, сколько вы вместе ♥',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  /// Counter card shown when a date is set.
  Widget _buildRelationshipCard(
      BuildContext context, {
        required RelationshipBreakdown breakdown,
        required bool fullyConfirmed,
        required bool selfConfirmed,
      }) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) =>
                    AppColors.purpleGradient.createShader(b),
                child: const Icon(Icons.favorite,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Мы вместе',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              // Edit date button
              GestureDetector(
                onTap: () => _pickAndSetDate(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Изменить',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.lavender,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Main counter
          Text(
            breakdown.durationLabel,
            style: const TextStyle(
              fontSize: 26,
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
          // Anniversary row
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined,
                    size: 14, color: AppColors.lavender),
                const SizedBox(width: 8),
                Text(
                  breakdown.daysUntilAnniversary == 0
                      ? 'Сегодня годовщина! 🎉'
                      : 'До годовщины: ${_pluralDays(breakdown.daysUntilAnniversary)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lavender,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Confirmation status
          if (!fullyConfirmed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Ожидаем подтверждения партнёра',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (!selfConfirmed)
                  GestureDetector(
                    onTap: () => _confirmDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Подтвердить',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
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

  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('failed-precondition')) {
      return 'Дата не установлена или условие не выполнено';
    }
    if (msg.contains('unauthenticated')) return 'Необходима авторизация';
    if (msg.contains('not-found')) return 'Пара не найдена';
    return 'Попробуйте ещё раз';
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

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Widget _buildDashboardSection(BuildContext context, _HomeData? data) {
    final coupleId = data?.couple?.id;
    if (coupleId == null || coupleId.isEmpty) {
      return Column(
        children: [
          _buildStatsGridFromData(context, _DashboardStats.empty()),
          const SizedBox(height: 16),
          _buildCreateIssueButton(context),
        ],
      );
    }

    return StreamBuilder<List<Issue>>(
      stream: _issueService.watchCoupleIssues(coupleId),
      builder: (context, issuesSnapshot) {
        return StreamBuilder<List<Agreement>>(
          stream: _agreementService.watchCoupleAgreements(coupleId),
          builder: (context, agreementsSnapshot) {
            return StreamBuilder<List<Checkin>>(
              stream: _checkinService.watchCoupleCheckins(coupleId),
              builder: (context, checkinsSnapshot) {
                final isLoading =
                    issuesSnapshot.connectionState == ConnectionState.waiting &&
                        !issuesSnapshot.hasData;

                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.purple,
                      ),
                    ),
                  );
                }

                final hasError = issuesSnapshot.hasError ||
                    agreementsSnapshot.hasError ||
                    checkinsSnapshot.hasError;
                final stats = _DashboardStats.fromData(
                  issues: issuesSnapshot.data ?? const <Issue>[],
                  agreements:
                  agreementsSnapshot.data ?? const <Agreement>[],
                  checkins: checkinsSnapshot.data ?? const <Checkin>[],
                );

                return Column(
                  children: [
                    if (hasError) ...[
                      _buildStatsError(),
                      const SizedBox(height: 12),
                    ],
                    _buildStatsGridFromData(context, stats),
                    const SizedBox(height: 16),
                    _buildCreateIssueButton(context),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatsGridFromData(
      BuildContext context,
      _DashboardStats dashboardStats,
      ) {
    final stats = [
      _StatItem(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.statusOpen,
        label: 'Открытые\nпроблемы',
        value: dashboardStats.openIssues.toString(),
      ),
      _StatItem(
        icon: Icons.handshake_outlined,
        iconColor: AppColors.lavender,
        label: 'Активные\nдоговорённости',
        value: dashboardStats.activeAgreements.toString(),
      ),
      _StatItem(
        icon: Icons.fact_check_outlined,
        iconColor: AppColors.pinkPurple,
        label: 'Check-in\nждут',
        value: dashboardStats.pendingCheckins.toString(),
      ),
      _StatItem(
        icon: Icons.check_circle_outline,
        iconColor: AppColors.statusResolved,
        label: 'Решённые\nпроблемы',
        value: dashboardStats.resolvedIssues.toString(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: stats.map((s) => _buildStatCard(context, s)).toList(),
    );
  }

  Widget _buildCreateIssueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateIssueScreen()),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Создать проблему',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsError() {
    return AppCard(
      color: AppColors.bgCardLight,
      padding: const EdgeInsets.all(14),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.statusDiscussion),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Часть данных дашборда не загрузилась.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsGridFallback(BuildContext context) {
    final stats = [
      _StatItem(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.statusOpen,
        label: 'Открытые\nпроблемы',
        value: _DashboardStats.empty().openIssues.toString(),
      ),
      _StatItem(
        icon: Icons.handshake_outlined,
        iconColor: AppColors.lavender,
        label: 'Договорён-\nности',
        value: _DashboardStats.empty().activeAgreements.toString(),
      ),
      _StatItem(
        icon: Icons.local_activity_outlined,
        iconColor: AppColors.pinkPurple,
        label: 'Активные\nактивности',
        value: _DashboardStats.empty().pendingCheckins.toString(),
      ),
      _StatItem(
        icon: Icons.chat_bubble_outline,
        iconColor: AppColors.roseAccent,
        label: 'Непрочитан-\nных',
        value: _DashboardStats.empty().resolvedIssues.toString(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: stats.map((s) => _buildStatCard(context, s)).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, _StatItem item) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.currentUser,
    required this.couple,
    required this.partner,
  });

  final AppUser currentUser;
  final Couple? couple;
  final AppUser? partner;
}

class _DashboardStats {
  const _DashboardStats({
    required this.openIssues,
    required this.activeAgreements,
    required this.pendingCheckins,
    required this.resolvedIssues,
  });

  final int openIssues;
  final int activeAgreements;
  final int pendingCheckins;
  final int resolvedIssues;

  factory _DashboardStats.empty() {
    return const _DashboardStats(
      openIssues: 0,
      activeAgreements: 0,
      pendingCheckins: 0,
      resolvedIssues: 0,
    );
  }

  factory _DashboardStats.fromData({
    required List<Issue> issues,
    required List<Agreement> agreements,
    required List<Checkin> checkins,
  }) {
    final activeAgreementIds = agreements
        .where((agreement) => agreement.isActive || agreement.isAccepted)
        .map((agreement) => agreement.id)
        .toSet();

    return _DashboardStats(
      // "Открытые" = проблемы без активного agreement и без решения.
      // agreed / solved / archived — не считаются открытыми.
      openIssues: issues
          .where(
            (issue) =>
        issue.isOpen ||
            issue.isInDiscussion ||
            issue.isAgreementProposed ||
            issue.isReopened,
      )
          .length,
      activeAgreements: activeAgreementIds.length,
      pendingCheckins: checkins
          .where(
            (checkin) =>
        checkin.isOpen &&
            activeAgreementIds.contains(checkin.agreementId),
      )
          .length,
      resolvedIssues:
      issues.where((issue) => issue.isSolved || issue.isArchived).length,
    );
  }
}

class _StatItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}