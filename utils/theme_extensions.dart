import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Extension methods for easy theme access
extension ThemeExtensions on BuildContext {
  /// Get theme colors
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Get text theme
  TextTheme get textStyle => Theme.of(this).textTheme;
  
  /// Get primary color
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  
  /// Get scaffold background color
  Color get scaffoldBg => Theme.of(this).scaffoldBackgroundColor;
}

/// Helper class for theme-aware spacing
class ThemeSpacing {
  static double xs(BuildContext context) => 4.0;
  static double sm(BuildContext context) => 8.0;
  static double md(BuildContext context) => 12.0;
  static double lg(BuildContext context) => 16.0;
  static double xl(BuildContext context) => 24.0;
  static double xxl(BuildContext context) => 32.0;
}

