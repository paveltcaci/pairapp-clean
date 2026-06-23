import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgDeep = Color(0xFF0A0B14);
  static const Color bgSurface = Color(0xFF111228);
  static const Color bgCard = Color(0xFF181A2E);
  static const Color bgCardLight = Color(0xFF1E2040);

  // Accents
  static const Color purple = Color(0xFF7C5CFC);
  static const Color purpleLight = Color(0xFF9D7FFF);
  static const Color lavender = Color(0xFFB79CFF);
  static const Color pinkPurple = Color(0xFFD46FFF);
  static const Color roseAccent = Color(0xFFFF6B9D);

  // Text
  static const Color textPrimary = Color(0xFFF0EEFF);
  static const Color textSecondary = Color(0xFF9B98C4);
  static const Color textMuted = Color(0xFF5C5A80);

  // Status
  static const Color statusOpen = Color(0xFF7C5CFC);
  static const Color statusDiscussion = Color(0xFFFFB74D);
  static const Color statusResolved = Color(0xFF66BB6A);

  // Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFFD46FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0B14), Color(0xFF0F1020)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient heartGlow = RadialGradient(
    colors: [Color(0x557C5CFC), Color(0x22D46FFF), Colors.transparent],
    radius: 0.8,
  );
}
