import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/data/chore_templates_data.dart';
import '../../shared/models/chore_spin.dart';
import '../../shared/models/chore_task.dart';
import '../../shared/services/chore_service.dart';
import '../../shared/services/couple_service.dart';
import '../../shared/services/functions_service.dart';
import '../../shared/services/user_service.dart';
import '../../theme/app_colors.dart';

class ChoreRandomizerScreen extends StatefulWidget {
  const ChoreRandomizerScreen({super.key});

  @override
  State<ChoreRandomizerScreen> createState() => _ChoreRandomizerScreenState();
}

class _ChoreRandomizerScreenState extends State<ChoreRandomizerScreen> {
  final _choreService = ChoreService();
  final _userService = UserService();
  final _coupleService = CoupleService();

  String? _coupleId;
  String? _currentUserId;
  String? _partnerDisplayName;
  bool _loadingProfile = true;

  String? _selectedTaskId;
  bool _spinning = false;
  String? _lastSelectedUserId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (!mounted) return;

      if (user != null && user.currentCoupleId != null) {
        String? partnerName;
        try {
          final couple =
              await _coupleService.getCouple(user.currentCoupleId!);
          if (couple != null) {
            final partnerId = couple.partnerAId == uid
                ? couple.partnerBId
                : couple.partnerAId;
            if (partnerId != null) {
              final partner = await _userService.getUserProfile(partnerId);
              partnerName = partner?.displayName;
            }
          }
        } catch (_) {}

        setState(() {
          _coupleId = user.currentCoupleId;
          _currentUserId = uid;
          _partnerDisplayName = partnerName ?? 'Партнёр';
          _loadingProfile = false;
        });
      } else {
        setState(() {
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _spin() async {
    final taskId = _selectedTaskId;
    if (taskId == null) return;

    setState(() {
      _spinning = true;
      _lastSelectedUserId = null;
    });

    try {
      final selectedUid = await _choreService.spinChoreRandomizer(taskId);
      if (!mounted) return;
      setState(() {
        _lastSelectedUserId = selectedUid;
        _spinning = false;
      });
    } on FunctionsCallException catch (e) {
      if (!mounted) return;
      setState(() => _spinning = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _spinning = false);
      _showError('Не удалось запустить рандомайзер');
    }
  }

  Future<void> _deleteTask(ChoreTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Удалить задачу?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: Text(
          '"${task.title}" будет удалена из списка.\nИстория решений сохранится.',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить',
                style: TextStyle(color: AppColors.roseAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (_selectedTaskId == task.id) {
      setState(() => _selectedTaskId = null);
    }

    try {
      await _choreService.softDeleteChoreTask(task.id);
    } on FunctionsCallException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Не удалось удалить задачу');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.bgCardLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _openAddTaskSheet(String coupleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(
        choreService: _choreService,
        coupleId: coupleId,
      ),
    );
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
              Expanded(child: _buildBody()),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Кто делает?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingProfile) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    final coupleId = _coupleId;
    if (coupleId == null || coupleId.isEmpty) {
      return _buildNoCoupleState();
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.purple,
      backgroundColor: AppColors.bgCard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTasksSection(coupleId),
            const SizedBox(height: 20),
            _buildSpinButton(),
            const SizedBox(height: 20),
            _buildResultBlock(),
            const SizedBox(height: 28),
            _buildHistorySection(coupleId),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCoupleState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👫', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text(
              'Сначала создайте пару',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Бытовой рандомайзер доступен, когда оба партнёра подключены',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Tasks Section ──────────────────────────────────────────────────────────

  Widget _buildTasksSection(String coupleId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Список задач',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Text('🧹', style: TextStyle(fontSize: 16)),
            const Spacer(),
            GestureDetector(
              onTap: () => _openAddTaskSheet(coupleId),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Добавить',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<ChoreTask>>(
          stream: _choreService.watchChoreTasks(coupleId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.purple),
                ),
              );
            }

            final tasks = snapshot.data ?? [];
            if (tasks.isEmpty) {
              return _buildEmptyTasksState(coupleId);
            }

            return Column(
              children: tasks.map((task) => _buildTaskCard(task)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyTasksState(String coupleId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        children: [
          const Text('🏠', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 14),
          const Text(
            'Добавьте первую бытовую задачу',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Список задач общий для обоих партнёров',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _openAddTaskSheet(coupleId),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Добавить задачу',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(ChoreTask task) {
    final isSelected = _selectedTaskId == task.id;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedTaskId = isSelected ? null : task.id;
        _lastSelectedUserId = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.purple.withValues(alpha: 0.18)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.bgCardLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.purple.withValues(alpha: 0.2)
                    : AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(task.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildChip(task.category),
                      const SizedBox(width: 6),
                      _buildIntensityChip(task.intensity),
                      if (task.estimatedLabel != null) ...[
                        const SizedBox(width: 6),
                        _buildChip(task.estimatedLabel!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            GestureDetector(
              onTap: () => _deleteTask(task),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isSelected
                      ? AppColors.roseAccent
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildIntensityChip(ChoreIntensity intensity) {
    Color color;
    switch (intensity) {
      case ChoreIntensity.easy:
        color = const Color(0xFF66BB6A);
        break;
      case ChoreIntensity.medium:
        color = AppColors.lavender;
        break;
      case ChoreIntensity.annoying:
        color = AppColors.roseAccent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        intensity.label,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }

  // ── Spin Button ───────────────────────────────────────────────────────────

  Widget _buildSpinButton() {
    final hasSelection = _selectedTaskId != null;
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasSelection ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: hasSelection && !_spinning ? _spin : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: hasSelection
                  ? [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: _spinning
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎲',
                            style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Text(
                          'Решить',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  // ── Result Block ──────────────────────────────────────────────────────────

  Widget _buildResultBlock() {
    final selectedUid = _lastSelectedUserId;
    if (selectedUid == null) return const SizedBox.shrink();

    final isMe = selectedUid == _currentUserId;
    final name = isMe ? 'Ты' : (_partnerDisplayName ?? 'Партнёр');
    final emoji = isMe ? '😬' : '😄';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.25),
            AppColors.pinkPurple.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.purple.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          const Text(
            'Сегодня это делает:',
            style:
                TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── History Section ───────────────────────────────────────────────────────

  Widget _buildHistorySection(String coupleId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Последние решения',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ChoreSpin>>(
          stream: _choreService.watchRecentSpins(coupleId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.purple),
                ),
              );
            }

            final spins = snapshot.data ?? [];
            if (spins.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bgCardLight),
                ),
                child: const Column(
                  children: [
                    Text('📋',
                        style: TextStyle(fontSize: 32)),
                    SizedBox(height: 10),
                    Text(
                      'История пока пуста',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: spins
                  .map((spin) => _buildSpinHistoryCard(spin))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpinHistoryCard(ChoreSpin spin) {
    final isMe = spin.selectedUserId == _currentUserId;
    final name = isMe ? 'Ты' : (_partnerDisplayName ?? 'Партнёр');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Row(
        children: [
          Text(spin.displayEmoji,
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spin.displayTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(spin.spunAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.roseAccent.withValues(alpha: 0.15)
                  : AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMe ? AppColors.roseAccent : AppColors.lavender,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин назад';
    if (diff.inDays == 0) return 'Сегодня';
    if (diff.inDays == 1) return 'Вчера';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

// ── Add Task Bottom Sheet ──────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({
    required this.choreService,
    required this.coupleId,
  });

  final ChoreService choreService;
  final String coupleId;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _emojiController = TextEditingController(text: '🧹');

  String _selectedCategory = 'другое';
  String _selectedIntensity = 'medium';
  int? _estimatedMinutes;
  bool _loading = false;
  bool _showTemplates = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _applyTemplate(ChoreTemplate template) {
    setState(() {
      _titleController.text = template.title;
      _emojiController.text = template.emoji;
      _selectedCategory = template.category;
      _selectedIntensity = template.intensity;
      _estimatedMinutes = template.estimatedMinutes;
      _showTemplates = false;
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название задачи')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.choreService.createChoreTask(
        title: title,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        emoji: _emojiController.text.trim().isNotEmpty
            ? _emojiController.text.trim()
            : '🧹',
        category: _selectedCategory,
        intensity: _selectedIntensity,
        estimatedMinutes: _estimatedMinutes,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on FunctionsCallException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось добавить задачу')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Новая задача',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Template toggle
            GestureDetector(
              onTap: () => setState(() => _showTemplates = !_showTemplates),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('⚡',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Быстрые шаблоны',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      _showTemplates
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            if (_showTemplates) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: kChoreTemplates
                      .take(30)
                      .map((t) => _buildTemplateChip(t))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 16),
            ],

            // Emoji + Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji input
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: _emojiController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, color: AppColors.textPrimary),
                    maxLength: 4,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.bgCardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title input
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Название задачи *',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.bgCardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              controller: _descController,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Описание (необязательно)',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 14),
                filled: true,
                fillColor: AppColors.bgCardLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            const Text(
              'Категория',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kChoreCategories
                  .map((c) => _buildSelectableChip(
                        label: c,
                        selected: _selectedCategory == c,
                        onTap: () =>
                            setState(() => _selectedCategory = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Intensity
            const Text(
              'Сложность',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildIntensityButton('easy', 'Лёгкая', const Color(0xFF66BB6A)),
                const SizedBox(width: 8),
                _buildIntensityButton(
                    'medium', 'Обычная', AppColors.lavender),
                const SizedBox(width: 8),
                _buildIntensityButton(
                    'annoying', 'Бесячая', AppColors.roseAccent),
              ],
            ),
            const SizedBox(height: 16),

            // Estimated minutes
            const Text(
              'Примерное время',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [null, 5, 10, 15, 20, 30, 45, 60, 90]
                  .map((mins) => _buildSelectableChip(
                        label: mins == null ? 'Не указано' : '~$mins мин',
                        selected: _estimatedMinutes == mins,
                        onTap: () =>
                            setState(() => _estimatedMinutes = mins),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _loading ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Добавить',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(ChoreTemplate template) {
    return GestureDetector(
      onTap: () => _applyTemplate(template),
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(template.emoji,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              template.title,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.purple.withValues(alpha: 0.2)
              : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.purple : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                selected ? AppColors.lavender : AppColors.textSecondary,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityButton(
      String value, String label, Color color) {
    final selected = _selectedIntensity == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIntensity = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.2)
                : AppColors.bgCardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
