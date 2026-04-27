import 'package:flutter/material.dart';

class AppColors {
  // Brand / seed color (professional blue).
  static const primaryLight = Color(0xFF2563EB); // Blue 600
  static const primaryDark = Color(0xFF60A5FA); // Blue 400

  // Neutral surfaces tuned for Material 3.
  static const backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const backgroundDark = Color(0xFF0B1220); // Deep navy

  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF0F172A); // Slate 900

  static const textPrimaryLight = Color(0xFF000000);
  static const textPrimaryDark = Color(0xFFE2E8F0); // Slate 200

  static const textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  static const chatBubbleSenderLight = primaryLight;
  static const chatBubbleSenderDark = primaryDark;
  static const chatBubbleReceiverLight = Color(0xFFEFF6FF); // Blue 50
  static const chatBubbleReceiverDark = Color(0xFF111C33); // Slightly lifted dark surface
}
