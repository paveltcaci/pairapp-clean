import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildHeartSection(),
                const SizedBox(height: 28),
                _buildStatsGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добрый вечер 🌙',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Анна & Павел',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 20),
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

  Widget _buildHeartSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow background
            Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.heartGlow,
              ),
            ),
            // Heart icon
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
        const Text(
          '2 года, 3 месяца и 14 дней ✨',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      _StatItem(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.statusOpen,
        label: 'Открытые\nпроблемы',
        value: '2',
      ),
      _StatItem(
        icon: Icons.handshake_outlined,
        iconColor: AppColors.lavender,
        label: 'Договорён-\nности',
        value: '4',
      ),
      _StatItem(
        icon: Icons.local_activity_outlined,
        iconColor: AppColors.pinkPurple,
        label: 'Активные\nактивности',
        value: '3',
      ),
      _StatItem(
        icon: Icons.chat_bubble_outline,
        iconColor: AppColors.roseAccent,
        label: 'Непрочитан-\nных',
        value: '5',
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
