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
  static const Color primaryBlue = Color(0xFF2E7D8F); // Trustworthy teal-blue
  static const Color primaryGreen = Color(0xFF4CAF50); // Healing green
  static const Color primaryPurple = Color(0xFF7B68EE); // Professional purple
  static const Color primaryOrange = Color(0xFFFB8C00); // Warm, supportive

  // Patient Theme Colors - Calming and Soothing
  static const Color patientPrimary = Color(0xFF2E7D8F); // Calm teal-blue
  static const Color patientSecondary = Color(0xFF4CAF50); // Hope green
  static const Color patientBackground = Color(0xFFF5F9FA); // Soft, restful
  static const Color patientSurface = Color(0xFFFFFFFF); // Clean white

  // Nurse Theme Colors - Clear and Actionable
  static const Color nursePrimary = Color(0xFF7B68EE); // Professional purple
  static const Color nurseSecondary = Color(0xFF4CAF50); // Success green
  static const Color nurseBackground = Color(0xFFF8F9FA); // Clean, neutral
  static const Color nurseSurface = Color(0xFFFFFFFF);

  // Doctor Theme Colors - Professional and Efficient
  static const Color doctorPrimary = Color(0xFF2E7D8F); // Trustworthy blue
  static const Color doctorSecondary = Color(0xFF1565C0); // Deep blue
  static const Color doctorBackground = Color(0xFFFFFFFF); // Clinical white
  static const Color doctorSurface = Color(0xFFF5F5F5); // Subtle grey

  // Semantic Colors - Medical Context
  static const Color success = Color(0xFF4CAF50); // Success, healthy
  static const Color warning = Color(0xFFFF9800); // Caution, attention needed
  static const Color error = Color(0xFFE53935); // Error, urgent
  static const Color info = Color(0xFF2196F3); // Information
  static const Color emergency = Color(
    0xFFD32F2F,
  ); // Emergency (softer than pure red)

  // Text Colors - High Contrast for Accessibility
  static const Color textPrimary = Color(0xFF1A1A1A); // Near black (WCAG AAA)
  static const Color textSecondary = Color(0xFF616161); // Medium grey (WCAG AA)
  static const Color textDisabled = Color(0xFF9E9E9E); // Disabled text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on colored bg

  // Neutral Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TYPOGRAPHY - Accessibility-First Text Styles
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Patient Typography - Larger, more readable for fatigued patients
  static TextTheme get patientTextTheme => const TextTheme(
    // Display - For major headings
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.3,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.3,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.3,
    ),

    // Headline - For section titles
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      height: 1.4,
    ),

    // Title - For card titles, list items
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      height: 1.5,
    ),

    // Body - For main content
    bodyLarge: TextStyle(
      fontSize: 17, // Larger for readability
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.6, // More line height for comfort
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.6,
      letterSpacing: 0.15,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),

    // Label - For buttons, form labels
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
      height: 1.4,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      height: 1.3,
    ),
  );

  /// Nurse Typography - Clear, scannable for quick decisions
  static TextTheme get nurseTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.3,
    ),
    displayMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
      height: 1.3,
    ),
  );

  /// Doctor Typography - Information-dense but readable
  static TextTheme get doctorTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
      height: 1.3,
    ),
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SPACING SYSTEM - Generous for Patients, Efficient for Staff
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Patient Spacing - More generous for comfort
  static const double patientSpacingXS = 8.0;
  static const double patientSpacingSM = 12.0;
  static const double patientSpacingMD = 16.0;
  static const double patientSpacingLG = 24.0;
  static const double patientSpacingXL = 32.0;
  static const double patientSpacingXXL = 48.0;

  // Staff Spacing - Efficient but comfortable
  static const double staffSpacingXS = 4.0;
  static const double staffSpacingSM = 8.0;
  static const double staffSpacingMD = 12.0;
  static const double staffSpacingLG = 16.0;
  static const double staffSpacingXL = 24.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COMPONENT SIZING - Accessibility-Compliant Touch Targets
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Patient Touch Targets - Larger (48-56dp) for fatigue/tremors
  static const double patientButtonHeight = 56.0;
  static const double patientIconButtonSize = 56.0;
  static const double patientListItemMinHeight = 72.0;

  // Staff Touch Targets - Standard (48dp) for efficiency
  static const double staffButtonHeight = 48.0;
  static const double staffIconButtonSize = 48.0;
  static const double staffListItemMinHeight = 64.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BORDER RADIUS - Soft, Friendly Corners
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
      titleTextStyle: patientTextTheme.headlineMedium?.copyWith(
        color: textOnPrimary,
      ),
      toolbarHeight: 64, // Taller for accessibility
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
        textStyle: patientTextTheme.labelLarge,
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
        textStyle: patientTextTheme.labelLarge,
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
      labelStyle: patientTextTheme.bodyMedium,
      hintStyle: patientTextTheme.bodyMedium?.copyWith(color: textDisabled),
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
      selectedLabelStyle: patientTextTheme.labelSmall,
      unselectedLabelStyle: patientTextTheme.labelSmall,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  /// Nurse Theme - Clear, Actionable, Efficient
  static ThemeData get nurseTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: nursePrimary,
      secondary: nurseSecondary,
      surface: nurseSurface,
      background: nurseBackground,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
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
      titleTextStyle: nurseTextTheme.headlineMedium?.copyWith(
        color: textOnPrimary,
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
        textStyle: nurseTextTheme.labelLarge,
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
      labelStyle: nurseTextTheme.bodyMedium,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: nurseSurface,
      selectedItemColor: nursePrimary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  /// Doctor Theme - Professional, Information-Dense
  static ThemeData get doctorTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: doctorPrimary,
      secondary: doctorSecondary,
      surface: doctorSurface,
      background: doctorBackground,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
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
      titleTextStyle: doctorTextTheme.headlineMedium?.copyWith(
        color: textOnPrimary,
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
        textStyle: doctorTextTheme.labelLarge,
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
      labelStyle: doctorTextTheme.bodyMedium,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: doctorSurface,
      selectedItemColor: doctorPrimary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  /// Default/Login Theme - Clean, welcoming
  static ThemeData get defaultTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryGreen,
      surface: Colors.white,
      background: const Color(0xFFF5F9FA),
      error: error,
    ),
    textTheme: patientTextTheme, // Use patient typography for login
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
