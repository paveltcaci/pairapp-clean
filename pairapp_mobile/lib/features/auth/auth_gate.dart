import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_shell.dart';
import '../../shared/models/app_user.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_service.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static final AuthService _authService = AuthService();
  static final UserService _userService = UserService();

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

            // Profile complete, no couple yet
            if (!appUser.hasCouple) {
              return const _WaitingForCoupleScreen();
            }

            // All good — show the main shell
            return const AppShell();
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
      body: Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      ),
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

class _WaitingForCoupleScreen extends StatelessWidget {
  const _WaitingForCoupleScreen();

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
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Почти готово!',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Создание пары будет следующим шагом.',
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
