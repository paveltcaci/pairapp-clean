import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/models/mock_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

class IssueChatScreen extends StatefulWidget {
  final MockIssue issue;

  const IssueChatScreen({super.key, required this.issue});

  @override
  State<IssueChatScreen> createState() => _IssueChatScreenState();
}

class _IssueChatScreenState extends State<IssueChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _msgController = TextEditingController();
  final List<MockMessage> _messages = List.from(MockData.messages);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _msgController.dispose();
    super.dispose();
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
                  widget.issue.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StatusBadge(status: widget.issue.status),
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
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _buildBubble(_messages[i]),
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildBubble(MockMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: msg.isMe ? AppColors.purpleGradient : null,
          color: msg.isMe ? null : AppColors.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
          border: msg.isMe
              ? null
              : Border.all(color: AppColors.bgCardLight),
          boxShadow: msg.isMe
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 14,
            color: msg.isMe ? Colors.white : AppColors.textPrimary,
          ),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Напишите сообщение...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_msgController.text.isNotEmpty) {
                setState(() {
                  _messages.add(MockMessage(
                    text: _msgController.text,
                    isMe: true,
                    time: DateTime.now(),
                  ));
                  _msgController.clear();
                });
              }
            },
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
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
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
