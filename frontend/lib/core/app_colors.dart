import 'package:flutter/material.dart';

/// Colour tokens extracted directly from stitch_ai_github_readme_generator/code.html
abstract final class AppColors {
  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary          = Color(0xFF595B8C);
  static const Color primaryDim       = Color(0xFF4D4F7F);
  static const Color primaryContainer = Color(0xFFC4C4FC);
  static const Color primaryFixedDim  = Color(0xFFB6B7EE);
  static const Color onPrimary        = Color(0xFFFBF7FF);
  static const Color onPrimaryFixed   = Color(0xFF282957);

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary              = Color(0xFF5D5D72);
  static const Color secondaryDim           = Color(0xFF515166);
  static const Color secondaryContainer     = Color(0xFFE2E0F9);
  static const Color secondaryFixedDim      = Color(0xFFD4D2EB);
  static const Color onSecondaryContainer   = Color(0xFF505064);
  static const Color onSecondaryFixedVariant= Color(0xFF5A5A6F);

  // ── Tertiary ──────────────────────────────────────────────────────────────
  static const Color tertiary          = Color(0xFF745479);
  static const Color tertiaryContainer = Color(0xFFF5CDF9);

  // ── Surface / Background ──────────────────────────────────────────────────
  static const Color background              = Color(0xFFF7F9FB);
  static const Color surface                 = Color(0xFFF7F9FB);
  static const Color surfaceBright           = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow     = Color(0xFFF0F4F7);
  static const Color surfaceContainer        = Color(0xFFEAEFF2);
  static const Color surfaceContainerHigh    = Color(0xFFE3E9ED);
  static const Color surfaceContainerHighest = Color(0xFFDCE4E8);
  static const Color surfaceDim              = Color(0xFFD4DBDF);
  static const Color surfaceVariant          = Color(0xFFDCE4E8);

  // ── On-surface ────────────────────────────────────────────────────────────
  static const Color onSurface        = Color(0xFF2C3437);
  static const Color onSurfaceVariant = Color(0xFF596064);
  static const Color onBackground     = Color(0xFF2C3437);

  // ── Outline ───────────────────────────────────────────────────────────────
  static const Color outline        = Color(0xFF747C80);
  static const Color outlineVariant = Color(0xFFACB3B7);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error          = Color(0xFFA8364B);
  static const Color errorContainer = Color(0xFFF97386);

  // ── Inverse ───────────────────────────────────────────────────────────────
  static const Color inverseSurface   = Color(0xFF0B0F10);
  static const Color inverseOnSurface = Color(0xFF9A9D9F);

  // ── Helpers ───────────────────────────────────────────────────────────────
  /// Ambient shadow colour (on-surface @ 5% opacity)
  static const Color ambientShadow = Color(0x0D2C3437);
  static const Color slate600      = Color(0xFF475569);
  static const Color slate900      = Color(0xFF0F172A);
  static const Color slate50       = Color(0xFFF8FAFC);
}
