import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Black and White Minimalistic
  static const Color _primaryBlack = Color(0xFF000000);
  static const Color _primaryWhite = Color(0xFFFFFFFF);
  static const Color _lightGrey = Color(0xFFF5F5F5);
  static const Color _mediumGrey = Color(0xFF9E9E9E);
  static const Color _accentGrey = Color(0xFF757575);
  
  // Dark Mode Colors
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkCard = Color(0xFF2C2C2C);
  static const Color _darkText = Color(0xFFE0E0E0);
  static const Color _darkSecondaryText = Color(0xFFB0B0B0);

  // Cached theme instances for performance
  static ThemeData? _lightThemeCache;
  static ThemeData? _darkThemeCache;

  // Light Theme
  static ThemeData get lightTheme {
    return _lightThemeCache ??= _buildTheme(
      brightness: Brightness.light,
      primaryColor: _primaryBlack,
      backgroundColor: _lightGrey,
      surfaceColor: _primaryWhite,
      onSurfaceColor: _primaryBlack,
      onPrimaryColor: _primaryWhite,
      secondaryColor: _accentGrey,
      onSecondaryColor: _primaryWhite,
      textColor: _primaryBlack,
      secondaryTextColor: _mediumGrey,
      dividerColor: _mediumGrey.withValues(alpha: 0.3),
      cardColor: _primaryWhite,
      scaffoldBackgroundColor: _lightGrey,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return _darkThemeCache ??= _buildTheme(
      brightness: Brightness.dark,
      primaryColor: _primaryWhite,
      backgroundColor: _darkBackground,
      surfaceColor: _darkSurface,
      onSurfaceColor: _darkText,
      onPrimaryColor: _primaryBlack,
      secondaryColor: _darkSecondaryText,
      onSecondaryColor: _primaryBlack,
      textColor: _darkText,
      secondaryTextColor: _darkSecondaryText,
      dividerColor: _darkSecondaryText.withValues(alpha: 0.3),
      cardColor: _darkCard,
      scaffoldBackgroundColor: _darkBackground,
    );
  }

  // Build theme with theme-aware colors
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color onPrimaryColor,
    required Color secondaryColor,
    required Color onSecondaryColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dividerColor,
    required Color cardColor,
    required Color scaffoldBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      
      // Color Scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Colors.red,
        onPrimary: onPrimaryColor,
        onSecondary: onSecondaryColor,
        onSurface: onSurfaceColor,
        onError: _primaryWhite,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: onSurfaceColor,
          size: 24,
        ),
      ),
      
      // Scaffold Theme
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: brightness == Brightness.light ? 2 : 4,
        shadowColor: brightness == Brightness.light 
            ? const Color(0x1A000000) 
            : const Color(0x33000000),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfaceColor,
          side: BorderSide(color: onSurfaceColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onSurfaceColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
        titleSmall: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: secondaryTextColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: onSurfaceColor,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Clear theme cache (useful for testing or dynamic theme changes)
  static void clearCache() {
    _lightThemeCache = null;
    _darkThemeCache = null;
  }
}

// Theme Extension for Custom Colors
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.cardBackground,
    required this.surfaceVariant,
    required this.border,
    required this.shadow,
  });

  final Color cardBackground;
  final Color surfaceVariant;
  final Color border;
  final Color shadow;

  @override
  AppColors copyWith({
    Color? cardBackground,
    Color? surfaceVariant,
    Color? border,
    Color? shadow,
  }) {
    return AppColors(
      cardBackground: cardBackground ?? this.cardBackground,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }

  static const light = AppColors(
    cardBackground: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    border: Color(0xFFE0E0E0),
    shadow: Color(0x1A000000),
  );

  static const dark = AppColors(
    cardBackground: Color(0xFF2C2C2C),
    surfaceVariant: Color(0xFF1E1E1E),
    border: Color(0xFF424242),
    shadow: Color(0x33000000),
  );
}
