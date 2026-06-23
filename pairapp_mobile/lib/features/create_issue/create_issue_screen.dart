import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/gradient_button.dart';

class CreateIssueScreen extends StatefulWidget {
  const CreateIssueScreen({super.key});

  @override
  State<CreateIssueScreen> createState() => _CreateIssueScreenState();
}

class _CreateIssueScreenState extends State<CreateIssueScreen> {
  int _importance = 3;
  String? _selectedCategory;
  String? _selectedFeeling;

  final _categories = ['Время', 'Финансы', 'Быт', 'Общение', 'Интимность', 'Семья'];
  final _feelings = ['Грустно 😢', 'Тревожно 😰', 'Обидно 😔', 'Злюсь 😤', 'Растерян 😕'];

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildField(
                        label: 'Что вас беспокоит?',
                        hint: 'Опишите проблему кратко...',
                        maxLines: 1,
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        label: 'Описание',
                        hint: 'Расскажите подробнее — что происходит, когда это началось...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Категория'),
                      const SizedBox(height: 10),
                      _buildChips(_categories, _selectedCategory,
                          (v) => setState(() => _selectedCategory = v)),
                      const SizedBox(height: 20),
                      _buildLabel('Как вы себя чувствуете?'),
                      const SizedBox(height: 10),
                      _buildChips(_feelings, _selectedFeeling,
                          (v) => setState(() => _selectedFeeling = v)),
                      const SizedBox(height: 20),
                      _buildLabel('Важность'),
                      const SizedBox(height: 12),
                      _buildImportanceSlider(),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: 'Создать проблему',
                        icon: Icons.add_circle_outline,
                        width: double.infinity,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 24),
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
            icon: const Icon(Icons.close,
                color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              'Новая проблема',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildChips(
    List<String> items,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.purpleGradient : null,
              color: isSelected ? null : AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.bgCardLight),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImportanceSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final val = i + 1;
            final selected = val <= _importance;
            return GestureDetector(
              onTap: () => setState(() => _importance = val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.purpleGradient : null,
                  color: selected ? null : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppColors.bgCardLight,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Маловажно',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text('Очень важно',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}
