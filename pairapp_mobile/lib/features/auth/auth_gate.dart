import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_shell.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/couple.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/user_service.dart';
import '../../theme/app_colors.dart';
import '../couple/couple_setup_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static final AuthService _authService = AuthService();
  static final UserService _userService = UserService();
  static final CoupleService _coupleService = CoupleService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      initialData: _authService.currentUser,
      stream: _authService.authStateChanges().cast<User?>(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting &&
            authSnap.data == null) {
          return const _LoadingScreen();
        }

        final user = authSnap.data;

        if (user == null) {
          return const LoginScreen();
        }

        // User is signed in — watch their Firestore profile
        return StreamBuilder<AppUser?>(
          stream: _userService.watchCurrentUserProfile(),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final appUser = profileSnap.data;

            // Auth trigger hasn't written the doc yet
            if (appUser == null) {
              return const _ProfileCreatingScreen();
            }

            // Profile exists but not completed → let user finish it
            if (!appUser.isProfileCompleted) {
              return const _CompleteProfileScreen();
            }

            // Profile complete, no couple yet → setup flow (create or join)
            if (!appUser.hasCouple) {
              return const CoupleSetupScreen();
            }

            // Has a coupleId — watch the couple document
            return StreamBuilder<Couple?>(
              stream: _coupleService.watchCouple(appUser.currentCoupleId!),
              builder: (context, coupleSnap) {
                if (coupleSnap.connectionState == ConnectionState.waiting) {
                  return const _LoadingScreen();
                }

                final couple = coupleSnap.data;

                // Document missing
                if (couple == null) {
                  return const _CoupleNotFoundScreen();
                }

                // Couple exists but not active (e.g. banned / deleted)
                if (!couple.isActive) {
                  return const _CoupleNotActiveScreen();
                }

                // Couple is active but partnerB hasn't joined yet →
                // show the waiting screen with the existing invite code.
                // This handles the "app restart after createCouple" case.
                if (!couple.hasBothPartners) {
                  return CoupleSetupScreen(
                    existingCoupleId: couple.id,
                    existingInviteCode: couple.inviteCode,
                  );
                }

                // Both partners present and couple active → main shell
                return const AppShell();
              },
            );
          },
        );
      },
    );
  }
}

// ── Internal placeholder screens ─────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
    );
  }
}

class _ProfileCreatingScreen extends StatelessWidget {
  const _ProfileCreatingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.purple),
            const SizedBox(height: 24),
            Text(
              'Профиль ещё создаётся…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteProfileScreen extends StatelessWidget {
  const _CompleteProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Профиль не завершён',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Нужно заполнить несколько полей, чтобы продолжить.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Завершить профиль'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoupleNotFoundScreen extends StatelessWidget {
  const _CoupleNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Пара не найдена',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Документ пары не существует. Обратись в поддержку.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoupleNotActiveScreen extends StatefulWidget {
  const _CoupleNotActiveScreen();

  @override
  State<_CoupleNotActiveScreen> createState() => _CoupleNotActiveScreenState();
}

class _CoupleNotActiveScreenState extends State<_CoupleNotActiveScreen> {
  final _coupleService = CoupleService();
  bool _isLoading = false;

  Future<void> _leaveCouple() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _coupleService.leaveCouple();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось выйти из пары. Попробуйте ещё раз.'),
          backgroundColor: AppColors.roseAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.link_off_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Пара не активна',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Эта пара больше не активна. Выйдите из пары, чтобы создать новую или подключиться по коду.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _leaveCouple,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Выйти из пары'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
