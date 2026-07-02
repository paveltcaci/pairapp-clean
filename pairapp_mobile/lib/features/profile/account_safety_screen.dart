import 'package:flutter/material.dart';

import '../../shared/services/auth_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/functions_service.dart';
import '../../shared/services/safety_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';

class AccountSafetyScreen extends StatefulWidget {
  const AccountSafetyScreen({super.key});

  @override
  State<AccountSafetyScreen> createState() => _AccountSafetyScreenState();
}

class _AccountSafetyScreenState extends State<AccountSafetyScreen> {
  final _authService = AuthService();
  final _coupleService = CoupleService();
  final _safetyService = SafetyService();

  String? _busyAction;

  static const _deleteConfirmation = 'УДАЛИТЬ';
  static const _reportReasons = [
    'Оскорбления',
    'Угрозы',
    'Спам',
    'Неприемлемое поведение',
    'Другое',
  ];

  bool get _isBusy => _busyAction != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Пара'),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.logout_rounded,
                        title: 'Выйти из пары',
                        subtitle: 'Пара будет завершена, история останется',
                        accentColor: AppColors.roseAccent,
                        isLoading: _busyAction == 'leaveCouple',
                        onTap: _isBusy ? null : _confirmLeaveCouple,
                      ),
                      const SizedBox(height: 22),
                      _buildSectionLabel('Безопасность'),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.report_outlined,
                        title: 'Пожаловаться',
                        accentColor: AppColors.lavender,
                        isLoading: _busyAction == 'createReport',
                        onTap: _isBusy ? null : _openReportDialog,
                      ),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.block_rounded,
                        title: 'Заблокировать партнёра',
                        accentColor: AppColors.roseAccent,
                        isLoading: _busyAction == 'blockUser',
                        onTap: _isBusy ? null : _confirmBlockUser,
                      ),
                      const SizedBox(height: 22),
                      _buildSectionLabel('Аккаунт'),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.delete_outline_rounded,
                        title: 'Удалить аккаунт',
                        accentColor: AppColors.roseAccent,
                        danger: true,
                        isLoading: _busyAction == 'deleteAccount',
                        onTap: _isBusy ? null : _openDeleteAccountDialog,
                      ),
                      const SizedBox(height: 22),
                      _buildSectionLabel('Документы'),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Политика конфиденциальности',
                        accentColor: AppColors.lavender,
                        onTap: () => _showDocumentPlaceholder(
                          'Политика конфиденциальности',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.description_outlined,
                        title: 'Условия использования',
                        accentColor: AppColors.lavender,
                        onTap: () =>
                            _showDocumentPlaceholder('Условия использования'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
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
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: _isBusy ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Аккаунт и безопасность',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }

  Future<void> _confirmLeaveCouple() async {
    final confirmed = await _showConfirmDialog(
      title: 'Выйти из пары?',
      text:
          'Вы сможете создать новую пару позже. История текущей пары останется.',
      confirmLabel: 'Выйти',
      confirmColor: AppColors.roseAccent,
    );
    if (confirmed != true) return;

    await _runAction(
      key: 'leaveCouple',
      action: _coupleService.leaveCouple,
      successMessage: 'Вы вышли из пары',
    );
  }

  Future<void> _openReportDialog() async {
    final report = await _showReportDialog();
    if (report == null) return;

    await _runAction(
      key: 'createReport',
      action: () => _safetyService.createReport(
        reason: report.reason,
        description: report.description,
      ),
      successMessage: 'Жалоба отправлена',
    );
  }

  Future<void> _confirmBlockUser() async {
    final confirmed = await _showConfirmDialog(
      title: 'Заблокировать партнёра?',
      text:
          'Пара будет заблокирована. Вы больше не сможете продолжать взаимодействие в этой паре.',
      confirmLabel: 'Заблокировать',
      confirmColor: AppColors.roseAccent,
    );
    if (confirmed != true) return;

    await _runAction(
      key: 'blockUser',
      action: _safetyService.blockUser,
      successMessage: 'Партнёр заблокирован',
    );
  }

  Future<void> _openDeleteAccountDialog() async {
    final confirmed = await _showDeleteAccountDialog();
    if (confirmed != true) return;

    await _runAction(
      key: 'deleteAccount',
      action: () async {
        await _safetyService.deleteAccount(confirm: true);
        await _authService.signOut();
      },
      successMessage: 'Аккаунт удалён',
      popToRoot: true,
    );
  }

  Future<void> _runAction({
    required String key,
    required Future<void> Function() action,
    required String successMessage,
    bool popToRoot = false,
  }) async {
    if (_isBusy) return;

    setState(() => _busyAction = key);

    try {
      await action();
      if (!mounted) return;

      _showSnackBar(successMessage, backgroundColor: AppColors.purple);

      if (popToRoot) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Ошибка: ${_friendlyError(e)}',
        backgroundColor: AppColors.roseAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String text,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }

  Future<_ReportPayload?> _showReportDialog() async {
    final commentController = TextEditingController();
    var selectedReason = _reportReasons.first;

    try {
      return await showDialog<_ReportPayload>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Пожаловаться',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Причина',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.bgCardLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        isExpanded: true,
                        dropdownColor: AppColors.bgSurface,
                        icon: const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.textMuted,
                        ),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        items: _reportReasons
                            .map(
                              (reason) => DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedReason = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: commentController,
                    minLines: 3,
                    maxLines: 5,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Комментарий',
                      hintText: 'Необязательно',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      _ReportPayload(
                        reason: selectedReason,
                        description: commentController.text.trim(),
                      ),
                    );
                  },
                  child: const Text(
                    'Отправить',
                    style: TextStyle(color: AppColors.lavender),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      commentController.dispose();
    }
  }

  Future<bool?> _showDeleteAccountDialog() async {
    final controller = TextEditingController();

    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Удалить аккаунт?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Это действие удалит аккаунт и завершит текущую сессию. Продолжайте только если уверены.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text(
                'Введите УДАЛИТЬ для подтверждения',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: _deleteConfirmation,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Отмена',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final enabled = value.text == _deleteConfirmation;
                return TextButton(
                  onPressed: enabled
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: Text(
                    'Удалить',
                    style: TextStyle(
                      color: enabled
                          ? AppColors.roseAccent
                          : AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showDocumentPlaceholder(String title) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Документ будет добавлен перед релизом.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'ОК',
              style: TextStyle(color: AppColors.lavender),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _friendlyError(Object e) {
    if (e is FunctionsCallException) {
      switch (e.code) {
        case 'unauthenticated':
          return 'необходима авторизация';
        case 'failed-precondition':
          return 'условие не выполнено';
        case 'not-found':
          return 'данные не найдены';
        default:
          return e.message;
      }
    }
    return 'попробуйте ещё раз';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: danger
          ? AppColors.roseAccent.withValues(alpha: 0.08)
          : AppColors.bgCard,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.purple,
              ),
            )
          else
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
        ],
      ),
    );
  }
}

class _ReportPayload {
  const _ReportPayload({required this.reason, required this.description});

  final String reason;
  final String description;
}
