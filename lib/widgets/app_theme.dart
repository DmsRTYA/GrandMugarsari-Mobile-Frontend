// lib/widgets/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const primary     = Color(0xFF1A1A2E);
  static const primaryDark = Color(0xFF0F3460);
  static const accent      = Color(0xFFC9A84C);
  static const accentLight = Color(0xFFF5E6B8);
  static const surface     = Color(0xFFF4F6FA);
  static const card        = Color(0xFFFFFFFF);
  static const textPri     = Color(0xFF1A1A2E);
  static const textSec     = Color(0xFF6B7280);
  static const divider     = Color(0xFFE5E7EB);
  static const error       = Color(0xFFE74C3C);
  static const success     = Color(0xFF2ECC71);

  static const booking     = Color(0xFFC9A84C);
  static const dikonfirmasi= Color(0xFF3498DB);
  static const checkInC    = Color(0xFF2ECC71);
  static const checkOutC   = Color(0xFF95A5A6);

  static Color statusColor(String s) {
    switch (s) {
      case 'Booking':      return booking;
      case 'Dikonfirmasi': return dikonfirmasi;
      case 'Check-In':     return checkInC;
      case 'Check-Out':    return checkOutC;
      default:             return textSec;
    }
  }

  static Color statusBg(String s) {
    switch (s) {
      case 'Booking':      return const Color(0xFFFDF8ED);
      case 'Dikonfirmasi': return const Color(0xFFEAF4FB);
      case 'Check-In':     return const Color(0xFFEAFAF1);
      case 'Check-Out':    return const Color(0xFFF2F3F4);
      default:             return surface;
    }
  }

  static ThemeData get theme => ThemeData(
    colorScheme: const ColorScheme.light(
      primary: primary, secondary: accent, surface: surface, error: error),
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary, foregroundColor: Colors.white, elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18,
          fontWeight: FontWeight.w600, letterSpacing: 0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: textSec),
    ),
    cardTheme: CardThemeData(
      elevation: 2, shadowColor: Colors.black12, color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
