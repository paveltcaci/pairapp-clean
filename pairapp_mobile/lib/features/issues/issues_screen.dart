import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/models/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import 'screens/issue_chat_screen.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  int _filterIndex = 0;
  final List<String> _filters = ['Все', 'Мои', 'Партнёра', 'Открытые'];

  List<MockIssue> get _filteredIssues {
    return switch (_filterIndex) {
      1 => MockData.issues.where((i) => i.author == 'Павел').toList(),
      2 => MockData.issues.where((i) => i.author == 'Анна').toList(),
      3 => MockData.issues.where((i) => i.status == 'open').toList(),
      _ => MockData.issues,
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
              Expanded(
                child: _filteredIssues.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет проблем в этой категории',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: _filteredIssues.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _buildIssueCard(context, _filteredIssues[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
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
            child: const Icon(Icons.tune, color: AppColors.textSecondary, size: 18),
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
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.purpleGradient : null,
                color: selected ? null : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? null
                    : Border.all(color: AppColors.bgCardLight),
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
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, MockIssue issue) {
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IssueChatScreen(issue: issue),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: issue.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.description,
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
                  issue.author[0],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                issue.author,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  issue.category,
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
                  (i) => Icon(
                    Icons.circle,
                    size: 6,
                    color: i < issue.importance
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
}
