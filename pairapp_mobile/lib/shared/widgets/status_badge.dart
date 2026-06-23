import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'open' => ('Открыта', AppColors.statusOpen),
      'discussion' => ('Обсуждение', AppColors.statusDiscussion),
      'resolved' => ('Решена', AppColors.statusResolved),
      'active' => ('Активно', AppColors.statusOpen),
      'done' => ('Выполнено', AppColors.statusResolved),
      _ => (status, AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
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
