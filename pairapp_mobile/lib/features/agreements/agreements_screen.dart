import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/models/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/gradient_button.dart';

class AgreementsScreen extends StatefulWidget {
  const AgreementsScreen({super.key});

  @override
  State<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends State<AgreementsScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Все', 'Активные', 'Выполненные'];

  List<MockAgreement> get _filtered {
    return switch (_tabIndex) {
      1 => MockData.agreements.where((a) => a.status == 'active').toList(),
      2 => MockData.agreements.where((a) => a.status == 'done').toList(),
      _ => MockData.agreements,
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
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: _filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _buildAgreementCard(_filtered[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GradientButton(
                  label: 'Добавить договорённость',
                  icon: Icons.add,
                  width: double.infinity,
                  onTap: () {},
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 18),
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

  Widget _buildAgreementCard(MockAgreement agreement) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (agreement.status == 'active'
                      ? AppColors.purple
                      : AppColors.statusResolved)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              agreement.status == 'active'
                  ? Icons.handshake_outlined
                  : Icons.check_circle_outline,
              color: agreement.status == 'active'
                  ? AppColors.purple
                  : AppColors.statusResolved,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agreement.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Создал: ${agreement.createdBy}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          StatusBadge(status: agreement.status),
        ],
      ),
    );
  }
}
