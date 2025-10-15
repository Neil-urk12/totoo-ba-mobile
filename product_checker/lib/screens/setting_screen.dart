import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'about_screen.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeModeDisplayName = ref.watch(themeModeDisplayNameProvider);
    final authState = ref.watch(authProvider);
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 30),
          
          // Theme Settings Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Theme Mode'),
              subtitle: Text(themeModeDisplayName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.isDarkMode ? 'Dark' : 'Light',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Account Settings Card (only show if authenticated)
          if (authState.isAuthenticated) ...[
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: const Text('Account'),
                    subtitle: const Text('Manage your account settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to account settings if needed
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Sign Out'),
                    subtitle: const Text('Sign out of your account'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLogoutDialog(context, ref);
                    },
                  ),
                ],
              ),
            ),
          ],
          
          // About Section (always visible)
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Learn more about this app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}