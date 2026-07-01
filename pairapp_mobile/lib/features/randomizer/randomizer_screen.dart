import 'package:flutter/material.dart';

import '../../shared/models/activity_idea.dart';
import '../../shared/models/app_user.dart';
import '../../shared/services/activity_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../theme/app_colors.dart';

class RandomizerScreen extends StatefulWidget {
  const RandomizerScreen({super.key});

  @override
  State<RandomizerScreen> createState() => _RandomizerScreenState();
}

class _RandomizerScreenState extends State<RandomizerScreen>
    with SingleTickerProviderStateMixin {
  final _activityService = ActivityService();
  final _userService = UserService();

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  AppUser? _currentUser;
  ActivityIdea? _currentIdea;
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _loadAndShow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAndShow() async {
    final user = await _userService.getCurrentUserProfile();
    if (!mounted) return;
    setState(() => _currentUser = user);
    _showNewIdea();
  }

  void _showNewIdea() {
    final idea = _activityService.randomIdea(
      category: _selectedCategory,
      excludeId: _currentIdea?.id,
    );
    setState(() => _currentIdea = idea);
    _controller.forward(from: 0);
  }

  void _selectCategory(String? category) {
    if (_selectedCategory == category) {
      setState(() => _selectedCategory = null);
    } else {
      setState(() => _selectedCategory = category);
    }
    _showNewIdea();
  }

  Future<void> _saveIdea() async {
    final idea = _currentIdea;
    if (idea == null) return;

    final user = _currentUser;
    if (user == null || !user.hasCouple) {
      _showSnackBar('Сначала создайте пару 💜');
      return;
    }

    setState(() => _isSaving = true);
    final result = await _activityService.saveIdea(idea);
    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case SaveIdeaResult.saved:
        _showSnackBar('Идея сохранена ❤️');
      case SaveIdeaResult.alreadySaved:
        _showSnackBar('Эта идея уже сохранена');
      case SaveIdeaResult.error:
        _showSnackBar('Не удалось сохранить. Попробуйте ещё раз');
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.bgCardLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              _buildCategoryChips(),
              Expanded(
                child: _currentIdea == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.purple,
                        ),
                      )
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
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
              'Идеи для нас',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = _activityService.allCategories;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => _selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.purple : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.purple : AppColors.bgCardLight,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final idea = _currentIdea!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildIdeaCard(idea),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(ActivityIdea idea) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bgCardLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji + категория
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    idea.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: idea.categories
                          .take(2)
                          .map((c) => _smallChip(c, AppColors.purple))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      idea.vibeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            idea.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            idea.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          // Preparation hint
          if (idea.preparation != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📌 ', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Text(
                      idea.preparation!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Meta chips: duration / budget
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(Icons.access_time_rounded, idea.durationLabel),
              _metaChip(
                idea.budget == ActivityBudget.free
                    ? Icons.money_off_rounded
                    : Icons.payments_outlined,
                idea.budgetLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        GradientButton(
          label: 'Ещё идея',
          icon: Icons.shuffle_rounded,
          width: double.infinity,
          height: 54,
          onTap: _showNewIdea,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _saveIdea,
            icon: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.roseAccent,
                    ),
                  )
                : const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: AppColors.roseAccent,
                  ),
            label: Text(
              _isSaving ? 'Сохраняем...' : 'Сохранить ❤️',
              style: const TextStyle(
                color: AppColors.roseAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.roseAccent,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
