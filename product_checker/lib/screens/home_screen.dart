import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/action_button_widget.dart';
import 'image_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Verify to check if this is true?',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verify drugs, food, cosmetics, and medical devices instantly',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Search Bar Widget
            const SearchBarWidget(),
            const SizedBox(height: 20),
            // Verify Product Button
            ActionButtonWidget(
              text: 'Verify Product',
              icon: Icons.verified_user,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              iconColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () { 
              },
            ),
            const SizedBox(height: 10),
            // Search by Image Button
            ActionButtonWidget(
              text: 'Search by Image', 
              icon: Icons.camera_alt, 
              backgroundColor: Theme.of(context).colorScheme.surface, 
              textColor: Theme.of(context).colorScheme.onSurface, 
              iconColor: Theme.of(context).colorScheme.onSurface, 
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ImageSearchScreen(),
                  ),
                );
              }
            ),
            const SizedBox(height: 20),
            // Product Categories Section
            Text(
              'Supported Product Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Category Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryChip(context, 'Drugs', Icons.medication),
                _buildCategoryChip(context, 'Food', Icons.restaurant),
                _buildCategoryChip(context, 'Cosmetics', Icons.face),
                _buildCategoryChip(context, 'Medical Devices', Icons.medical_services),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}