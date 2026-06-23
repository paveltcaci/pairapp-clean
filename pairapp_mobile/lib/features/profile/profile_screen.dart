import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(context),
                const SizedBox(height: 28),
                _buildAvatar(context),
                const SizedBox(height: 24),
                _buildMenuItems(context),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
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
        Text('Профиль', style: Theme.of(context).textTheme.displayMedium),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgCardLight),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Изменить',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'П',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgCard, width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  size: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Павел',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        const Text(
          'pavel@example.com',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 12, color: AppColors.purple),
              SizedBox(width: 6),
              Text(
                'Пара с Анной',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.purple,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final items = [
      _MenuItem(
          icon: Icons.people_outline, label: 'Настройки пары', hasArrow: true),
      _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Уведомления',
          hasArrow: true),
      _MenuItem(
          icon: Icons.language_outlined, label: 'Язык', value: 'Русский'),
      _MenuItem(
          icon: Icons.help_outline, label: 'Поддержка', hasArrow: true),
      _MenuItem(
          icon: Icons.info_outline, label: 'О приложении', value: 'v1.0.0'),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon,
                      color: AppColors.lavender, size: 18),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: item.hasArrow
                    ? const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.textMuted)
                    : item.value != null
                        ? Text(
                            item.value!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted),
                          )
                        : null,
                onTap: () {},
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1, indent: 68, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Выйти из пары?',
                style: TextStyle(color: AppColors.textPrimary)),
            content: const Text(
              'Вы уверены? Это действие нельзя отменить.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Выйти',
                    style: TextStyle(color: AppColors.roseAccent)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.roseAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.roseAccent.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.roseAccent, size: 18),
            SizedBox(width: 8),
            Text(
              'Выйти из пары',
              style: TextStyle(
                color: AppColors.roseAccent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? value;
  final bool hasArrow;

  _MenuItem({
    required this.icon,
    required this.label,
    this.value,
    this.hasArrow = false,
  });
}
