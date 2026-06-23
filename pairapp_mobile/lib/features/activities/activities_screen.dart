import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';
import '../randomizer/randomizer_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
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
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _buildActivityCards(context),
                const SizedBox(height: 28),
                _buildRecentIdeas(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCards(BuildContext context) {
    final cards = [
      _ActivityCard(
        icon: Icons.shuffle_rounded,
        title: 'Рандом занятие',
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
      _ActivityCard(
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
      _ActivityCard(
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
      _ActivityCard(
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
      children: cards
          .map((card) => _buildActivityCard(card))
          .toList(),
    );
  }

  Widget _buildActivityCard(_ActivityCard card) {
    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: card.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (card.gradient.colors.first).withValues(alpha: 0.3),
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

  Widget _buildRecentIdeas(BuildContext context) {
    final recentIdeas = [
      'Приготовить пиццу с нуля 🍕',
      'Посмотреть закат с горы 🌄',
      'Сыграть в монополию 🎲',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Недавние идеи',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...recentIdeas.map((idea) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lightbulb_outline,
                          color: AppColors.lavender, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        idea,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _ActivityCard {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}
