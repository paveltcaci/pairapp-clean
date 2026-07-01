import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/data/quiz_questions_data.dart';
import '../../shared/models/quiz_question.dart';
import '../../shared/models/quiz_round.dart';
import '../../shared/services/functions_service.dart';
import '../../shared/services/quiz_service.dart';
import '../../shared/services/user_service.dart';
import '../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Session-scoped flags (reset on app restart)
// ─────────────────────────────────────────────────────────────────────────────

/// Показывать confirm-диалог "Близость 18+" только один раз за сессию.
bool _quizAdultConfirmShownInSession = false;

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _userService = UserService();
  final _quizService = QuizService();

  String? _coupleId;
  String? _currentUserId;
  bool _loading = true;

  // Локально управляем, какой раунд сейчас показан на экране.
  // Это НЕ производная от watchActiveRound(), потому что тот стрим
  // перестаёт возвращать раунд, как только он становится completed —
  // а нам как раз в этот момент нужно показать reveal, а не список категорий.
  String? _viewingRoundId;
  final Set<String> _dismissedRoundIds = {};
  StreamSubscription<QuizRound?>? _activeRoundSub;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _activeRoundSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (!mounted) return;
      setState(() {
        _coupleId = user?.currentCoupleId;
        _currentUserId = uid;
        _loading = false;
      });
      final coupleId = _coupleId;
      if (coupleId != null && coupleId.isNotEmpty) {
        _watchForActiveRound(coupleId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Слушает активный (waiting_both / waiting_partner) раунд пары и
  /// автоматически открывает его, если сейчас ничего не показывается.
  /// Не переоткрывает раунд, который пользователь только что закрыл сам.
  void _watchForActiveRound(String coupleId) {
    _activeRoundSub?.cancel();
    _activeRoundSub = _quizService.watchActiveRound(coupleId).listen((round) {
      if (!mounted) return;
      if (round != null &&
          _viewingRoundId == null &&
          !_dismissedRoundIds.contains(round.id)) {
        setState(() => _viewingRoundId = round.id);
      }
    });
  }

  void _openRound(String roundId) {
    setState(() => _viewingRoundId = roundId);
  }

  void _exitToCategories() {
    final leaving = _viewingRoundId;
    setState(() {
      if (leaving != null) _dismissedRoundIds.add(leaving);
      _viewingRoundId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.purple))
              : _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final coupleId = _coupleId;
    final uid = _currentUserId;

    if (coupleId == null || coupleId.isEmpty || uid == null) {
      return _buildNoCoupleState();
    }

    final viewingRoundId = _viewingRoundId;
    if (viewingRoundId != null) {
      return _ActiveRoundView(
        key: ValueKey(viewingRoundId),
        roundId: viewingRoundId,
        uid: uid,
        coupleId: coupleId,
        quizService: _quizService,
        onExitToCategories: _exitToCategories,
        onOpenRound: _openRound,
      );
    }

    // No active round being viewed — show categories
    return _CategoryPickerView(
      coupleId: coupleId,
      uid: uid,
      quizService: _quizService,
      onOpenRound: _openRound,
    );
  }

  Widget _buildNoCoupleState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👫', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Квизы для пары',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Пригласите партнёра, чтобы начать квизы вместе',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Picker
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPickerView extends StatelessWidget {
  const _CategoryPickerView({
    required this.coupleId,
    required this.uid,
    required this.quizService,
    required this.onOpenRound,
  });

  final String coupleId;
  final String uid;
  final QuizService quizService;
  final ValueChanged<String> onOpenRound;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Back button + title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Квизы для пары',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Выберите категорию',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemCount: kQuizCategories.length,
            itemBuilder: (context, i) {
              final cat = kQuizCategories[i];
              return _CategoryCard(
                category: cat,
                onTap: () => _onCategoryTap(context, cat),
              );
            },
          ),
          const SizedBox(height: 32),
          // History section
          _CompletedRoundsSection(
              coupleId: coupleId, uid: uid, quizService: quizService),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _onCategoryTap(BuildContext context, QuizCategory cat) {
    if (cat.isAdult && !_quizAdultConfirmShownInSession) {
      _showAdultConfirm(context, cat);
    } else {
      _openCategory(context, cat);
    }
  }

  void _showAdultConfirm(BuildContext context, QuizCategory cat) {
    _quizAdultConfirmShownInSession = true;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🔞', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Близость 18+',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Эта категория только для взрослых партнёров. '
          'Вопросы посвящены личным границам, желаниям и близости.\n\n'
          'Продолжить?',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openCategory(context, cat);
            },
            child: Text(
              'Продолжить',
              style: TextStyle(
                color: Color(cat.gradient[0]),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCategory(BuildContext context, QuizCategory cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _QuestionPickerScreen(
          category: cat,
          coupleId: coupleId,
          uid: uid,
          quizService: quizService,
          onOpenRound: onOpenRound,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Card
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final QuizCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradient = quizCategoryGradient(category);
    final baseColor = Color(category.gradient[0]);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Soft glow accent in the corner for a livelier, less flat look
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon bubble
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    if (category.isAdult)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded,
                                size: 10, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              '18+',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  category.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                if (category.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    category.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question Picker (random question from category)
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionPickerScreen extends StatefulWidget {
  const _QuestionPickerScreen({
    required this.category,
    required this.coupleId,
    required this.uid,
    required this.quizService,
    required this.onOpenRound,
  });

  final QuizCategory category;
  final String coupleId;
  final String uid;
  final QuizService quizService;
  final ValueChanged<String> onOpenRound;

  @override
  State<_QuestionPickerScreen> createState() => _QuestionPickerScreenState();
}

class _QuestionPickerScreenState extends State<_QuestionPickerScreen> {
  late QuizQuestion _currentQuestion;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    _pickRandomQuestion();
  }

  void _pickRandomQuestion() {
    final q = randomQuestionFromCategory(widget.category.id);
    if (q != null) {
      setState(() => _currentQuestion = q);
    }
  }

  Future<void> _launchRound() async {
    if (_launching) return;
    setState(() => _launching = true);
    try {
      final roundId = await widget.quizService.createQuizRound(
        category: widget.category.id,
        questionId: _currentQuestion.id,
        questionText: _currentQuestion.text,
        answerType: _currentQuestion.answerType.firestoreValue,
        options: _currentQuestion.options
            ?.map((o) => {'id': o.id, 'text': o.text})
            .toList(),
      );
      if (!mounted) return;
      // Open the round immediately, then pop back to QuizScreen.
      widget.onOpenRound(roundId);
      Navigator.pop(context);
    } on FunctionsCallException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Не удалось запустить вопрос. Попробуйте ещё раз.');
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.bgCardLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gradient = quizCategoryGradient(widget.category);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.category.emoji} ${widget.category.title.replaceAll('\n', ' ')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Question card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Color(widget.category.gradient[0])
                                  .withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.category.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _currentQuestion.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _currentQuestion.answerType ==
                                        QuizAnswerType.openText
                                    ? '✏️ Свободный ответ'
                                    : '🎯 Выбор варианта',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Shuffle button
                      GestureDetector(
                        onTap: _pickRandomQuestion,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.bgCardLight),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shuffle_rounded,
                                  color: AppColors.textSecondary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Другой вопрос',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Launch button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _launching ? null : _launchRound,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(widget.category.gradient[0])
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _launching
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Text(
                                      'Задать вопрос партнёру',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Round View
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveRoundView extends StatelessWidget {
  const _ActiveRoundView({
    super.key,
    required this.roundId,
    required this.uid,
    required this.coupleId,
    required this.quizService,
    required this.onExitToCategories,
    required this.onOpenRound,
  });

  final String roundId;
  final String uid;
  final String coupleId;
  final QuizService quizService;
  final VoidCallback onExitToCategories;
  final ValueChanged<String> onOpenRound;

  @override
  Widget build(BuildContext context) {
    // Watch by round id directly — this keeps working even after the round
    // becomes `completed` and drops out of the watchActiveRound() query,
    // which is what used to make the quiz screen snap back to the category
    // grid right when the reveal should appear.
    return StreamBuilder<QuizRound?>(
      stream: quizService.watchRound(roundId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.purple),
          );
        }
        final round = snap.data;
        if (round == null) {
          // Round no longer exists — bounce back to categories safely.
          WidgetsBinding.instance
              .addPostFrameCallback((_) => onExitToCategories());
          return const Center(
            child: CircularProgressIndicator(color: AppColors.purple),
          );
        }
        return _buildRoundContent(context, round);
      },
    );
  }

  Widget _buildRoundContent(BuildContext context, QuizRound round) {
    final iHaveAnswered = round.hasAnswered(uid);

    if (round.isCompleted) {
      return _RevealView(
        round: round,
        uid: uid,
        coupleId: coupleId,
        quizService: quizService,
        onExitToCategories: onExitToCategories,
        onOpenRound: onOpenRound,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: onExitToCategories,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Активный вопрос',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question card
          _QuestionCard(round: round),

          const SizedBox(height: 20),

          // Status / answer form
          if (!iHaveAnswered)
            _AnswerForm(
              round: round,
              uid: uid,
              quizService: quizService,
            )
          else
            _WaitingView(round: round, uid: uid),

          const SizedBox(height: 20),

          // Secondary CTA — lets you browse other categories while this
          // round is still pending; it keeps running in the background.
          Center(
            child: TextButton(
              onPressed: onExitToCategories,
              child: const Text(
                'К категориям',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question Card (in round)
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.round});
  final QuizRound round;

  @override
  Widget build(BuildContext context) {
    // Find category for gradient
    final cat = kQuizCategories.firstWhere(
      (c) => c.id == round.category,
      orElse: () => kQuizCategories.first,
    );
    final gradient = quizCategoryGradient(cat);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(cat.gradient[0]).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(cat.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            round.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Answer Form
// ─────────────────────────────────────────────────────────────────────────────

class _AnswerForm extends StatefulWidget {
  const _AnswerForm({
    required this.round,
    required this.uid,
    required this.quizService,
  });
  final QuizRound round;
  final String uid;
  final QuizService quizService;

  @override
  State<_AnswerForm> createState() => _AnswerFormState();
}

class _AnswerFormState extends State<_AnswerForm> {
  final _textCtrl = TextEditingController();
  String? _selectedOptionId;
  bool _submitting = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  bool get _isChoice => widget.round.answerType == 'choice';

  Future<void> _submit() async {
    final answer =
        _isChoice ? _selectedOptionId : _textCtrl.text.trim();
    if (answer == null || answer.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await widget.quizService.submitQuizAnswer(
        roundId: widget.round.id,
        answer: answer,
      );
    } on FunctionsCallException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: AppColors.bgCardLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Не удалось отправить ответ'),
        backgroundColor: AppColors.bgCardLight,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Partner already answered banner
    final partnerUid = widget.round.partnerOf(widget.uid);
    final partnerAnswered = widget.round.hasAnswered(partnerUid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (partnerAnswered) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('⚡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Партнёр уже ответил. Твоя очередь!',
                    style: TextStyle(
                      color: AppColors.lavender,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Answer input
        if (_isChoice)
          _buildChoiceOptions()
        else
          _buildTextInput(),

        const SizedBox(height: 16),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: _submitting ? null : _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Ответить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: TextField(
        controller: _textCtrl,
        maxLines: 4,
        minLines: 3,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 15, height: 1.5),
        decoration: const InputDecoration(
          hintText: 'Напишите свой ответ...',
          hintStyle: TextStyle(color: AppColors.textMuted),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildChoiceOptions() {
    return Column(
      children: widget.round.options.map((opt) {
        final isSelected = _selectedOptionId == opt['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedOptionId = opt['id']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.purple.withValues(alpha: 0.2)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.purple
                    : AppColors.bgCardLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    opt['text'] ?? '',
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.purple, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Waiting View (I answered, waiting for partner)
// ─────────────────────────────────────────────────────────────────────────────

class _WaitingView extends StatelessWidget {
  const _WaitingView({required this.round, required this.uid});
  final QuizRound round;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        children: [
          // Animated dots indicator
          const _PulsingDots(),
          const SizedBox(height: 20),
          const Text(
            'Ответ сохранён ✓',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ждём ответа партнёра...\nКак только он(а) ответит — увидите оба ответа',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Мой ответ: ${round.answerOf(uid) ?? ""}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.lavender,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final offset = (i / 3 * 2 * pi);
          final value =
              (sin(_anim.value * pi + offset) * 0.5 + 0.5).clamp(0.3, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: value),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reveal View (both answered)
// ─────────────────────────────────────────────────────────────────────────────

class _RevealView extends StatelessWidget {
  const _RevealView({
    required this.round,
    required this.uid,
    required this.coupleId,
    required this.quizService,
    required this.onExitToCategories,
    required this.onOpenRound,
  });
  final QuizRound round;
  final String uid;
  final String coupleId;
  final QuizService quizService;
  final VoidCallback onExitToCategories;
  final ValueChanged<String> onOpenRound;

  @override
  Widget build(BuildContext context) {
    final partnerUid = round.partnerOf(uid);
    final myAnswer = round.answerOf(uid) ?? '';
    final partnerAnswer = round.answerOf(partnerUid) ?? '';
    final isChoice = round.answerType == 'choice';
    final matched = round.matched;

    // Resolve option labels for choice type
    String resolveLabel(String answerId) {
      if (!isChoice) return answerId;
      final opt =
          round.options.where((o) => o['id'] == answerId).firstOrNull;
      return opt?['text'] ?? answerId;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: onExitToCategories,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Результат',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question recap
          _QuestionCard(round: round),

          const SizedBox(height: 20),

          // Match banner (for choice)
          if (isChoice && matched != null) ...[
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: matched
                    ? const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    matched ? '❤️ Совпало!' : '🌊 Не совпало',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    matched
                        ? 'Вы думаете одинаково в этом вопросе!'
                        : 'Но теперь вы знаете друг друга лучше',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Answers
          _buildAnswerCard(
            label: 'Твой ответ',
            answer: resolveLabel(myAnswer),
            color: AppColors.purple,
          ),
          const SizedBox(height: 10),
          _buildAnswerCard(
            label: 'Ответ партнёра',
            answer: resolveLabel(partnerAnswer),
            color: AppColors.roseAccent,
          ),

          const SizedBox(height: 28),

          // Next question button — jumps straight into another question
          // from the same category.
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                final cat = kQuizCategories.firstWhere(
                  (c) => c.id == round.category,
                  orElse: () => kQuizCategories.first,
                );
                onExitToCategories();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _QuestionPickerScreen(
                      category: cat,
                      coupleId: coupleId,
                      uid: uid,
                      quizService: quizService,
                      onOpenRound: onOpenRound,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Следующий вопрос',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary action — back to the full category grid.
          Center(
            child: TextButton(
              onPressed: onExitToCategories,
              child: const Text(
                'К категориям',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAnswerCard({
    required String label,
    required String answer,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Completed Rounds History Section
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedRoundsSection extends StatelessWidget {
  const _CompletedRoundsSection({
    required this.coupleId,
    required this.uid,
    required this.quizService,
  });

  final String coupleId;
  final String uid;
  final QuizService quizService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'История вопросов',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<QuizRound>>(
          stream: quizService.watchCompletedRounds(coupleId, limit: 10),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.purple)),
              );
            }
            final rounds = snap.data ?? [];
            if (rounds.isEmpty) {
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
                    Text('🎲', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 10),
                    Text(
                      'Пока нет завершённых вопросов',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: rounds.map((r) => _HistoryCard(round: r, uid: uid)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.round, required this.uid});
  final QuizRound round;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final cat = kQuizCategories.firstWhere(
      (c) => c.id == round.category,
      orElse: () => kQuizCategories.first,
    );
    final isChoice = round.answerType == 'choice';
    final matched = round.matched;

    return GestureDetector(
      onTap: () => _openDetail(context, cat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: Row(
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    round.questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isChoice && matched != null)
                    Text(
                      matched ? '❤️ Совпало' : '🌊 Не совпало',
                      style: TextStyle(
                        fontSize: 11,
                        color: matched
                            ? AppColors.statusResolved
                            : AppColors.lavender,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, QuizCategory cat) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HistoryDetailSheet(round: round, uid: uid, category: cat),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Detail Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryDetailSheet extends StatelessWidget {
  const _HistoryDetailSheet({
    required this.round,
    required this.uid,
    required this.category,
  });

  final QuizRound round;
  final String uid;
  final QuizCategory category;

  @override
  Widget build(BuildContext context) {
    final partnerUid = round.partnerOf(uid);
    final myAnswer = round.answerOf(uid) ?? '';
    final partnerAnswer = round.answerOf(partnerUid) ?? '';
    final isChoice = round.answerType == 'choice';
    final matched = round.matched;

    String resolveLabel(String answerId) {
      if (!isChoice) return answerId;
      final opt =
          round.options.where((o) => o['id'] == answerId).firstOrNull;
      return opt?['text'] ?? answerId;
    }

    final completedAt = round.completedAt;
    final dateLabel = completedAt != null
        ? DateFormat('d MMMM, HH:mm', 'ru').format(completedAt)
        : '';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.title.replaceAll('\n', ' '),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusResolved.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Завершено',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusResolved,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                round.questionText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              if (dateLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  dateLabel,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 20),
              if (isChoice && matched != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: matched
                        ? const LinearGradient(colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF43A047),
                          ])
                        : const LinearGradient(colors: [
                            Color(0xFF5C6BC0),
                            Color(0xFF7986CB),
                          ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    matched ? '❤️ Совпало' : '🌊 Не совпало',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildAnswerCard(
                label: 'Твой ответ',
                answer: resolveLabel(myAnswer),
                color: AppColors.purple,
              ),
              const SizedBox(height: 10),
              _buildAnswerCard(
                label: 'Ответ партнёра',
                answer: resolveLabel(partnerAnswer),
                color: AppColors.roseAccent,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerCard({
    required String label,
    required String answer,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
