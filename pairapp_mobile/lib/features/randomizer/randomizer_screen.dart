import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/models/mock_data.dart';
import '../../shared/widgets/gradient_button.dart';

class RandomizerScreen extends StatefulWidget {
  const RandomizerScreen({super.key});

  @override
  State<RandomizerScreen> createState() => _RandomizerScreenState();
}

class _RandomizerScreenState extends State<RandomizerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  String _currentActivity = MockData.randomActivities[0];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextActivity() async {
    await _controller.forward();
    setState(() {
      _currentActivity = MockData.randomActivities[
          _random.nextInt(MockData.randomActivities.length)];
    });
    await _controller.reverse();
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGlowCircle(),
                      const SizedBox(height: 32),
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: _buildActivityCard(),
                      ),
                      const SizedBox(height: 40),
                      GradientButton(
                        label: 'Ещё вариант',
                        icon: Icons.refresh_rounded,
                        width: double.infinity,
                        height: 56,
                        onTap: _nextActivity,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border,
                            size: 16, color: AppColors.textMuted),
                        label: const Text(
                          'Сохранить идею',
                          style: TextStyle(color: AppColors.textMuted),
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
            child: Text(
              'Рандом занятие',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGlowCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.heartGlow,
          ),
        ),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.shuffle_rounded,
              color: Colors.white, size: 38),
        ),
      ],
    );
  }

  Widget _buildActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bgCardLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Идея для вас 💜',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentActivity,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
