import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF1B6CA8);       // trustworthy blue
  static const primaryLight = Color(0xFF4A90D9);
  static const primaryDark = Color(0xFF0D4F80);

  static const secondary = Color(0xFF2ECC71);     // health green
  static const secondaryLight = Color(0xFF58D68D);

  static const accent = Color(0xFFFF8C00);        // warm orange for CTAs

  static const background = Color(0xFFF5F7FA);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFEEF2F7);

  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFFB0B8C4);

  static const error = Color(0xFFE53E3E);
  static const warning = Color(0xFFED8936);
  static const success = Color(0xFF38A169);

  static const divider = Color(0xFFE2E8F0);

  // Chat bubbles
  static const userBubble = Color(0xFF1B6CA8);
  static const assistantBubble = Color(0xFFEEF2F7);

  // Emergency red
  static const emergency = Color(0xFFE53E3E);
}
