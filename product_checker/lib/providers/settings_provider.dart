import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode enum for better type safety
enum AppThemeMode {
  light,
  dark,
  system,
}

// Settings state class
class SettingsState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const SettingsState({
    required this.themeMode,
    required this.isDarkMode,
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Settings notifier class
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState(
    themeMode: AppThemeMode.system,
    isDarkMode: false,
  ));

  // Toggle between light and dark mode
  void toggleTheme() {
    final newThemeMode = state.themeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    
    state = state.copyWith(
      themeMode: newThemeMode,
      isDarkMode: newThemeMode == AppThemeMode.dark,
    );
  }

  // Set specific theme mode
  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(
      themeMode: mode,
      isDarkMode: mode == AppThemeMode.dark,
    );
  }

  // Set dark mode based on system brightness
  void setSystemTheme(bool isSystemDark) {
    if (state.themeMode == AppThemeMode.system) {
      state = state.copyWith(isDarkMode: isSystemDark);
    }
  }
}

// Provider for settings state
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// Provider for current theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  
  switch (settings.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

// Provider for current brightness
final brightnessProvider = Provider<Brightness>((ref) {
  final settings = ref.watch(settingsProvider);
  
  if (settings.themeMode == AppThemeMode.system) {
    // Return system brightness - this would need to be updated from the main app
    return Brightness.light; // Default fallback
  }
  
  return settings.isDarkMode ? Brightness.dark : Brightness.light;
});

// Provider for theme mode display name
final themeModeDisplayNameProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  
  switch (settings.themeMode) {
    case AppThemeMode.light:
      return 'Light Mode';
    case AppThemeMode.dark:
      return 'Dark Mode';
    case AppThemeMode.system:
      return 'System Default';
  }
});
