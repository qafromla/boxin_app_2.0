import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand colors used across the app.
class AppColors {
  static const red = Color(0xFFE3241F);
  static const redDark = Color(0xFFB71C1C);
  static const green = Color(0xFF2EB24C);
  static const orange = Color(0xFFFF8A00);

  /// The word REST on the workout screen. Darker than [green] so it stays
  /// readable on the light background as well as the dark one.
  static const restText = Color(0xFF128A3E);

  // Light
  static const lightBackground = Color(0xFFF3F3F5);
  static const lightCard = Colors.white;
  static const lightMuted = Color(0xFFDADADF);

  // Dark
  static const darkBackground = Color(0xFF111114);
  static const darkCard = Color(0xFF1E1E23);
  static const darkMuted = Color(0xFF3A3A42);
}

/// Small helpers so widgets can pick the right color for the current theme.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get mutedColor => isDark ? AppColors.darkMuted : AppColors.lightMuted;
  Color get textColor => isDark ? Colors.white : const Color(0xFF16161A);
  Color get subtleTextColor =>
      isDark ? const Color(0xFFB4B4BC) : const Color(0xFF6B6B75);
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? Colors.white : const Color(0xFF16161A);

    // Status bar icons must contrast with the background (fixes invisible
    // icons in dark mode).
    final overlay = overlayFor(brightness);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        brightness: brightness,
        primary: AppColors.red,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: overlay,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
    );
  }

  static SystemUiOverlayStyle overlayFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          )
          : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          );
}
