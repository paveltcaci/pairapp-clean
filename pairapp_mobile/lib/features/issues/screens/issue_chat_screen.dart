import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../shared/models/agreement.dart';
import '../../../shared/models/checkin.dart';
import '../../../shared/models/issue_message.dart';
import '../../../shared/services/agreement_service.dart';
import '../../../shared/services/checkin_service.dart';
import '../../../shared/services/issue_service.dart';
import '../../../shared/services/user_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

class IssueChatScreen extends StatefulWidget {
  final String issueId;
  final String title;
  final String status;

  const IssueChatScreen({
    super.key,
    required this.issueId,
    required this.title,
    required this.status,
  });

  @override
  State<IssueChatScreen> createState() => _IssueChatScreenState();
}

class _IssueChatScreenState extends State<IssueChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final IssueService _issueService = IssueService();
  final AgreementService _agreementService = AgreementService();
  final UserService _userService = UserService();

  // ── Messages stream ──────────────────────────────────────────────────────
  late Stream<List<IssueMessage>> _messagesStream;

  // ── Agreements: one stable subscription, state in widget ─────────────────
  StreamSubscription<List<Agreement>>? _agreementsSubscription;
  List<Agreement> _issueAgreements = const [];
  bool _agreementsLoading = true;
  Object? _agreementsError;

  // ── Checkins: issue-scoped subscription ───────────────────────────────────
  StreamSubscription<List<Checkin>>? _checkinsSubscription;
  List<Checkin> _issueCheckins = const [];
  String? _submittingCheckinId;
  String? _cachedCoupleId;

  // ── Partner role (needed for correct "Accept" button logic) ───────────────
  bool? _isPartnerA;

  bool _isSending = false;
  String? _acceptingAgreementId;
  IssueMessageType _selectedMessageType = IssueMessageType.comment;

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    debugPrint('IssueChatScreen init issueId=${widget.issueId}');
    _messagesStream = _issueService.watchIssueMessages(widget.issueId);
    _initAgreementsSubscription();
  }

  @override
  void didUpdateWidget(covariant IssueChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issueId != widget.issueId) {
      debugPrint(
        'IssueChatScreen issueId changed old=${oldWidget.issueId}, new=${widget.issueId}',
      );
      _messagesStream = _issueService.watchIssueMessages(widget.issueId);
      setState(() {
        _issueAgreements = const [];
        _issueCheckins = const [];
        _agreementsLoading = true;
        _agreementsError = null;
        _cachedCoupleId = null;
      });
      _initAgreementsSubscription();
    }
  }

  @override
  void dispose() {
    _agreementsSubscription?.cancel();
    _checkinsSubscription?.cancel();
    _tabController.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Agreements subscription setup ─────────────────────────────────────────

  Future<void> _initAgreementsSubscription() async {
    // Cancel any previous subscription first.
    await _agreementsSubscription?.cancel();
    _agreementsSubscription = null;

    try {
      // 1. Get current user profile → coupleId.
      final user = await _userService.getCurrentUserProfile();
      if (!mounted) return;

      final coupleId = user?.currentCoupleId;
      final currentUid = _currentUserId;

      debugPrint(
        'IssueChatScreen _initAgreementsSubscription uid=$currentUid coupleId=${coupleId ?? 'null'} issueId=${widget.issueId}',
      );

      if (coupleId == null || coupleId.isEmpty) {
        setState(() {
          _issueAgreements = const [];
          _agreementsLoading = false;
          _agreementsError = null;
          _isPartnerA = null;
        });
        return;
      }

      // 2. Fetch couple doc once to determine partnerA/B role.
      final coupleSnap = await FirebaseFirestore.instance
          .collection('couples')
          .doc(coupleId)
          .get();
      if (!mounted) return;

      if (coupleSnap.exists && currentUid != null) {
        final partnerAId = coupleSnap.data()?['partnerAId'] as String?;
        _isPartnerA = partnerAId == currentUid;
        debugPrint(
          'IssueChatScreen _isPartnerA=$_isPartnerA partnerAId=$partnerAId currentUid=$currentUid',
        );
      } else {
        _isPartnerA = null;
      }

      // 3. Create ONE subscription; state updates via setState in callbacks.
      _cachedCoupleId = coupleId;
      _agreementsSubscription = _agreementService
          .watchIssueAgreements(widget.issueId, coupleId: coupleId)
          .listen(
            (agreements) {
          if (!mounted) return;
          setState(() {
            _issueAgreements = agreements;
            _agreementsLoading = false;
            _agreementsError = null;
          });
          debugPrint(
            'AGREEMENTS_STATE received count=${agreements.length}',
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!mounted) return;
          setState(() {
            _agreementsLoading = false;
            _agreementsError = error;
          });
          debugPrint('AGREEMENTS_STATE error=$error');
        },
      );

      // 4. Start issue-scoped checkins subscription (filters by issueId client-side).
      _initCheckinsSubscription(coupleId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _agreementsLoading = false;
        _agreementsError = e;
      });
      debugPrint('AGREEMENTS_STATE init error=$e');
    }
  }

  // ── Checkins subscription setup ───────────────────────────────────────────

  void _initCheckinsSubscription(String coupleId) {
    _checkinsSubscription?.cancel();

    debugPrint('ISSUE_CHECKINS_STREAM coupleId=$coupleId issueId=${widget.issueId}');

    _checkinsSubscription = CheckinService()
        .watchCoupleCheckins(coupleId)
        .listen(
          (checkins) {
            if (!mounted) return;

            debugPrint('ISSUE_CHECKINS docs count=${checkins.length}');

            final filtered = checkins.where((c) {
              final matchesIssue = c.issueId == widget.issueId;
              final isOpen = c.isOpen;
              final visible = matchesIssue && isOpen;

              debugPrint(
                'ISSUE_CHECKIN id=${c.id}, agreementId=${c.agreementId}, '
                'issueId=${c.issueId}, status=${c.status}, scheduledAt=${c.scheduledAt}',
              );
              debugPrint(
                'ISSUE_CHECKIN visible=$visible reason: '
                'matchesIssue=$matchesIssue, isOpen=$isOpen',
              );

              return visible;
            }).toList();

            setState(() => _issueCheckins = filtered);
          },
          onError: (Object error) {
            debugPrint('ISSUE_CHECKINS_STREAM error=$error');
          },
        );
  }

  // ── Submit checkin answer ─────────────────────────────────────────────────

  Future<void> _submitCheckinAnswer(
    Checkin checkin,
    CheckinAnswer answer,
  ) async {
    if (_submittingCheckinId != null) return;

    debugPrint(
      'ISSUE_CHECKIN submit answer=${answer.backendValue} checkinId=${checkin.id}',
    );

    setState(() => _submittingCheckinId = checkin.id);

    try {
      await CheckinService().submitCheckinAnswer(
        checkinId: checkin.id,
        answer: answer,
      );
      if (!mounted) return;

      // Stream will auto-update _issueCheckins; show confirmation snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ответ сохранён'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on CheckinServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось отправить ответ.'),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submittingCheckinId = null);
    }
  }

  // ── Accept logic ──────────────────────────────────────────────────────────

  /// Returns true only when the current user has NOT yet confirmed this
  /// agreement. Uses acceptedByPartnerA/B fields (backend source of truth).
  bool _canAcceptAgreement(Agreement agreement) {
    if (!agreement.isPending) return false;
    final isPartnerA = _isPartnerA;
    if (isPartnerA == null) return false; // role unknown → hide button
    return isPartnerA
        ? !agreement.acceptedByPartnerA
        : !agreement.acceptedByPartnerB;
  }

  // ── Send message ──────────────────────────────────────────────────────────

  Future<void> _handleSend() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _issueService.createIssueMessage(
        issueId: widget.issueId,
        text: text,
        type: _selectedMessageType.backendValue,
      );
      _msgController.clear();
      _scrollToBottomSoon();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyErrorMessage(e)),
          backgroundColor: AppColors.bgCard,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is IssueServiceException) return error.message;
    return 'Не удалось отправить сообщение. Попробуйте ещё раз.';
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ── Propose Agreement ─────────────────────────────────────────────────────

  void _showProposeAgreementSheet(IssueMessage message) {
    debugPrint(
      'IssueChatScreen open propose sheet issueId=${widget.issueId} messageId=${message.id}',
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProposeAgreementSheet(
        issueId: widget.issueId,
        solutionText: message.text,
        agreementService: _agreementService,
        onSuccess: () {
          // Do NOT reset the subscription — Firestore listener updates _issueAgreements automatically.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Договорённость предложена'),
              backgroundColor: Color(0xFF2D2D3A),
            ),
          );
        },
        onError: (String msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red.shade900,
            ),
          );
        },
      ),
    );
  }

  // ── Accept Agreement ──────────────────────────────────────────────────────

  Future<void> _acceptAgreement(String agreementId) async {
    if (_acceptingAgreementId != null) return;
    setState(() => _acceptingAgreementId = agreementId);

    try {
      await _agreementService.acceptAgreement(agreementId);
      // Firestore subscription updates _issueAgreements automatically.
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
      _showAgreementError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showAgreementError('Не удалось принять договорённость.');
    } finally {
      if (mounted) setState(() => _acceptingAgreementId = null);
    }
  }

  void _showAgreementError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildChatTab(), _buildAgreementsTab()],
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StatusBadge(status: widget.status),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Чат'),
          Tab(text: 'Договорённости'),
        ],
      ),
    );
  }

  // ── Chat tab ──────────────────────────────────────────────────────────────
  // Uses _issueAgreements from state (no extra StreamBuilder for agreements).

  Widget _buildChatTab() {
    // Derive button/badge state from in-memory _issueAgreements.
    final hasBlockingAgreement = _issueAgreements.any(
          (a) => a.isPending || a.isAccepted || a.isActive,
    );

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<IssueMessage>>(
            stream: _messagesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.purple),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Не удалось загрузить сообщения.',
                      style: TextStyle(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final messages = snapshot.data ?? const <IssueMessage>[];

              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    'Пока нет сообщений',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                }
              });

              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _buildBubble(
                  messages[i],
                  hasBlockingAgreement: hasBlockingAgreement,
                ),
              );
            },
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildBubble(
      IssueMessage message, {
        required bool hasBlockingAgreement,
      }) {
    final isMe = _currentUserId != null && message.authorId == _currentUserId;
    final isSolution = message.type == IssueMessageType.solution;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe ? AppColors.purpleGradient : null,
              color: isMe ? null : AppColors.bgCard,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: isMe ? null : Border.all(color: AppColors.bgCardLight),
              boxShadow: isMe
                  ? [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeBadge(message.type, isMe: isMe),
                const SizedBox(height: 5),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isSolution) ...[
            const SizedBox(height: 4),
            if (_agreementsLoading && _issueAgreements.isEmpty)
              _buildAgreementStateBadge(
                icon: Icons.hourglass_empty,
                text: 'Проверяем договорённости...',
              )
            else if (_agreementsError != null)
              _buildAgreementStateBadge(
                icon: Icons.error_outline,
                text: 'Не удалось проверить договорённость',
              )
            else if (hasBlockingAgreement)
                _buildAgreementStateBadge(
                  icon: Icons.check_circle_outline,
                  text: 'Договорённость уже предложена',
                )
              else if (!isMe)
                  _buildProposeButton(message),
          ],
        ],
      ),
    );
  }

  Widget _buildAgreementStateBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposeButton(IssueMessage message) {
    return GestureDetector(
      onTap: () => _showProposeAgreementSheet(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.statusResolved.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.statusResolved.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 13,
              color: AppColors.statusResolved,
            ),
            const SizedBox(width: 5),
            Text(
              'Сделать договорённостью',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.statusResolved,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Agreements tab ────────────────────────────────────────────────────────
  // Reads directly from _issueAgreements state. NO StreamBuilder here.

  Widget _buildAgreementsTab() {
    // Show spinner only while initially loading AND no data yet.
    if (_agreementsLoading && _issueAgreements.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (_agreementsError != null) {
      return _buildAgreementsMessage(
        icon: Icons.warning_amber_rounded,
        title: 'Не удалось загрузить договорённости',
        subtitle: 'Проверьте подключение и попробуйте позже.',
      );
    }

    if (_issueAgreements.isEmpty) {
      return _buildAgreementsMessage(
        icon: Icons.handshake_outlined,
        title: 'Пока нет договорённостей по этой проблеме',
        subtitle: 'Предложите решение в чате, чтобы создать договорённость.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _issueAgreements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final agreement = _issueAgreements[i];
        // Find a pending checkin linked to this agreement.
        final checkin = _issueCheckins
            .where((c) => c.agreementId == agreement.id)
            .firstOrNull;
        final showCheckin =
            checkin != null && (agreement.isActive || agreement.isAccepted);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAgreementCard(agreement),
            if (showCheckin) ...[
              const SizedBox(height: 12),
              _buildCheckinCard(checkin!),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAgreementCard(Agreement agreement) {
    final canAccept = _canAcceptAgreement(agreement);
    final isAccepting = _acceptingAgreementId == agreement.id;
    final statusColor = _agreementStatusColor(agreement.status);
    final currentUserId = _currentUserId;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _agreementStatusIcon(agreement.status),
                  color: statusColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
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
                      _agreementSubtitle(agreement, currentUserId),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AgreementStatusPill(
                label: _agreementStatusLabel(agreement.status),
                color: statusColor,
              ),
            ],
          ),
          if (_hasAgreementDescription(agreement)) ...[
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
                  _agreementCheckDateLabel(agreement),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          if (_isPartnerA == null && agreement.isPending) ...[
            const SizedBox(height: 12),
            Text(
              'Загрузка статуса подтверждения...',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ] else if (canAccept) ...[
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

  // ── Check-in card ─────────────────────────────────────────────────────────

  Widget _buildCheckinCard(Checkin checkin) {
    final isPartnerA = _isPartnerA;
    final ownAnswer = isPartnerA == true
        ? checkin.partnerAAnswer
        : checkin.partnerBAnswer;
    final hasAnswered = ownAnswer != null;
    final isSubmitting = _submittingCheckinId == checkin.id;

    final scheduledAt = checkin.scheduledAt;
    final isDue = scheduledAt == null || !scheduledAt.isAfter(DateTime.now());
    final String dateLabel;
    if (scheduledAt == null) {
      dateLabel = 'Дата check-in не указана';
    } else if (isDue) {
      dateLabel = 'Пора проверить договорённость';
    } else {
      final d = scheduledAt.day.toString().padLeft(2, '0');
      final m = scheduledAt.month.toString().padLeft(2, '0');
      dateLabel = 'Проверка запланирована: $d.$m.${scheduledAt.year}';
    }

    return AppCard(
      color: AppColors.bgCardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.statusDiscussion.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.statusDiscussion,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-in',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasAnswered
                          ? 'Ваш ответ сохранён, ждём партнёра'
                          : 'Работает ли договорённость?',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusDiscussion.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.statusDiscussion.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  checkin.status == CheckinStatus.partial
                      ? 'Ждём ответ'
                      : 'Ожидает',
                  style: const TextStyle(
                    color: AppColors.statusDiscussion,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date row — uses checkin.scheduledAt, not agreement.checkDate
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDue
                        ? AppColors.statusDiscussion
                        : AppColors.textMuted,
                    fontWeight:
                        isDue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Answer area
          if (hasAnswered)
            Row(
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ваш ответ принят. Ожидаем партнёра.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            )
          else if (isSubmitting)
            const SizedBox(
              height: 38,
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
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildCheckinAnswerButton(
                    label: 'Да',
                    color: AppColors.statusResolved,
                    onTap: () => _submitCheckinAnswer(
                      checkin,
                      CheckinAnswer.yes,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCheckinAnswerButton(
                    label: 'Частично',
                    color: AppColors.statusDiscussion,
                    onTap: () => _submitCheckinAnswer(
                      checkin,
                      CheckinAnswer.partially,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCheckinAnswerButton(
                    label: 'Нет',
                    color: AppColors.roseAccent,
                    onTap: () => _submitCheckinAnswer(
                      checkin,
                      CheckinAnswer.no,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCheckinAnswerButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.55)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementsMessage({
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
            Icon(icon, size: 44, color: AppColors.textMuted),
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
                height: 1.35,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _hasAgreementDescription(Agreement agreement) {
    final d = agreement.description;
    return d != null && d.isNotEmpty;
  }

  String _agreementSubtitle(Agreement agreement, String? currentUserId) {
    if (currentUserId != null && agreement.proposedBy == currentUserId) {
      return agreement.isPending
          ? 'Ожидаем подтверждения партнёра'
          : 'Вы предложили';
    }
    if (!_canAcceptAgreement(agreement) && agreement.isPending) {
      return 'Ожидаем подтверждения партнёра';
    }
    return agreement.isPending
        ? 'Партнёр предложил, ждёт вашего ответа'
        : 'Предложил партнёр';
  }

  String _agreementCheckDateLabel(Agreement agreement) {
    final date = agreement.checkDate;
    if (date == null) return 'Дата проверки не указана';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return 'Проверка: $day.$month.${date.year}';
  }

  IconData _agreementStatusIcon(AgreementStatus status) {
    return switch (status) {
      AgreementStatus.proposed ||
      AgreementStatus.acceptedByOne =>
      Icons.hourglass_empty_rounded,
      AgreementStatus.acceptedByBoth ||
      AgreementStatus.active =>
      Icons.handshake_outlined,
      AgreementStatus.completed => Icons.check_circle_outline,
      AgreementStatus.failed => Icons.error_outline_rounded,
      AgreementStatus.archived => Icons.inventory_2_outlined,
      AgreementStatus.unknown => Icons.help_outline,
    };
  }

  Color _agreementStatusColor(AgreementStatus status) {
    return switch (status) {
      AgreementStatus.proposed ||
      AgreementStatus.acceptedByOne =>
      AppColors.statusDiscussion,
      AgreementStatus.acceptedByBoth ||
      AgreementStatus.active =>
      AppColors.purple,
      AgreementStatus.completed => AppColors.statusResolved,
      AgreementStatus.failed => AppColors.roseAccent,
      AgreementStatus.archived ||
      AgreementStatus.unknown =>
      AppColors.textMuted,
    };
  }

  String _agreementStatusLabel(AgreementStatus status) {
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

  // ── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.bgCardLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMessageTypeChips(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  enabled: !_isSending,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Напишите сообщение...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isSending ? null : _handleSend,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isSending
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTypeChips() {
    const types = <IssueMessageType>[
      IssueMessageType.comment,
      IssueMessageType.objection,
      IssueMessageType.solution,
    ];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _buildTypeChip(types[i]),
      ),
    );
  }

  Widget _buildTypeChip(IssueMessageType type) {
    final isSelected = _selectedMessageType == type;
    final color = _messageTypeColor(type);

    return GestureDetector(
      onTap: _isSending
          ? null
          : () => setState(() => _selectedMessageType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.bgCardLight,
          ),
        ),
        child: Text(
          type.displayLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Color _messageTypeColor(IssueMessageType type) {
    return switch (type) {
      IssueMessageType.objection => AppColors.statusDiscussion,
      IssueMessageType.solution => AppColors.statusResolved,
      IssueMessageType.comment => AppColors.lavender,
      _ => AppColors.textMuted,
    };
  }

  Widget _buildTypeBadge(IssueMessageType type, {required bool isMe}) {
    final badgeColor = _messageTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.9)
            : badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        type.displayLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}

// ── _AgreementStatusPill ────────────────────────────────────────────────────

class _AgreementStatusPill extends StatelessWidget {
  const _AgreementStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── _ProposeAgreementSheet ──────────────────────────────────────────────────

class _ProposeAgreementSheet extends StatefulWidget {
  const _ProposeAgreementSheet({
    required this.issueId,
    required this.solutionText,
    required this.agreementService,
    required this.onSuccess,
    required this.onError,
  });

  final String issueId;
  final String solutionText;
  final AgreementService agreementService;
  final VoidCallback onSuccess;
  final void Function(String message) onError;

  @override
  State<_ProposeAgreementSheet> createState() => _ProposeAgreementSheetState();
}

class _ProposeAgreementSheetState extends State<_ProposeAgreementSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  int _checkIntervalDays = 7;
  bool _isLoading = false;

  static const List<int> _intervals = [1, 3, 7, 14, 30];
  static const int _titlePreviewLength = 60;

  @override
  void initState() {
    super.initState();
    final text = widget.solutionText.trim();
    final description = text.length > AgreementService.descriptionMaxLength
        ? text.substring(0, AgreementService.descriptionMaxLength).trimRight()
        : text;
    _titleController = TextEditingController(
      text: text.length > _titlePreviewLength
          ? '${text.substring(0, _titlePreviewLength)}...'
          : text,
    );
    _descController = TextEditingController(text: description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handlePropose() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      widget.onError('Введите название договорённости.');
      return;
    }
    if (title.length < AgreementService.titleMinLength) {
      widget.onError('Название должно быть не короче 3 символов.');
      return;
    }

    final description = _descController.text.trim();
    if (description.length > AgreementService.descriptionMaxLength) {
      widget.onError('Описание не должно быть длиннее 2000 символов.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint(
        'IssueChatScreen submit proposeAgreement issueId=${widget.issueId} title=$title checkIntervalDays=$_checkIntervalDays',
      );
      await widget.agreementService.proposeAgreement(
        issueId: widget.issueId,
        title: title,
        description: description.isEmpty ? null : description,
        checkIntervalDays: _checkIntervalDays,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess();
    } on AgreementServiceException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onError(e.message);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onError('Не удалось предложить договорённость.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2D2D3A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Предложить договорённость',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Название'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _titleController,
            hint: 'Краткое название договорённости',
            maxLines: 2,
            maxLength: AgreementService.titleMaxLength,
          ),
          const SizedBox(height: 14),
          _buildLabel('Описание'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _descController,
            hint: 'Подробнее о договорённости',
            maxLines: 4,
            maxLength: AgreementService.descriptionMaxLength,
          ),
          const SizedBox(height: 16),
          _buildLabel('Интервал проверки'),
          const SizedBox(height: 8),
          _buildIntervalSelector(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isLoading ? null : _handlePropose,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppColors.purpleGradient,
                  color: _isLoading ? const Color(0xFF2D2D3A) : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isLoading
                      ? null
                      : [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.textMuted,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Предложить',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        counterStyle: const TextStyle(
          fontSize: 11,
          color: AppColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _intervals.map((days) {
        final isSelected = _checkIntervalDays == days;
        return GestureDetector(
          onTap: _isLoading
              ? null
              : () => setState(() => _checkIntervalDays = days),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.purple.withValues(alpha: 0.18)
                  : const Color(0xFF2D2D3A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.purple : const Color(0xFF3D3D50),
              ),
            ),
            child: Text(
              _intervalLabel(days),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.purple : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _intervalLabel(int days) {
    return switch (days) {
      1 => '1 день',
      3 => '3 дня',
      7 => '7 дней',
      14 => '14 дней',
      30 => '30 дней',
      _ => '$days дней',
    };
  }
}