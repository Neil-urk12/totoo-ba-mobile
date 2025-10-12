import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../providers/image_search_provider.dart';
import 'image_processing_screen.dart';

class ImageSearchScreen extends ConsumerStatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  ConsumerState<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends ConsumerState<ImageSearchScreen> {
  @override
  void initState() {
    super.initState();
    // Reset provider state when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(imageSearchProvider.notifier).reset();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(imageSearchProvider);
    final notifier = ref.read(imageSearchProvider.notifier);
    
    return Scaffold(
          appBar: AppBar(
            title: const Text('Search by Image'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  'Image Product Search',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a photo or upload an image to verify your product',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (provider.hasError) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => notifier.reset(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Image Preview Section
                if (provider.hasImage) ...[
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        provider.selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                if (!provider.hasImage) ...[
                  if (!kIsWeb) ...[
                    _buildActionButton(
                      context,
                      'Take Photo',
                      'Use your camera to capture the product',
                      Icons.camera_alt,
                      Colors.blue,
                      () => _pickImage(context, ImageSource.camera, notifier),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildActionButton(
                    context,
                    kIsWeb ? 'Select Image File' : 'Upload Image',
                    kIsWeb ? 'Choose an image file from your device' : 'Select an image from your gallery',
                    Icons.photo_library,
                    Colors.green,
                    () => _pickImage(context, ImageSource.gallery, notifier),
                  ),
                ] else ...[
                  // Process and Retake buttons when image is selected
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Retake Photo',
                          'Take a new photo',
                          Icons.refresh,
                          Colors.orange,
                          () => _retakePhoto(context, notifier),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Search Product',
                          'Verify this product',
                          Icons.search,
                          Theme.of(context).colorScheme.primary,
                          () => _searchProduct(context, provider),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Compact Information Section
                _buildCompactInfoSection(context),
              ],
            ),
          ),
        );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Tips',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCompactTip(
            context,
            Icons.wb_sunny_outlined,
            'Good lighting',
            'Natural light works best for clear photos',
          ),
          const SizedBox(height: 12),
          _buildCompactTip(
            context,
            Icons.camera_alt_outlined,
            'Clear product',
            kIsWeb 
              ? 'Make sure product name and brand are clearly visible in the image'
              : 'Make sure product name and brand are visible',
          ),
          const SizedBox(height: 12),
          _buildCompactTip(
            context,
            Icons.security_outlined,
            'Secure & private',
            'Your images are processed securely and not stored',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTip(BuildContext context, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source, ImageSearchNotifier notifier) async {
    final success = await notifier.pickImage(source);
    
    if (!success && mounted && context.mounted) {
      // Get the current state to access error message
      final currentState = ref.read(imageSearchProvider);
      
      // Only show error message if there's an actual error (not just cancellation)
      if (currentState.hasError && currentState.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentState.errorMessage),
            backgroundColor: Colors.orange,
          ),
        );
      }
      // If no error message, it means user just cancelled - no need to show anything
    }
  }

  void _retakePhoto(BuildContext context, ImageSearchNotifier notifier) {
    // Open camera directly for retaking photo
    _pickImage(context, ImageSource.camera, notifier);
  }

  void _searchProduct(BuildContext context, ImageSearchStateModel provider) {
    if (!provider.hasImage) return;

    // Store the image file before resetting
    final imageFile = provider.selectedImage!;
    
    // Reset the entire provider state to clear everything
    ref.read(imageSearchProvider.notifier).reset();
    
    // Navigate to processing screen with the stored image
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageProcessingScreen(
          imageFile: imageFile,
        ),
      ),
    ).then((_) {
      // Reset state again when returning from processing screen
      if (mounted) {
        ref.read(imageSearchProvider.notifier).reset();
      }
    });
  }

}
