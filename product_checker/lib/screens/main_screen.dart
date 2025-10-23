import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'setting_screen.dart';
import '../providers/navigation_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SavedScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
      SettingScreen(
        onNavigateToProfile: () {
          ref.read(navigationProvider.notifier).navigateToProfile();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Totoo ba ito?'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ref.read(navigationProvider.notifier).navigateToSettings();
            },
          ),
        ],
      ),
      body: _screens[navigationState.currentScreen.tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.bottomNavIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).onBottomNavTap(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}