import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CANCARE THEME SYSTEM
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Healthcare-Appropriate Theme System
/// Designed for: Cancer Patients, Nurses, Doctors
///
/// Key Design Principles:
/// 1. Accessibility First - WCAG 2.1 AA compliant minimum
/// 2. Medical Safety - Clear, unambiguous interfaces
/// 3. Comfort for Patients - Calming colors, generous spacing
/// 4. Efficiency for Staff - Quick access, information density
/// 5. Error Prevention - Clear labels, confirmation patterns
///
/// ═══════════════════════════════════════════════════════════════════════════

class AppTheme {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COLOR PALETTE - Healthcare Appropriate Colors
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Primary Colors - Calming, Professional, Trustworthy
  static const Color primaryBlue = Color(0xFF5B9AA0);
  static const Color primaryGreen = Color(0xFF81C784);
  static const Color primaryPurple = Color(0xFF9575CD);
  static const Color primaryOrange = Color(0xFFFFB74D);

  // Patient Theme Colors
  static const Color patientPrimary = Color(0xFF81C784);
  static const Color patientSecondary = Color(0xFF5B9AA0);
  static const Color patientBackground = Color(0xFFF7FBF9);
  static const Color patientSurface = Color(0xFFFFFFFF);
  static const Color patientAccent = Color(0xFFE8F5E9);

  // Nurse Theme Colors
  static const Color nursePrimary = Color(0xFF9575CD);
  static const Color nurseSecondary = Color(0xFF81C784);
  static const Color nurseBackground = Color(0xFFF5F5F8);
  static const Color nurseSurface = Color(0xFFFFFFFF);
  static const Color nurseAccent = Color(0xFFEDE7F6);

  // Doctor Theme Colors
  static const Color doctorPrimary = Color(0xFF5B9AA0);
  static const Color doctorSecondary = Color(0xFF42A5F5);
  static const Color doctorBackground = Color(0xFFFAFAFA);
  static const Color doctorSurface = Color(0xFFFFFFFF);
  static const Color doctorAccent = Color(0xFFE0F2F1);

  // Semantic Colors
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
  static const Color emergency = Color(0xFFEF5350);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TYPOGRAPHY - Accessibility-First Text Styles (inherit: false everywhere)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Patient Typography - Larger, more readable
  static TextTheme patientTextTheme = TextTheme(
    displayLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.4,
      letterSpacing: -0.5,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    displayMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    displaySmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.6,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.6,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.6,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodyLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 19,
      fontWeight: FontWeight.w400,
      height: 1.7,
      letterSpacing: 0.2,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodyMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.7,
      letterSpacing: 0.2,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodySmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0.5,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
  );

  /// Nurse Typography - Clear, scannable
  static TextTheme nurseTextTheme = TextTheme(
    displayLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    displayMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    displaySmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodyLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodyMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodySmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
  );

  /// Doctor Typography - Information-dense
  static TextTheme doctorTextTheme = TextTheme(
    displayLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    displayMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    displaySmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    headlineSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    titleSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodyLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodyMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    bodySmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelLarge: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelMedium: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
    labelSmall: TextStyle(
      inherit: false,
      color: textPrimary,
      fontFamily: 'Roboto',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    ),
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SPACING SYSTEM
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Patient Spacing - Generous
  static const double patientSpacingXS = 10.0;
  static const double patientSpacingSM = 16.0;
  static const double patientSpacingMD = 20.0;
  static const double patientSpacingLG = 28.0;
  static const double patientSpacingXL = 40.0;
  static const double patientSpacingXXL = 56.0;

  // Staff Spacing - Efficient
  static const double staffSpacingXS = 4.0;
  static const double staffSpacingSM = 8.0;
  static const double staffSpacingMD = 12.0;
  static const double staffSpacingLG = 16.0;
  static const double staffSpacingXL = 24.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COMPONENT SIZING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Patient Touch Targets - Larger
  static const double patientButtonHeight = 64.0;
  static const double patientIconButtonSize = 64.0;
  static const double patientListItemMinHeight = 80.0;

  // Staff Touch Targets - Standard
  static const double staffButtonHeight = 48.0;
  static const double staffIconButtonSize = 48.0;
  static const double staffListItemMinHeight = 64.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BORDER RADIUS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // THEME DATA GENERATORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Patient Theme - Calming, Accessible, Comfortable
  static ThemeData get patientTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: patientPrimary,
      secondary: patientSecondary,
      surface: patientSurface,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),
    textTheme: patientTextTheme,
    scaffoldBackgroundColor: patientBackground,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: patientSpacingMD,
        vertical: patientSpacingSM,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: patientPrimary,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        inherit: false,
        color: textOnPrimary,
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
      toolbarHeight: 64,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: patientPrimary,
        foregroundColor: textOnPrimary,
        minimumSize: const Size(double.infinity, patientButtonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: patientSpacingLG,
          vertical: patientSpacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        elevation: 2,
        textStyle: TextStyle(
          inherit: false,
          color: textOnPrimary,
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.5,
          letterSpacing: 0.5,
          textBaseline: TextBaseline.alphabetic,
          decoration: TextDecoration.none,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: patientPrimary,
        minimumSize: const Size(double.infinity, patientButtonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: patientSpacingLG,
          vertical: patientSpacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        side: const BorderSide(color: patientPrimary, width: 2),
        textStyle: TextStyle(
          inherit: false,
          color: patientPrimary,
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.5,
          letterSpacing: 0.5,
          textBaseline: TextBaseline.alphabetic,
          decoration: TextDecoration.none,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: patientSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: patientSpacingMD,
        vertical: patientSpacingMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: patientPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: TextStyle(
        inherit: false,
        color: textPrimary,
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0.2,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
      hintStyle: TextStyle(
        inherit: false,
        color: textDisabled,
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0.2,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: patientSpacingMD,
        vertical: patientSpacingSM,
      ),
      minVerticalPadding: patientSpacingSM,
      minLeadingWidth: 56,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: patientSurface,
      selectedItemColor: patientPrimary,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(
        inherit: true,
        color: patientPrimary,
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
      unselectedLabelStyle: TextStyle(
        inherit: true,
        color: textSecondary,
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  /// Nurse Theme
  static ThemeData get nurseTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: nursePrimary,
      secondary: nurseSecondary,
      surface: nurseSurface,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),
    textTheme: nurseTextTheme,
    scaffoldBackgroundColor: nurseBackground,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: staffSpacingMD,
        vertical: staffSpacingSM,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: nursePrimary,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        inherit: false,
        color: textOnPrimary,
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
      toolbarHeight: 56,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: nursePrimary,
        foregroundColor: textOnPrimary,
        minimumSize: const Size(double.infinity, staffButtonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: staffSpacingLG,
          vertical: staffSpacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        textStyle: TextStyle(
          inherit: false,
          color: textOnPrimary,
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
          textBaseline: TextBaseline.alphabetic,
          decoration: TextDecoration.none,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: nurseSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: staffSpacingMD,
        vertical: staffSpacingMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: nursePrimary, width: 2),
      ),
      labelStyle: TextStyle(
        inherit: false,
        color: textPrimary,
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: nurseSurface,
      selectedItemColor: nursePrimary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  /// Doctor Theme
  static ThemeData get doctorTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: doctorPrimary,
      secondary: doctorSecondary,
      surface: doctorSurface,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),
    textTheme: doctorTextTheme,
    scaffoldBackgroundColor: doctorBackground,
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSM),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: staffSpacingMD,
        vertical: staffSpacingSM,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: doctorPrimary,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        inherit: false,
        color: textOnPrimary,
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
      toolbarHeight: 56,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: doctorPrimary,
        foregroundColor: textOnPrimary,
        minimumSize: const Size(double.infinity, staffButtonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: staffSpacingLG,
          vertical: staffSpacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        textStyle: TextStyle(
          inherit: false,
          color: textOnPrimary,
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
          textBaseline: TextBaseline.alphabetic,
          decoration: TextDecoration.none,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: doctorSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: staffSpacingMD,
        vertical: staffSpacingMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: doctorPrimary, width: 2),
      ),
      labelStyle: TextStyle(
        inherit: false,
        color: textPrimary,
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: doctorSurface,
      selectedItemColor: doctorPrimary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  /// Default/Login Theme
  static ThemeData get defaultTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryGreen,
      surface: Colors.white,
      error: error,
    ),
    textTheme: patientTextTheme,
    scaffoldBackgroundColor: const Color(0xFFF5F9FA),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
      ),
    ),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, patientButtonHeight),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),
    ),
  );
}
