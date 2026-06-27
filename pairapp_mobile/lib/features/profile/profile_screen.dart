import 'package:flutter/material.dart';

import '../../shared/models/app_user.dart';
import '../../shared/models/couple.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';
import 'couple_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _coupleService = CoupleService();
  final _authService = AuthService();

  Stream<_ProfileData?> _watchProfileData() {
    return _userService.watchCurrentUserProfile().asyncExpand((currentUser) {
      if (currentUser == null) {
        return Stream<_ProfileData?>.value(null);
      }

      final coupleId = currentUser.currentCoupleId;
      if (coupleId == null || coupleId.isEmpty) {
        return Stream<_ProfileData?>.value(
          _ProfileData(currentUser: currentUser, partner: null, couple: null),
        );
      }

      return _coupleService.watchCouple(coupleId).asyncMap((couple) async {
        if (couple == null) {
          return _ProfileData(currentUser: currentUser, partner: null, couple: null);
        }

        final partnerId = couple.partnerAId == currentUser.id
            ? couple.partnerBId
            : couple.partnerAId;

        AppUser? partner;
        if (partnerId != null && partnerId.isNotEmpty) {
          partner = await _userService.getUserProfile(partnerId);
        }

        return _ProfileData(currentUser: currentUser, partner: partner, couple: couple);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_ProfileData?>(
      stream: _watchProfileData(),
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

        final currentUser = snapshot.data?.currentUser;
        final partner = snapshot.data?.partner;
        final couple = snapshot.data?.couple;

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
                    _buildAvatar(context, currentUser, partner),
                    const SizedBox(height: 24),
                    _buildMenuItems(context, currentUser, couple),
                    const SizedBox(height: 20),
                    _buildLeaveCoupleButton(context),
                    const SizedBox(height: 12),
                    _buildAccountLogoutButton(context),
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

  static String _email(AppUser? user) {
    final email = user?.email?.trim();
    return email == null || email.isEmpty ? 'Email не указан' : email;
  }

  static String _avatarLetter(AppUser? user) {
    final name = _displayName(user, fallback: '?');
    return name.substring(0, 1).toUpperCase();
  }

  String _coupleLabel(AppUser? currentUser, AppUser? partner) {
    if (partner != null) {
      return 'Пара с ${_displayName(partner, fallback: 'партнёром')}';
    }
    if (currentUser?.currentCoupleId != null &&
        currentUser!.currentCoupleId!.isNotEmpty) {
      return 'Пара создана';
    }
    return 'Нет пары';
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

  Widget _buildAvatar(
      BuildContext context,
      AppUser? currentUser,
      AppUser? partner,
      ) {
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
              child: Center(
                child: Text(
                  _avatarLetter(currentUser),
                  style: const TextStyle(
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
          _displayName(currentUser, fallback: 'Пользователь'),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          _email(currentUser),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 12, color: AppColors.purple),
              const SizedBox(width: 6),
              Text(
                _coupleLabel(currentUser, partner),
                style: const TextStyle(
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

  Widget _buildMenuItems(BuildContext context, AppUser? currentUser, Couple? couple) {
    final language = currentUser?.language == 'en' ? 'English' : 'Русский';
    final items = [
      _MenuItem(
          icon: Icons.people_outline, label: 'Настройки пары', hasArrow: true),
      _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Уведомления',
          hasArrow: true),
      _MenuItem(icon: Icons.language_outlined, label: 'Язык', value: language),
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

          VoidCallback? tap;
          if (item.label == 'Настройки пары') {
            tap = () {
              if (couple == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Сначала создайте пару'),
                    backgroundColor: AppColors.bgCardLight,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoupleSettingsScreen(
                      initialCouple: couple,
                      currentUserId: currentUser!.id,
                    ),
                  ),
                );
              }
            };
          }
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
                onTap: tap ?? () {},
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

  Widget _buildLeaveCoupleButton(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.roseAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.roseAccent.withValues(alpha: 0.18)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.roseAccent, size: 18),
            SizedBox(width: 8),
            Text(
              'Выйти из пары — позже',
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

  Widget _buildAccountLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Выйти из аккаунта?',
                style: TextStyle(color: AppColors.textPrimary)),
            content: const Text(
              'Вы сможете снова войти по email и паролю.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _authService.signOut();
                },
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
          color: AppColors.bgCard.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.exit_to_app_outlined,
                color: AppColors.textSecondary, size: 18),
            SizedBox(width: 8),
            Text(
              'Выйти из аккаунта',
              style: TextStyle(
                color: AppColors.textSecondary,
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

class _ProfileData {
  const _ProfileData({
    required this.currentUser,
    required this.partner,
    required this.couple,
  });

  final AppUser currentUser;
  final AppUser? partner;
  final Couple? couple;
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