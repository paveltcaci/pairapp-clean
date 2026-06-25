import 'package:flutter/material.dart';

import '../create_issue/create_issue_screen.dart';
import '../../shared/models/agreement.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/checkin.dart';
import '../../shared/models/couple.dart';
import '../../shared/models/issue.dart';
import '../../shared/services/agreement_service.dart';
import '../../shared/services/checkin_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/issue_service.dart';
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
                    const SizedBox(height: 28),
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