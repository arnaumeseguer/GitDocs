import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBg = Color(0xFFF8FAFC);
const Color kSurface = Color(0xFFFFFFFF);
const Color kSurfaceLow = Color(0xFFF1F5F9);
const Color kSurfaceHigh = Color(0xFFE2E8F0);
const Color kOnSurface = Color(0xFF0F172A);
const Color kOnSurfaceMuted = Color(0xFF475569);
const Color kOnSurfaceFaint = Color(0xFF94A3B8);
const Color kAccent = Color(0xFF7C3AED);
const Color kPrimary = Color(0xFF0F766E);
const Color kPrimaryDim = Color(0xFF115E59);

final BoxShadow kIslandShadow = BoxShadow(
  color: Colors.black.withValues(alpha: 0.06),
  blurRadius: 18,
  offset: const Offset(0, 8),
);

final BoxShadow kIslandShadowHover = BoxShadow(
  color: Colors.black.withValues(alpha: 0.10),
  blurRadius: 22,
  offset: const Offset(0, 10),
);

TextStyle headline({double size = 24, Color color = kOnSurface}) {
  return GoogleFonts.manrope(
    fontSize: size,
    fontWeight: FontWeight.w800,
    color: color,
    height: 1.1,
  );
}

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kBg,
    colorScheme: base.colorScheme.copyWith(
      primary: kPrimary,
      secondary: kAccent,
      surface: kSurface,
    ),
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: kOnSurface,
      displayColor: kOnSurface,
    ),
    dividerTheme: const DividerThemeData(color: kSurfaceHigh, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
