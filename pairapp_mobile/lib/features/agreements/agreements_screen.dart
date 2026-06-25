import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../checkins/pending_checkins_section.dart';
import '../../shared/models/agreement.dart';
import '../../shared/models/app_user.dart';
import '../../shared/services/agreement_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';

class AgreementsScreen extends StatefulWidget {
  const AgreementsScreen({super.key});

  @override
  State<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends State<AgreementsScreen> {
  final _agreementService = AgreementService();
  final _userService = UserService();

  int _tabIndex = 0;
  String? _acceptingAgreementId;
  late final Stream<AppUser?> _userStream;
  Stream<List<Agreement>>? _agreementsStream;
  String? _agreementsCoupleId;

  /// null = not yet fetched; true = current user is partnerA; false = partnerB.
  bool? _isPartnerA;

  static const List<String> _tabs = ['Ожидают', 'Активные', 'Завершённые'];

  @override
  void initState() {
    super.initState();
    _userStream = _userService.watchCurrentUserProfile();
  }

  List<Agreement> _filtered(List<Agreement> agreements) {
    return switch (_tabIndex) {
    // "Ожидают" — proposed + accepted_by_one
      0 => agreements.where((a) => a.isPending).toList(),
    // "Активные" — active + accepted_by_both
      1 => agreements.where((a) => a.isActive || a.isAccepted).toList(),
    // "Завершённые" — completed + failed + archived
      2 => agreements
          .where((a) => a.isCompleted || a.isFailed || a.status == AgreementStatus.archived)
          .toList(),
      _ => agreements,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabs(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
          Expanded(
            child: Text(
              'Договорённости',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final tab = entry.value;
          final selected = i == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.purpleGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<AppUser?>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return _buildMessage(
            icon: Icons.error_outline,
            title: 'Не удалось загрузить профиль',
            subtitle: _streamErrorMessage(userSnapshot.error),
          );
        }

        if (!userSnapshot.hasData &&
            userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildMessage(
            icon: Icons.hourglass_empty_rounded,
            title: 'Загружаем профиль',
            subtitle:
            'Если экран не обновится, current user profile stream не отдал данные.',
          );
        }

        final user = userSnapshot.data;
        final coupleId = user?.currentCoupleId;
        if (user == null || coupleId == null || coupleId.isEmpty) {
          return _buildMessage(
            icon: Icons.people_outline,
            title: 'Нет активной пары',
            subtitle: 'Договорённости появятся после подключения партнёра.',
          );
        }

        return StreamBuilder<List<Agreement>>(
          stream: _watchAgreementsFor(coupleId),
          builder: (context, agreementsSnapshot) {
            if (agreementsSnapshot.hasError) {
              return _buildMessage(
                icon: Icons.warning_amber_rounded,
                title: 'Не удалось загрузить договорённости',
                subtitle: _streamErrorMessage(agreementsSnapshot.error),
              );
            }

            if (!agreementsSnapshot.hasData &&
                agreementsSnapshot.connectionState == ConnectionState.waiting) {
              return _buildMessage(
                icon: Icons.hourglass_empty_rounded,
                title: 'Загружаем договорённости',
                subtitle: 'coupleId=$coupleId',
              );
            }

            final allAgreements =
                agreementsSnapshot.data ?? const <Agreement>[];
            final agreements = _filtered(allAgreements);

            if (allAgreements.isEmpty) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  PendingCheckinsSection(
                    coupleId: coupleId,
                    currentUserId: user.id,
                    agreements: allAgreements,
                  ),
                  SizedBox(
                    height: 360,
                    child: _buildMessage(
                      icon: Icons.handshake_outlined,
                      title: 'Пока нет договорённостей',
                      subtitle:
                      'Новые договорённости появятся здесь после создания из чата проблемы.',
                    ),
                  ),
                ],
              );
            }

            if (agreements.isEmpty) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  PendingCheckinsSection(
                    coupleId: coupleId,
                    currentUserId: user.id,
                    agreements: allAgreements,
                  ),
                  SizedBox(height: 360, child: _buildEmptyState()),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              itemCount: agreements.length + 1,
              separatorBuilder: (context, index) => index == 0
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return PendingCheckinsSection(
                    coupleId: coupleId,
                    currentUserId: user.id,
                    agreements: allAgreements,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildAgreementCard(
                    agreements[index - 1],
                    currentUserId: user.id,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Stream<List<Agreement>> _watchAgreementsFor(String coupleId) {
    if (_agreementsCoupleId != coupleId) {
      _agreementsCoupleId = coupleId;
      _agreementsStream = _agreementService.watchCoupleAgreements(coupleId);
      // Fetch couple doc once to determine current user's role.
      _fetchPartnerRole(coupleId);
    }
    return _agreementsStream!;
  }

  Future<void> _fetchPartnerRole(String coupleId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snap = await FirebaseFirestore.instance
          .collection('couples')
          .doc(coupleId)
          .get();
      if (!mounted) return;
      final partnerAId = snap.data()?['partnerAId'] as String?;
      setState(() {
        _isPartnerA = partnerAId == uid;
      });
      debugPrint(
        'AgreementsScreen _isPartnerA=$_isPartnerA partnerAId=$partnerAId uid=$uid',
      );
    } catch (e) {
      debugPrint('AgreementsScreen _fetchPartnerRole error=$e');
    }
  }

  Widget _buildAgreementCard(
      Agreement agreement, {
        required String currentUserId,
      }) {
    final canAccept = _canAccept(agreement, currentUserId);
    final isAccepting = _acceptingAgreementId == agreement.id;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _statusColor(agreement.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _statusIcon(agreement.status),
                  color: _statusColor(agreement.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agreement.title.isEmpty
                          ? 'Договорённость без названия'
                          : agreement.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(agreement, currentUserId),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _AgreementStatusBadge(agreement.status),
            ],
          ),
          if (_hasDescription(agreement)) ...[
            const SizedBox(height: 12),
            Text(
              agreement.description!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 15,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _checkDateLabel(agreement),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          if (canAccept) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: isAccepting ? null : () => _acceptAgreement(agreement.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 42,
                decoration: BoxDecoration(
                  gradient: isAccepting ? null : AppColors.purpleGradient,
                  color: isAccepting ? AppColors.bgCardLight : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isAccepting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textMuted,
                    ),
                  )
                      : const Text(
                    'Принять',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _acceptAgreement(String agreementId) async {
    if (_acceptingAgreementId != null) return;

    setState(() => _acceptingAgreementId = agreementId);

    try {
      await _agreementService.acceptAgreement(agreementId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Договорённость принята'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AgreementServiceException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Не удалось принять договорённость.');
    } finally {
      if (mounted) {
        setState(() => _acceptingAgreementId = null);
      }
    }
  }

  bool _canAccept(Agreement agreement, String currentUserId) {
    if (!agreement.isPending) return false;
    final isPartnerA = _isPartnerA;
    if (isPartnerA == null) return false; // role unknown → hide button
    return isPartnerA
        ? !agreement.acceptedByPartnerA
        : !agreement.acceptedByPartnerB;
  }

  bool _hasDescription(Agreement agreement) {
    final description = agreement.description;
    return description != null && description.isNotEmpty;
  }

  String _streamErrorMessage(Object? error) {
    if (error == null) {
      return 'Проверьте подключение и попробуйте позже.';
    }
    return error.toString();
  }

  Widget _buildEmptyState() {
    return _buildMessage(
      icon: switch (_tabIndex) {
        0 => Icons.hourglass_empty_rounded,
        1 => Icons.handshake_outlined,
        _ => Icons.done_all_rounded,
      },
      title: switch (_tabIndex) {
        0 => 'Нет ожидающих договорённостей',
        1 => 'Нет активных договорённостей',
        _ => 'Нет завершённых договорённостей',
      },
      subtitle: switch (_tabIndex) {
        0 => 'Предложенные решения появятся здесь.',
        1 => 'Активные договорённости появятся после подтверждения обоими.',
        _ => 'История выполненных и неудачных проверок появится здесь.',
      },
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _subtitle(Agreement agreement, String currentUserId) {
    if (agreement.proposedBy == currentUserId) {
      return agreement.isPending
          ? 'Ожидаем подтверждения партнёра'
          : 'Вы предложили';
    }

    // If current user already confirmed but partner hasn't yet.
    if (!_canAccept(agreement, currentUserId) && agreement.isPending) {
      return 'Ожидаем подтверждения партнёра';
    }

    return agreement.isPending
        ? 'Партнёр предложил, ждёт вашего ответа'
        : 'Предложил партнёр';
  }

  String _checkDateLabel(Agreement agreement) {
    final date = agreement.checkDate;
    if (date == null) return 'Дата проверки не указана';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return 'Проверка: $day.$month.${date.year}';
  }

  IconData _statusIcon(AgreementStatus status) {
    return switch (status) {
      AgreementStatus.proposed ||
      AgreementStatus.acceptedByOne => Icons.hourglass_empty_rounded,
      AgreementStatus.acceptedByBoth ||
      AgreementStatus.active => Icons.handshake_outlined,
      AgreementStatus.completed => Icons.check_circle_outline,
      AgreementStatus.failed => Icons.error_outline_rounded,
      AgreementStatus.archived => Icons.inventory_2_outlined,
      AgreementStatus.unknown => Icons.help_outline,
    };
  }

  Color _statusColor(AgreementStatus status) {
    return switch (status) {
      AgreementStatus.proposed ||
      AgreementStatus.acceptedByOne => AppColors.statusDiscussion,
      AgreementStatus.acceptedByBoth ||
      AgreementStatus.active => AppColors.purple,
      AgreementStatus.completed => AppColors.statusResolved,
      AgreementStatus.failed => AppColors.roseAccent,
      AgreementStatus.archived ||
      AgreementStatus.unknown => AppColors.textMuted,
    };
  }
}

class _AgreementStatusBadge extends StatelessWidget {
  const _AgreementStatusBadge(this.status);

  final AgreementStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AgreementStatus.proposed ||
      AgreementStatus.acceptedByOne => AppColors.statusDiscussion,
      AgreementStatus.acceptedByBoth ||
      AgreementStatus.active => AppColors.purple,
      AgreementStatus.completed => AppColors.statusResolved,
      AgreementStatus.failed => AppColors.roseAccent,
      AgreementStatus.archived ||
      AgreementStatus.unknown => AppColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        _label(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _label(AgreementStatus status) {
    return switch (status) {
      AgreementStatus.proposed => 'Предложена',
      AgreementStatus.acceptedByOne => 'Ожидает',
      AgreementStatus.acceptedByBoth || AgreementStatus.active => 'Активна',
      AgreementStatus.completed => 'Выполнена',
      AgreementStatus.failed => 'Не работает',
      AgreementStatus.archived => 'Архив',
      AgreementStatus.unknown => 'Неизвестно',
    };
  }
}