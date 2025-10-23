import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/action_button_widget.dart';
import 'image_search_screen.dart';
import 'text_processing_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Navigation provider now handles state resets automatically
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TextProcessingScreen(
            searchQuery: query.trim(),
          ),
        ),
      );
    }
  }

  void _handleVerifyProduct() {
    if (_searchQuery.trim().isEmpty) {
      setState(() {
        _errorText = 'Please enter a product name, brand, or registration number';
      });
      return;
    }
    
    // Clear any existing error
    setState(() {
      _errorText = null;
    });
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TextProcessingScreen(
          searchQuery: _searchQuery.trim(),
        ),
      ),
    );
  }

  void _handleTextChanged(String query) {
    setState(() {
      _searchQuery = query;
      _errorText = null; // Clear error when user types
    });
  }

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
              'Is this true stone?',
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
            SearchBarWidget(
              onSearch: _handleSearch,
              onTextChanged: _handleTextChanged,
              errorText: _errorText,
            ),
            const SizedBox(height: 20),
            // Verify Product Button
            ActionButtonWidget(
              text: 'Verify Product',
              icon: Icons.verified_user,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              iconColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: _handleVerifyProduct,
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