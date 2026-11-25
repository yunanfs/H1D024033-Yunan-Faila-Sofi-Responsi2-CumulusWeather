import 'package:flutter/material.dart';

/// Theme terpusat agar tampilan konsisten (Light & Dark, Material 3).
class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF3B82F6);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static List<Color> backgroundGradient(Brightness b) => b == Brightness.light
      ? const [Color(0xFFD6E2FF), Color(0xFFF5F7FF)]
      : const [Color(0xFF16275A), Color(0xFF0B1020)];

  static ThemeData _build(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final t = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      scaffoldBackgroundColor:
          b == Brightness.light ? const Color(0xFFF5F7FF) : const Color(0xFF0B1020),
      textTheme: t.copyWith(
        headlineLarge: t.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodySmall: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
