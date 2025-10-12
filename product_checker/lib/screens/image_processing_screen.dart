import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../providers/image_search_provider.dart';
import 'image_search_results_screen.dart';

class ImageProcessingScreen extends ConsumerStatefulWidget {
  final File imageFile;
  
  const ImageProcessingScreen({
    super.key,
    required this.imageFile,
  });

  @override
  ConsumerState<ImageProcessingScreen> createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends ConsumerState<ImageProcessingScreen> {

  @override
  void initState() {
    super.initState();
    // Processing will be started in the build method
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startProcessing(WidgetRef ref) {
    final notifier = ref.read(imageSearchProvider.notifier);
    
    // Set the image in the provider first, then process
    notifier.setImage(widget.imageFile);
    
    notifier.processImage().then((_) {
      if (mounted) {
        final state = ref.read(imageSearchProvider);
        if (state.isCompleted) {
          // Add a small delay to ensure state is fully updated
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ImageSearchResultsScreen(
                    imageFile: widget.imageFile,
                  ),
                ),
              );
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(imageSearchProvider);
        
        // Start processing if not already started
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.isIdle) {
            _startProcessing(ref);
          }
        });
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    'Processing Image',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we analyze your product',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Image preview
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Minimalistic circular loading indicator
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Processing message
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      provider.currentProcessingMessage,
                      key: ValueKey(provider.currentProcessingMessage),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress indicator
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: LinearProgressIndicator(
                      value: provider.processingProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress text
                  Text(
                    '${(provider.processingProgress * 7).round()} of 7',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Tips section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Did you know?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Our AI analyzes multiple product features including text, packaging design, and brand elements to provide accurate verification results.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
