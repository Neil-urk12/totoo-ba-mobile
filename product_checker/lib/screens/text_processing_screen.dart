import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/text_search_provider.dart';
import 'text_search_results_screen.dart';

class TextProcessingScreen extends ConsumerStatefulWidget {
  final String searchQuery;
  
  const TextProcessingScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  ConsumerState<TextProcessingScreen> createState() => _TextProcessingScreenState();
}

class _TextProcessingScreenState extends ConsumerState<TextProcessingScreen> {

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
    final notifier = ref.read(textSearchProvider.notifier);
    
    // Reset the provider state before starting processing
    notifier.reset();
    
    // Start the search - navigation will be handled by the build method listener
    notifier.searchProduct(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(textSearchProvider);
        
        // Start processing if not already started
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.isIdle) {
            _startProcessing(ref);
          }
        });
        
        // Listen for state changes and navigate when appropriate
        ref.listen<TextSearchStateModel>(textSearchProvider, (previous, next) {
          if (next.isCompleted && 
              next.processingProgress >= 1.0 && 
              next.currentProcessingMessage == 'Search completed successfully' &&
              next.searchResult != TextSearchResult.unknown &&
              next.searchResults.isNotEmpty &&
              previous?.searchResult != next.searchResult) {
            // Navigate when search is completed and results are fully processed
            // Only navigate when the search result has actually changed from previous state
            final navigator = Navigator.of(context);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TextSearchResultsScreen(
                      searchQuery: widget.searchQuery,
                      skipLoadingState: true,
                    ),
                  ),
                );
              }
            });
          } else if (next.hasError && next.errorMessage.isNotEmpty) {
            // Navigate when there's an error
            final navigator = Navigator.of(context);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TextSearchResultsScreen(
                      searchQuery: widget.searchQuery,
                      skipLoadingState: true,
                    ),
                  ),
                );
              }
            });
          }
        });
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    'Processing Search',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we search for your product',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Search query preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Searching for:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.searchQuery,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                      key: ValueKey('${provider.currentProcessingMessage}_${provider.processingProgress}_${DateTime.now().millisecondsSinceEpoch}'),
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
                    '${(provider.processingProgress * 100).round()}%',
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
                              'Search Tips',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with product names, brand names, or registration numbers for the most accurate results.',
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
