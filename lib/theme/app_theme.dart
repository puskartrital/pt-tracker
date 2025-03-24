import 'package:flutter/material.dart';
import 'package:pt_tracker/models/task.dart';

class AppTheme {
  // Primary colors - Will be updated from logo
  static Color primaryLight = const Color(0xFF0090F7); // Default, will be updated
  static Color primaryDark = const Color(0xFF2196F3); // Added missing primaryDark
  static Color secondaryLight = const Color(0xFFBA62FC); // Default, will be updated
  
  // Secondary colors
  static const Color secondaryDark = Color(0xFFFF9800);
  
  // Accent colors
  static const Color accentLight = Color(0xFF30D158); // Fresh green
  static const Color accentDark = Color(0xFF4CAF50);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Surface colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Error colors
  static const Color errorLight = Color(0xFFFF3B30);
  static const Color errorDark = Color(0xFFFF5252);
  
  // Status colors
  static const Color todoColor = Color(0xFF9E9E9E); // Grey
  static const Color inProgressColor = Color(0xFF2196F3); // Blue
  static const Color onHoldColor = Color(0xFFFFC107); // Yellow
  static const Color wontDoColor = Color(0xFF9C27B0); // Purple
  static const Color completedColor = Color(0xFF4CAF50); // Green
  
  // Priority colors
  static const Color lowPriorityColor = Color(0xFF30D158); // Green
  static const Color mediumPriorityColor = Color(0xFF0A84FF); // Blue
  static const Color highPriorityColor = Color(0xFFFF9500); // Orange
  static const Color criticalPriorityColor = Color(0xFFFF3B30); // Red
  
  // Add method to update theme colors from logo
  static void updateColorsFromLogo(Color primaryColor, Color secondaryColor) {
    primaryLight = primaryColor;
    primaryDark = primaryColor.withOpacity(0.8); // Update dark theme color too
    secondaryLight = secondaryColor;
  }
  
  // Common dimensions
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double chipBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  
  // Create light theme
  static ThemeData lightTheme() {
    return ThemeData(
      fontFamily: 'Mukta',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryLight,
        onPrimary: Colors.white,
        secondary: secondaryLight,
        onSecondary: Colors.white,
        error: errorLight,
        onError: Colors.white,
        background: backgroundLight,
        onBackground: Color(0xFF1D1D1D),
        surface: surfaceLight,
        onSurface: Color(0xFF1D1D1D),
        tertiary: accentLight,
        onTertiary: Colors.white,
        surfaceTint: backgroundLight,
        outline: Color(0xFFE0E0E0),
        shadow: Color(0x40000000),
        inversePrimary: Color(0xFF81D4FA),
        surfaceVariant: Color(0xFFF5F5F9),
        onSurfaceVariant: Color(0xFF6C6C6C),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight, width: 2), // Removed const
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6C6C6C),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
  
  // Create dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      fontFamily: 'Mukta',
      colorScheme: ColorScheme(  // Removed const
        brightness: Brightness.dark,
        primary: primaryDark,
        onPrimary: Colors.white,
        secondary: secondaryDark,
        onSecondary: Colors.white,
        error: errorDark,
        onError: Colors.white,
        background: backgroundDark,
        onBackground: Colors.white,
        surface: surfaceDark,
        onSurface: Colors.white,
        tertiary: accentDark,
        onTertiary: Colors.white,
        surfaceTint: backgroundDark,
        outline: const Color(0xFF3A3A3A),
        shadow: const Color(0x66000000),
        inversePrimary: primaryDark,
        surfaceVariant: const Color(0xFF252525),
        onSurfaceVariant: const Color(0xFFBDBDBD),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        color: surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          side: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryDark, width: 2), // Removed const
        ),
        filled: true,
        fillColor: const Color(0xFF252525),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFFBDBDBD),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
  
  // Helper methods for getting colors
  static Color getSeverityColor(TaskSeverity severity) {
    switch (severity) {
      case TaskSeverity.low:
        return lowPriorityColor;
      case TaskSeverity.medium:
        return mediumPriorityColor;
      case TaskSeverity.high:
        return highPriorityColor;
      case TaskSeverity.critical:
        return criticalPriorityColor;
    }
  }
  
  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return todoColor;
      case TaskStatus.inProgress:
        return inProgressColor;
      case TaskStatus.onHold:
        return onHoldColor;
      case TaskStatus.wontDo:
        return wontDoColor;
    }
  }

  // Update the icon getters with modern icons
  static IconData getSeverityIcon(TaskSeverity severity) {
    switch (severity) {
      case TaskSeverity.low:
        return Icons.keyboard_double_arrow_down_rounded;
      case TaskSeverity.medium:
        return Icons.drag_handle_rounded;
      case TaskSeverity.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskSeverity.critical:
        return Icons.error_rounded;
    }
  }

  static IconData getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.pending_rounded;
      case TaskStatus.onHold:
        return Icons.pause_circle_rounded;
      case TaskStatus.wontDo:
        return Icons.block_rounded;
    }
  }
}
