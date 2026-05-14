import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimary = Color(0xFF1E293B);
const kPrimaryDim = Color(0xFF334155);
const kPrimaryLight = Color(0xFF475569);
const kAccent = Color(0xFF6366F1);
const kBg = Color(0xFFF8FAFC);
const kSurface = Color(0xFFFFFFFF);
const kSurfaceLow = Color(0xFFF1F5F9);
const kSurfaceHigh = Color(0xFFE2E8F0);
const kOnSurface = Color(0xFF0F172A);
const kOnSurfaceMuted = Color(0xFF64748B);
const kOnSurfaceFaint = Color(0xFF94A3B8);

final kIslandShadow = BoxShadow(
  color: const Color(0xFF0F172A).withOpacity(0.07),
  blurRadius: 24,
  offset: const Offset(0, 4),
);

final kIslandShadowHover = BoxShadow(
  color: const Color(0xFF0F172A).withOpacity(0.12),
  blurRadius: 32,
  offset: const Offset(0, 8),
);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.light(
      primary: kPrimary,
      secondary: kAccent,
      surface: kSurface,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );
}

TextStyle headline({double size = 16, FontWeight weight = FontWeight.w800}) =>
    GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: kOnSurface);

TextStyle mono({double size = 12}) =>
    TextStyle(fontFamily: 'JetBrains Mono', fontSize: size, color: kOnSurface);
