import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/models/couple.dart';
import '../../shared/services/couple_service.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/gradient_button.dart';

class CoupleSetupScreen extends StatefulWidget {
  const CoupleSetupScreen({
    super.key,
    this.existingCoupleId,
    this.existingInviteCode,
  });

  /// Set when the user already has a couple (e.g. app restarted after
  /// createCouple but before partnerB joined).
  final String? existingCoupleId;
  final String? existingInviteCode;

  @override
  State<CoupleSetupScreen> createState() => _CoupleSetupScreenState();
}

class _CoupleSetupScreenState extends State<CoupleSetupScreen> {
  final CoupleService _coupleService = CoupleService();
  final TextEditingController _codeController = TextEditingController();

  bool _creating = false;
  bool _joining = false;
  String? _error;

  String? _createdCoupleId;
  String? _inviteCode;
  Stream<Couple?>? _coupleStream;

  @override
  void initState() {
    super.initState();
    // If the user already has a couple (returned here after app restart),
    // jump straight into the "waiting for partner" view.
    if (widget.existingCoupleId != null) {
      _createdCoupleId = widget.existingCoupleId;
      _inviteCode = widget.existingInviteCode;
      _coupleStream = _coupleService.watchCouple(widget.existingCoupleId!);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _createCouple() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final result = await _coupleService.createCouple();
      setState(() {
        _createdCoupleId = result.coupleId;
        _inviteCode = result.inviteCode;
        _coupleStream = _coupleService.watchCouple(result.coupleId);
      });
    } catch (e) {
      setState(() => _error = 'Не удалось создать пару. Попробуй снова.');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _joinCouple() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Введи код приглашения.');
      return;
    }
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      await _coupleService.joinCoupleByInviteCode(code);
      // AuthGate reacts to the updated userProfile (hasCouple=true,
      // couple.hasBothPartners=true) and navigates to AppShell automatically.
    } catch (e) {
      setState(() => _error = 'Неверный код или пара уже занята.');
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  void _copyCode() {
    if (_inviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _inviteCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Код скопирован'),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // If a couple was created (either now or on a previous session),
    // show the "waiting for partner" view.
    if (_createdCoupleId != null && _coupleStream != null) {
      return _WaitingForPartnerScreen(
        inviteCode: _inviteCode ?? '',
        coupleStream: _coupleStream!,
        onCopyCode: _copyCode,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const _Header(),
                const SizedBox(height: 40),

                // Error banner
                if (_error != null) ...[
                  _ErrorBanner(message: _error!),
                  const SizedBox(height: 20),
                ],

                // ── Create couple ──────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.purpleGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Создать пару',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ты — первый. Партнёр присоединится по коду.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _creating
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.purple,
                              ),
                            )
                          : GradientButton(
                              label: 'Создать пару',
                              icon: Icons.add_rounded,
                              width: double.infinity,
                              onTap: _createCouple,
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppColors.bgCardLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'или',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const Expanded(
                        child: Divider(color: AppColors.bgCardLight)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Join couple ────────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.bgCardLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.link_rounded,
                              color: AppColors.lavender,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Подключиться по коду',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Введи код, который прислал партнёр.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: 'XXXXXX',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          filled: true,
                          fillColor: AppColors.bgDeep,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.bgCardLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.bgCardLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.purple,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _joining
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.purple,
                              ),
                            )
                          : GradientButton(
                              label: 'Подключиться',
                              icon: Icons.arrow_forward_rounded,
                              width: double.infinity,
                              onTap: _joinCouple,
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Создай свою пару',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Пригласи партнёра или присоединись по коду.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.roseAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.roseAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.roseAccent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.roseAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Waiting for partner (after createCouple) ──────────────────────────────────

class _WaitingForPartnerScreen extends StatelessWidget {
  const _WaitingForPartnerScreen({
    required this.inviteCode,
    required this.coupleStream,
    required this.onCopyCode,
  });

  final String inviteCode;
  final Stream<Couple?> coupleStream;
  final VoidCallback onCopyCode;

  @override
  Widget build(BuildContext context) {
    // We just listen to keep the stream alive. The actual navigation is driven
    // by AuthGate watching appUser.currentCoupleId + couple.hasBothPartners.
    return StreamBuilder<Couple?>(
      stream: coupleStream,
      builder: (context, snap) {
        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Пара создана!',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Передай этот код партнёру',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Invite code card
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Column(
                        children: [
                          Text(
                            inviteCode,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: onCopyCode,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.copy_rounded,
                                  color: AppColors.lavender,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Скопировать код',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.lavender),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.purple,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Ожидаем, пока партнёр присоединится…',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
