import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.bgCardLight,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
