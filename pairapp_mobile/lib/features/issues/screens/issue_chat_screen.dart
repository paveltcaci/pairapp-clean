import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../shared/models/agreement.dart';
import '../../../shared/models/issue_message.dart';
import '../../../shared/services/agreement_service.dart';
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

  late Stream<List<IssueMessage>> _messagesStream;
  Stream<List<Agreement>>? _agreementsStream;
  String? _agreementsCoupleId;
  bool _isSending = false;
  String? _acceptingAgreementId;
  IssueMessageType _selectedMessageType = IssueMessageType.comment;

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    debugPrint('IssueChatScreen init issueId=${widget.issueId}');
    _subscribeToIssueStreams();
  }

  @override
  void didUpdateWidget(covariant IssueChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issueId != widget.issueId) {
      debugPrint(
        'IssueChatScreen issueId changed old=${oldWidget.issueId}, new=${widget.issueId}',
      );
      _subscribeToIssueStreams();
    }
  }

  void _subscribeToIssueStreams() {
    _messagesStream = _issueService.watchIssueMessages(widget.issueId);
    _agreementsStream = null;
    _agreementsCoupleId = null;
    _loadCoupleIdAndSubscribe();
  }

  Future<void> _loadCoupleIdAndSubscribe() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      if (!mounted) return;

      final coupleId = user?.currentCoupleId;
      _agreementsCoupleId = coupleId;
      debugPrint(
        'IssueChatScreen subscribe agreements currentUserId=$_currentUserId, coupleId=${coupleId ?? 'null'}, issueId=${widget.issueId}',
      );
      if (coupleId == null || coupleId.isEmpty) {
        setState(() {
          _agreementsStream = Stream.value(const <Agreement>[]);
        });
        return;
      }

      setState(() {
        _agreementsStream = _agreementService.watchIssueAgreements(
          widget.issueId,
          coupleId: coupleId,
        );
      });
    } catch (_) {
      if (!mounted) return;
      // If we cannot verify agreements, keep the propose button hidden.
      setState(() {
        _agreementsStream = Stream<List<Agreement>>.error(
          const AgreementServiceException(
            'Не удалось проверить договорённости',
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is IssueServiceException) {
      return error.message;
    }
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

  // ── Propose Agreement ────────────────────────────────────────────────────

  void _showProposeAgreementSheet(IssueMessage message) {
    debugPrint(
      'IssueChatScreen open propose sheet widgetIssueId=${widget.issueId}, messageId=${message.id}, messageIssueId=${message.issueId}',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Договорённость предложена'),
              backgroundColor: Color(0xFF2D2D3A),
            ),
          );
        },
        onError: (String msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red.shade900),
          );
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

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

  Widget _buildChatTab() {
    return StreamBuilder<List<Agreement>>(
      stream: _agreementsStream,
      builder: (context, agreementSnapshot) {
        final isAgreementCheckLoading =
            _agreementsStream == null ||
            (!agreementSnapshot.hasError &&
                !agreementSnapshot.hasData &&
                agreementSnapshot.connectionState == ConnectionState.waiting);
        final isAgreementCheckFailed = agreementSnapshot.hasError;
        final hasBlockingAgreement =
            agreementSnapshot.hasData &&
            agreementSnapshot.data!.any(
              (agreement) =>
                  agreement.isPending ||
                  agreement.isAccepted ||
                  agreement.isActive,
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
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
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
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) => _buildBubble(
                      messages[i],
                      hasBlockingAgreement: hasBlockingAgreement,
                      isAgreementCheckLoading: isAgreementCheckLoading,
                      isAgreementCheckFailed: isAgreementCheckFailed,
                    ),
                  );
                },
              ),
            ),
            _buildInputBar(),
          ],
        );
      },
    );
  }

  Widget _buildBubble(
    IssueMessage message, {
    required bool hasBlockingAgreement,
    required bool isAgreementCheckLoading,
    required bool isAgreementCheckFailed,
  }) {
    final isMe = _currentUserId != null && message.authorId == _currentUserId;
    final isSolution = message.type == IssueMessageType.solution;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
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
            if (isAgreementCheckLoading)
              _buildAgreementStateBadge(
                icon: Icons.hourglass_empty,
                text: 'Проверяем договорённости...',
              )
            else if (isAgreementCheckFailed)
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

  Color _messageTypeColor(IssueMessageType type) {
    switch (type) {
      case IssueMessageType.objection:
        return AppColors.statusDiscussion;
      case IssueMessageType.solution:
        return AppColors.statusResolved;
      case IssueMessageType.comment:
        return AppColors.lavender;
      case IssueMessageType.agreement:
      case IssueMessageType.checkin:
      case IssueMessageType.reopen:
      case IssueMessageType.unknown:
        return AppColors.textMuted;
    }
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
        itemBuilder: (context, index) => _buildTypeChip(types[index]),
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
            width: 1,
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

  Widget _buildAgreementsTab() {
    final stream = _agreementsStream;
    if (stream == null) {
      return _buildAgreementsMessage(
        icon: Icons.bug_report_outlined,
        title: 'DEBUG: agreements stream is null',
        subtitle:
            'currentUserId=${_currentUserId ?? 'null'}\n'
            'coupleId=${_agreementsCoupleId ?? 'null'}\n'
            'issueId=${widget.issueId}',
      );
    }

    return StreamBuilder<List<Agreement>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildAgreementsMessage(
            icon: Icons.warning_amber_rounded,
            title: 'Не удалось загрузить договорённости',
            subtitle: _agreementStreamErrorMessage(snapshot.error),
          );
        }

        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return _buildAgreementsMessage(
            icon: Icons.hourglass_empty_rounded,
            title: 'Загружаем договорённости',
            subtitle:
                'currentUserId=${_currentUserId ?? 'null'}\n'
                'coupleId=${_agreementsCoupleId ?? 'null'}\n'
                'issueId=${widget.issueId}',
          );
        }

        final agreements = snapshot.data ?? const <Agreement>[];
        if (agreements.isEmpty) {
          return _buildAgreementsMessage(
            icon: Icons.handshake_outlined,
            title: 'Пока нет договорённостей по этой проблеме',
            subtitle:
                'currentUserId=${_currentUserId ?? 'null'}\n'
                'coupleId=${_agreementsCoupleId ?? 'null'}\n'
                'issueId=${widget.issueId}',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: agreements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _buildAgreementCard(agreements[index]),
        );
      },
    );
  }

  Widget _buildAgreementCard(Agreement agreement) {
    final currentUserId = _currentUserId;
    final canAccept =
        currentUserId != null && _canAcceptAgreement(agreement, currentUserId);
    final isAccepting = _acceptingAgreementId == agreement.id;
    final statusColor = _agreementStatusColor(agreement.status);

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

  String _agreementStreamErrorMessage(Object? error) {
    if (error == null) {
      return 'Проверьте подключение и попробуйте позже.';
    }
    return error.toString();
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
      _showAgreementError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showAgreementError('Не удалось принять договорённость.');
    } finally {
      if (mounted) {
        setState(() => _acceptingAgreementId = null);
      }
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

  bool _canAcceptAgreement(Agreement agreement, String currentUserId) {
    return agreement.isPending && agreement.proposedBy != currentUserId;
  }

  bool _hasAgreementDescription(Agreement agreement) {
    final description = agreement.description;
    return description != null && description.isNotEmpty;
  }

  String _agreementSubtitle(Agreement agreement, String? currentUserId) {
    if (currentUserId != null && agreement.proposedBy == currentUserId) {
      return agreement.isPending
          ? 'Ожидаем подтверждения партнёра'
          : 'Вы предложили';
    }

    if (_isAcceptedByCurrentUser(agreement)) {
      return 'Ожидаем подтверждения партнёра';
    }

    return agreement.isPending
        ? 'Партнёр предложил, ждёт вашего ответа'
        : 'Предложил партнёр';
  }

  bool _isAcceptedByCurrentUser(Agreement agreement) {
    final uid = _currentUserId;
    if (uid == null) return false;
    if (agreement.proposedBy == uid) return true;
    return agreement.isPending && !_canAcceptAgreement(agreement, uid);
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
      AgreementStatus.acceptedByOne => Icons.hourglass_empty_rounded,
      AgreementStatus.acceptedByBoth ||
      AgreementStatus.active => Icons.handshake_outlined,
      AgreementStatus.completed => Icons.check_circle_outline,
      AgreementStatus.failed => Icons.error_outline_rounded,
      AgreementStatus.archived => Icons.inventory_2_outlined,
      AgreementStatus.unknown => Icons.help_outline,
    };
  }

  Color _agreementStatusColor(AgreementStatus status) {
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
}

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
        'IssueChatScreen submit proposeAgreement issueId=${widget.issueId}, title=$title, checkIntervalDays=$_checkIntervalDays',
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
          // Handle bar
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

          // Title
          const Text(
            'Предложить договорённость',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Title field
          _buildLabel('Название'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _titleController,
            hint: 'Краткое название договорённости',
            maxLines: 2,
            maxLength: AgreementService.titleMaxLength,
          ),
          const SizedBox(height: 14),

          // Description field
          _buildLabel('Описание'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _descController,
            hint: 'Подробнее о договорённости',
            maxLines: 4,
            maxLength: AgreementService.descriptionMaxLength,
          ),
          const SizedBox(height: 16),

          // Interval selector
          _buildLabel('Интервал проверки'),
          const SizedBox(height: 8),
          _buildIntervalSelector(),
          const SizedBox(height: 24),

          // Propose button
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
        counterStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                width: 1,
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
    switch (days) {
      case 1:
        return '1 день';
      case 3:
        return '3 дня';
      case 7:
        return '7 дней';
      case 14:
        return '14 дней';
      case 30:
        return '30 дней';
      default:
        return '$days дней';
    }
  }
}
