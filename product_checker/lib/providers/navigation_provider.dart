import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'saved_records_provider.dart';
import 'text_search_provider.dart';

enum AppScreen {
  home(0),
  saved(1),
  reports(2),
  profile(3),
  settings(4);

  const AppScreen(this.tabIndex);
  final int tabIndex;

  static AppScreen fromIndex(int index) {
    return AppScreen.values.firstWhere(
      (screen) => screen.tabIndex == index,
      orElse: () => AppScreen.home,
    );
  }
}

class NavigationState {
  final AppScreen currentScreen;
  final Map<AppScreen, dynamic> screenData;

  const NavigationState({
    this.currentScreen = AppScreen.home,
    this.screenData = const {},
  });

  NavigationState copyWith({
    AppScreen? currentScreen,
    Map<AppScreen, dynamic>? screenData,
  }) {
    return NavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      screenData: screenData ?? this.screenData,
    );
  }

  // Helper getter for bottom navigation bar index
  // Settings screen (index 4) should show as home (index 0) in bottom nav
  int get bottomNavIndex => currentScreen.tabIndex < 4 ? currentScreen.tabIndex : 0;
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier(this.ref) : super(const NavigationState());

  final Ref ref;

  void navigateToScreen(AppScreen screen) {
    // Handle screen-specific logic and side effects
    switch (screen) {
      case AppScreen.saved:
        // Reset saved screen when navigating to it
        ref.read(resetSavedScreenProvider.notifier).state =
            !ref.read(resetSavedScreenProvider);
        break;
      case AppScreen.home:
        // Reset text search provider when returning to home
        ref.read(textSearchProvider.notifier).reset();
        break;
      case AppScreen.reports:
      case AppScreen.profile:
      case AppScreen.settings:
        // No specific side effects for these screens currently
        break;
    }

    state = state.copyWith(currentScreen: screen);
  }

  void navigateToSettings() {
    navigateToScreen(AppScreen.settings);
  }

  void navigateToProfile() {
    navigateToScreen(AppScreen.profile);
  }

  void navigateToHome() {
    navigateToScreen(AppScreen.home);
  }

  void navigateToSaved() {
    navigateToScreen(AppScreen.saved);
  }

  void navigateToReports() {
    navigateToScreen(AppScreen.reports);
  }

  // Handle bottom navigation bar taps
  void onBottomNavTap(int index) {
    final screen = AppScreen.fromIndex(index);
    navigateToScreen(screen);
  }

  // Store screen-specific data if needed
  void setScreenData(AppScreen screen, dynamic data) {
    final newScreenData = Map<AppScreen, dynamic>.from(state.screenData);
    newScreenData[screen] = data;
    state = state.copyWith(screenData: newScreenData);
  }

  // Get screen-specific data
  T? getScreenData<T>(AppScreen screen) {
    return state.screenData[screen] as T?;
  }
}

// Provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier(ref);
});