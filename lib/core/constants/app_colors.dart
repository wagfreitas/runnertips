import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Running Theme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFD84315);
  static const Color primaryLight = Color(0xFFFFAB91);
  
  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color secondaryGreen = Color(0xFF388E3C);
  
  // Neutral Colors
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = Color(0xFFFF6B35);
  static const Color borderError = Color(0xFFF44336);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryBlue, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'climate': Color(0xFF2196F3),      // Blue
    'elevation': Color(0xFF4CAF50),    // Green
    'organization': Color(0xFFFF9800), // Orange
    'logistics': Color(0xFF9C27B0),    // Purple
    'nutrition': Color(0xFFE91E63),    // Pink
    'timing': Color(0xFF607D8B),       // Blue Grey
    'awards': Color(0xFFFFC107),       // Amber
    'accommodation': Color(0xFF795548), // Brown
    'transportation': Color(0xFF3F51B5), // Indigo
    'food': Color(0xFFFF5722),         // Deep Orange
    'tourism': Color(0xFF00BCD4),      // Cyan
    'shopping': Color(0xFF8BC34A),     // Light Green
    'general': Color(0xFF9E9E9E),      // Grey
  };
  
  // Reputation Level Colors
  static const Map<String, Color> reputationColors = {
    'beginner': Color(0xFF9E9E9E),     // Grey
    'intermediate': Color(0xFF4CAF50), // Green
    'expert': Color(0xFF2196F3),       // Blue
    'guru': Color(0xFFFF9800),         // Orange
  };
  
  // Difficulty Colors
  static const Map<String, Color> difficultyColors = {
    'easy': Color(0xFF4CAF50),         // Green
    'moderate': Color(0xFFFF9800),     // Orange
    'hard': Color(0xFFF44336),         // Red
    'extreme': Color(0xFF9C27B0),      // Purple
  };
}
