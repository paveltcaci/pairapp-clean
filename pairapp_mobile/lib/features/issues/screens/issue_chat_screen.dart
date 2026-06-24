import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../shared/models/agreement.dart';
import '../../../shared/models/issue_message.dart';
import '../../../shared/models/mock_data.dart';
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

  late final Stream<List<IssueMessage>> _messagesStream;
  Stream<List<Agreement>>? _agreementsStream;
  bool _isSending = false;
  IssueMessageType _selectedMessageType = IssueMessageType.comment;

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messagesStream = _issueService.watchIssueMessages(widget.issueId);
    _loadCoupleIdAndSubscribe();
  }

  Future<void> _loadCoupleIdAndSubscribe() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      if (!mounted) return;

      final coupleId = user?.currentCoupleId;
      if (coupleId == null || coupleId.isEmpty) return;

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
          const AgreementServiceException('Не удалось проверить договорённости'),
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
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red.shade900,
            ),
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
                  children: [
                    _buildChatTab(),
                    _buildAgreementsTab(),
                  ],
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
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 18),
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
        final isAgreementCheckLoading = _agreementsStream == null ||
            agreementSnapshot.connectionState == ConnectionState.waiting;
        final isAgreementCheckFailed = agreementSnapshot.hasError;
        final hasBlockingAgreement = agreementSnapshot.hasData &&
            agreementSnapshot.data!.any(
              (agreement) =>
                  agreement.isPending || agreement.isAccepted || agreement.isActive,
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
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
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
            else
              _buildProposeButton(message, isMe: isMe),
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
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textMuted,
          ),
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

  Widget _buildProposeButton(IssueMessage message, {required bool isMe}) {
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
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
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : AppColors.bgCard,
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
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: MockData.agreements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final a = MockData.agreements[i];
        return AppCard(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (a.status == 'active'
                          ? AppColors.purple
                          : AppColors.statusResolved)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  a.status == 'active'
                      ? Icons.handshake_outlined
                      : Icons.check_circle_outline,
                  color: a.status == 'active'
                      ? AppColors.purple
                      : AppColors.statusResolved,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Создал: ${a.createdBy}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: a.status),
            ],
          ),
        );
      },
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

  @override
  void initState() {
    super.initState();
    final text = widget.solutionText;
    _titleController = TextEditingController(
      text: text.length > 60 ? '${text.substring(0, 60)}...' : text,
    );
    _descController = TextEditingController(text: text);
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

    setState(() => _isLoading = true);

    try {
      await widget.agreementService.proposeAgreement(
        issueId: widget.issueId,
        title: title,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
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
          ),
          const SizedBox(height: 14),

          // Description field
          _buildLabel('Описание'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _descController,
            hint: 'Подробнее о договорённости',
            maxLines: 4,
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
                  gradient: _isLoading
                      ? null
                      : AppColors.purpleGradient,
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
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.purple.withValues(alpha: 0.18)
                  : const Color(0xFF2D2D3A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.purple
                    : const Color(0xFF3D3D50),
                width: 1,
              ),
            ),
            child: Text(
              _intervalLabel(days),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.purple
                    : AppColors.textMuted,
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
