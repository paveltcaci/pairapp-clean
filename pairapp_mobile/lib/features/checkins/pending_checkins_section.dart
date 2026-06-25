import 'package:flutter/material.dart';

import '../../shared/models/agreement.dart';
import '../../shared/models/checkin.dart';
import '../../shared/models/couple.dart';
import '../../shared/models/issue.dart';
import '../../shared/services/checkin_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/issue_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_colors.dart';

class PendingCheckinsSection extends StatefulWidget {
  const PendingCheckinsSection({
    super.key,
    required this.coupleId,
    required this.currentUserId,
    required this.agreements,
  });

  final String coupleId;
  final String currentUserId;
  final List<Agreement> agreements;

  @override
  State<PendingCheckinsSection> createState() => _PendingCheckinsSectionState();
}

class _PendingCheckinsSectionState extends State<PendingCheckinsSection> {
  final _checkinService = CheckinService();
  final _coupleService = CoupleService();
  final _issueService = IssueService();

  String? _submittingCheckinId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Couple?>(
      stream: _coupleService.watchCouple(widget.coupleId),
      builder: (context, coupleSnapshot) {
        if (coupleSnapshot.hasError) {
          return _buildInlineError('Не удалось загрузить данные пары.');
        }

        final couple = coupleSnapshot.data;
        if (couple == null) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<List<Checkin>>(
          stream: _checkinService.watchCoupleCheckins(widget.coupleId),
          builder: (context, checkinsSnapshot) {
            if (checkinsSnapshot.hasError) {
              return _buildInlineError('Не удалось загрузить check-in.');
            }

            if (checkinsSnapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.purple,
                  backgroundColor: AppColors.bgCard,
                ),
              );
            }

            final activeAgreementIds = widget.agreements
                .where((agreement) => agreement.isActive || agreement.isAccepted)
                .map((agreement) => agreement.id)
                .toSet();
            final checkins = (checkinsSnapshot.data ?? const <Checkin>[])
                .where(
                  (checkin) =>
                      checkin.isOpen &&
                      activeAgreementIds.contains(checkin.agreementId),
                )
                .toList();

            if (checkins.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Text(
                    'Проверка договорённостей',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...checkins.map(
                  (checkin) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _CheckinCard(
                      checkin: checkin,
                      agreement: _agreementFor(checkin),
                      couple: couple,
                      currentUserId: widget.currentUserId,
                      issueService: _issueService,
                      isSubmitting: _submittingCheckinId == checkin.id,
                      onAnswer: (answer) => _submitAnswer(checkin, answer),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Agreement? _agreementFor(Checkin checkin) {
    for (final agreement in widget.agreements) {
      if (agreement.id == checkin.agreementId) {
        return agreement;
      }
    }
    return null;
  }

  Widget _buildInlineError(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: AppCard(
        color: AppColors.bgCardLight,
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer(Checkin checkin, CheckinAnswer answer) async {
    if (_submittingCheckinId != null) return;

    setState(() => _submittingCheckinId = checkin.id);

    try {
      final result = await _checkinService.submitCheckinAnswer(
        checkinId: checkin.id,
        answer: answer,
      );

      if (!mounted) return;
      _showResult(result);
    } on CheckinServiceException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Не удалось отправить ответ на check-in.');
    } finally {
      if (mounted) {
        setState(() => _submittingCheckinId = null);
      }
    }
  }

  void _showResult(SubmitCheckinAnswerResult result) {
    final message = switch (result.result) {
      CheckinResult.success => 'Оба ответили: договорённость выполнена.',
      CheckinResult.partial => 'Оба ответили: нужна корректировка.',
      CheckinResult.failed => 'Оба ответили: договорённость не сработала.',
      CheckinResult.unknown || null => result.bothAnswered
          ? 'Ответы получены.'
          : 'Ответ сохранён. Ждём ответ партнёра.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
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
}

class _CheckinCard extends StatelessWidget {
  const _CheckinCard({
    required this.checkin,
    required this.agreement,
    required this.couple,
    required this.currentUserId,
    required this.issueService,
    required this.isSubmitting,
    required this.onAnswer,
  });

  final Checkin checkin;
  final Agreement? agreement;
  final Couple couple;
  final String currentUserId;
  final IssueService issueService;
  final bool isSubmitting;
  final ValueChanged<CheckinAnswer> onAnswer;

  @override
  Widget build(BuildContext context) {
    final isPartnerA = couple.partnerAId == currentUserId;
    final ownAnswer =
        isPartnerA ? checkin.partnerAAnswer : checkin.partnerBAnswer;
    final hasAnswered = ownAnswer != null;

    return AppCard(
      color: AppColors.bgCardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.statusDiscussion.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.statusDiscussion,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _agreementTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(hasAnswered),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _CheckinStatusBadge(checkin: checkin),
            ],
          ),
          if (_agreementText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _agreementText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          if (checkin.issueId?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            FutureBuilder<Issue?>(
              future: issueService.getIssue(checkin.issueId!),
              builder: (context, snapshot) {
                final title = snapshot.data?.title;
                if (title == null || title.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _MetaRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  text: 'Проблема: $title',
                );
              },
            ),
          ],
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.event_available_outlined,
            text: _dateLabel(checkin.scheduledAt),
          ),
          const SizedBox(height: 14),
          if (ownAnswer != null)
            _AnsweredState(answer: ownAnswer)
          else
            _AnswerButtons(
              enabled: !isSubmitting,
              isSubmitting: isSubmitting,
              onAnswer: onAnswer,
            ),
        ],
      ),
    );
  }

  String get _agreementTitle {
    final title = agreement?.title.trim();
    if (title != null && title.isNotEmpty) return title;
    return 'Договорённость';
  }

  String get _agreementText {
    final description = agreement?.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    return '';
  }

  String _statusLabel(bool hasAnswered) {
    if (hasAnswered) return 'Ваш ответ сохранён, ждём партнёра';
    return 'Пора проверить, работает ли договорённость';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Дата check-in не указана';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return 'Check-in: $day.$month.${date.year}';
  }
}

class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons({
    required this.enabled,
    required this.isSubmitting,
    required this.onAnswer,
  });

  final bool enabled;
  final bool isSubmitting;
  final ValueChanged<CheckinAnswer> onAnswer;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return const SizedBox(
        height: 42,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.purple,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _AnswerButton(
            label: 'Да',
            color: AppColors.statusResolved,
            enabled: enabled,
            onTap: () => onAnswer(CheckinAnswer.yes),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AnswerButton(
            label: 'Частично',
            color: AppColors.statusDiscussion,
            enabled: enabled,
            onTap: () => onAnswer(CheckinAnswer.partially),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AnswerButton(
            label: 'Нет',
            color: AppColors.roseAccent,
            enabled: enabled,
            onTap: () => onAnswer(CheckinAnswer.no),
          ),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: enabled ? 0.55 : 0.22),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: enabled ? color : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AnsweredState extends StatelessWidget {
  const _AnsweredState({required this.answer});

  final CheckinAnswer answer;

  @override
  Widget build(BuildContext context) {
    return _MetaRow(
      icon: Icons.hourglass_top_rounded,
      text: 'Ваш ответ: ${_answerLabel(answer)}. Ждём ответ партнёра.',
    );
  }

  String _answerLabel(CheckinAnswer answer) {
    return switch (answer) {
      CheckinAnswer.yes => 'да',
      CheckinAnswer.partially => 'частично',
      CheckinAnswer.no => 'нет',
    };
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckinStatusBadge extends StatelessWidget {
  const _CheckinStatusBadge({required this.checkin});

  final Checkin checkin;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (checkin.status) {
      CheckinStatus.pending => ('Ожидает', AppColors.statusDiscussion),
      CheckinStatus.partial => ('Ждём ответ', AppColors.purple),
      CheckinStatus.completed => ('Готово', AppColors.statusResolved),
      CheckinStatus.unknown => ('Check-in', AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
