import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeModeDisplayName = ref.watch(themeModeDisplayNameProvider);
    
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
        ],
      ),
    );
  }
}