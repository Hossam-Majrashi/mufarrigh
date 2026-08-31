import 'package:flutter/material.dart';

/// Mufarrigh brand colors and theme.
class AppTheme {
  AppTheme._();

  // ── Exact Reference Color Palette ──────────────────────────────
  static const Color background         = Color(0xFF0C1716); // Main background
  static const Color surface            = Color(0xFF0C1716); // Main background / scaffold
  static const Color surfacePanelBg     = Color(0xFF152220); // Secondary background / panels
  static const Color surfaceCard        = Color(0xFF111E1C); // Cards / surfaces
  static const Color divider            = Color(0xFF16433F); // Borders
  static const Color border             = Color(0xFF16433F); // Borders alias
  
  static const Color accentPrimary      = Color(0xFF18C8BE); // Primary accent
  static const Color primaryAccent      = Color(0xFF18C8BE); // Primary accent alias
  static const Color accentSecondary    = Color(0xFF25AFA8); // Secondary accent
  static const Color secondaryAccent    = Color(0xFF25AFA8); // Secondary accent alias

  static const Color onSurface          = Color(0xFFE8F2F0); // Primary text
  static const Color primaryText        = Color(0xFFE8F2F0); // Primary text alias
  static const Color onSurfaceMid       = Color(0xFF8AA8A4); // Secondary text
  static const Color secondaryText      = Color(0xFF8AA8A4); // Secondary text alias
  static const Color onSurfaceDim       = Color(0xFF55716D); // Muted text
  static const Color mutedText          = Color(0xFF55716D); // Muted text alias

  static const Color hoverBg            = Color(0xFF123B37); // Hover / selected background
  static const Color selectedBg         = Color(0xFF123B37); // Hover / selected background alias

  static const Color primaryButton      = Color(0xFF18C8BE); // Primary button
  static const Color onPrimaryButton    = Color(0xFF061312); // Button text
  static const Color buttonText         = Color(0xFF061312); // Button text alias

  // Backward-compatible aliases
  static const Color primaryDeep        = Color(0xFF152220); // Secondary background / panel
  static const Color primaryMid         = Color(0xFF123B37); // Selected / panel highlight
  static const Color accentViolet       = Color(0xFF18C8BE); // Primary accent
  static const Color accentTeal         = Color(0xFF25AFA8); // Secondary accent
  static const Color accentAmber        = Color(0xFF18C8BE); // Active accent

  static const Color error              = Color(0xFFFF5757);
  static const Color success            = Color(0xFF18C8BE);

  // Checkerboard colors for transparency preview
  static const Color checkerLight       = Color(0xFF162523);
  static const Color checkerDark        = Color(0xFF0E1A18);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF152220), Color(0xFF0C1716)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF18C8BE), Color(0xFF25AFA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF152220), Color(0xFF111E1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Typography ────────────────────────────────────────────────
  static const String fontFamily = 'Cairo';

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: onSurface,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: onSurface,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: onSurfaceMid,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: onSurfaceMid,
    letterSpacing: 0.8,
  );

  // ── Theme ──────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        tertiary: accentSecondary,
        surface: surface,
        surfaceContainerLowest: surface,
        surfaceContainerLow: surfaceCard,
        surfaceContainer: surfaceCard,
        surfaceContainerHigh: surfacePanelBg,
        surfaceContainerHighest: surfacePanelBg,
        onSurface: onSurface,
        onPrimary: onPrimaryButton,
        error: error,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfacePanelBg,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: titleMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButton,
          foregroundColor: onPrimaryButton,
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentPrimary,
          minimumSize: const Size(120, 48),
          side: const BorderSide(color: divider, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: onSurfaceMid),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCard,
        modalBackgroundColor: surfaceCard,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentPrimary,
        thumbColor: accentPrimary,
        overlayColor: accentPrimary.withValues(alpha: 0.15),
        inactiveTrackColor: divider,
        trackHeight: 3,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onPrimaryButton : onSurfaceDim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accentPrimary
              : divider,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePanelBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentPrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: onSurfaceDim),
        labelStyle: const TextStyle(color: onSurfaceMid),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfacePanelBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: divider),
        ),
        textStyle: bodySmall,
      ),
    );
  }
}
