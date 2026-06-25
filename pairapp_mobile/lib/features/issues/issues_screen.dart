import 'package:flutter/material.dart';

import '../../shared/models/issue.dart';
import '../../shared/services/issue_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/app_colors.dart';
import 'screens/issue_chat_screen.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final _userService = UserService();
  final _issueService = IssueService();

  int _filterIndex = 0;
  final List<String> _filters = const ['Все', 'Мои', 'Партнёра', 'Открытые'];

  bool _loadingProfile = true;
  String? _coupleId;
  String? _currentUid;
  String? _profileError;

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
        _currentUid = user?.id;
        _coupleId = user?.currentCoupleId;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _profileError = 'Не удалось загрузить профиль';
        _loadingProfile = false;
      });
    }
  }

  List<Issue> _applyFilter(List<Issue> issues) {
    return switch (_filterIndex) {
      1 => issues.where((issue) => issue.authorId == _currentUid).toList(),
      2 => issues.where((issue) => issue.authorId != _currentUid).toList(),
      3 => issues.where((issue) => issue.isOpen || issue.isReopened).toList(),
      _ => issues,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              _buildFilters(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingProfile) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (_profileError != null) {
      return _buildMessage(
        icon: Icons.error_outline,
        title: 'Ошибка',
        subtitle: _profileError!,
      );
    }

    final coupleId = _coupleId;
    if (coupleId == null || coupleId.isEmpty) {
      return _buildMessage(
        icon: Icons.people_outline,
        title: 'Сначала создайте пару',
        subtitle: 'Пригласите партнёра, чтобы начать обсуждение проблем',
      );
    }

    return StreamBuilder<List<Issue>>(
      stream: _issueService.watchCoupleIssues(coupleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.purple),
          );
        }

        if (snapshot.hasError) {
          return _buildMessage(
            icon: Icons.warning_amber_rounded,
            title: 'Что-то пошло не так',
            subtitle: 'Не удалось загрузить проблемы. Попробуйте позже.',
          );
        }

        final allIssues = snapshot.data ?? const <Issue>[];
        final issues = _applyFilter(allIssues);

        if (issues.isEmpty) {
          return _buildEmptyState(allIssues.isEmpty);
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: issues.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildIssueCard(
            context,
            issues[index],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Проблемы',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bgCardLight),
            ),
            child: const Icon(
              Icons.tune,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.purpleGradient : null,
                color: selected ? null : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: selected ? null : Border.all(color: AppColors.bgCardLight),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, Issue issue) {
    final isMyIssue = issue.authorId == _currentUid;
    final authorLabel = isMyIssue ? 'Я' : 'Партнёр';
    final avatarLetter = isMyIssue ? 'Я' : 'П';
    final statusForBadge = _statusForBadge(issue.status);

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IssueChatScreen(
            issueId: issue.id,
            title: issue.title,
            status: statusForBadge,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  issue.title.isEmpty ? 'Без названия' : issue.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: statusForBadge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.description?.isNotEmpty == true
                ? issue.description!
                : 'Описание не заполнено',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.purple.withValues(alpha: 0.2),
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                authorLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (issue.feelings.isNotEmpty) ...[
                Text(
                  _feelingLabel(issue.feelings.first),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _categoryLabel(issue.category),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.circle,
                    size: 6,
                    color: index < issue.importanceLevel
                        ? AppColors.purple
                        : AppColors.bgCardLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool trueEmpty) {
    return _buildMessage(
      icon: trueEmpty ? Icons.inbox_outlined : Icons.filter_list_off,
      title: trueEmpty ? 'Пока нет проблем' : 'Нет проблем в этой категории',
      subtitle: trueEmpty
          ? 'Создайте первую проблему, чтобы начать обсуждение'
          : 'Попробуйте выбрать другой фильтр',
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _statusForBadge(IssueStatus status) {
    return switch (status) {
      IssueStatus.open || IssueStatus.reopened => 'open',
      IssueStatus.inDiscussion ||
      IssueStatus.agreementProposed ||
      IssueStatus.agreed =>
        'discussion',
      IssueStatus.solved || IssueStatus.archived => 'resolved',
      IssueStatus.unknown => 'open',
    };
  }

  String _categoryLabel(String category) {
    return switch (category) {
      'communication' => 'Общение',
      'time_together' => 'Время',
      'household' => 'Быт',
      'money' => 'Финансы',
      'intimacy' => 'Близость',
      'jealousy' => 'Ревность',
      'future_plans' => 'Будущее',
      'other' => 'Другое',
      _ => category,
    };
  }

  String _feelingLabel(String feeling) {
    return switch (feeling) {
      'sadness' => 'Грустно',
      'anger' => 'Злюсь',
      'anxiety' => 'Тревожно',
      'loneliness' => 'Одиноко',
      'tiredness' => 'Усталость',
      'hurt' => 'Обидно',
      'confusion' => 'Смущение',
      'fear' => 'Страх',
      _ => feeling,
    };
  }
}
