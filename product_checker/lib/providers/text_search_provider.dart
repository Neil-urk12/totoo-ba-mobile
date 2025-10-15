import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drug_product.dart';
import '../data/mock_data.dart' as mock;

enum TextSearchState {
  idle,
  processing,
  completed,
  error,
}

class TextSearchStateModel {
  final TextSearchState state;
  final String searchQuery;
  final List<DrugProduct> searchResults;
  final String errorMessage;
  final String currentProcessingMessage;
  final double processingProgress;
  final bool isProductRegistered;
  final String? detectedProductName;
  final String? detectedBrandName;

  const TextSearchStateModel({
    this.state = TextSearchState.idle,
    this.searchQuery = '',
    this.searchResults = const [],
    this.errorMessage = '',
    this.currentProcessingMessage = '',
    this.processingProgress = 0.0,
    this.isProductRegistered = false,
    this.detectedProductName,
    this.detectedBrandName,
  });

  TextSearchStateModel copyWith({
    TextSearchState? state,
    String? searchQuery,
    List<DrugProduct>? searchResults,
    String? errorMessage,
    String? currentProcessingMessage,
    double? processingProgress,
    bool? isProductRegistered,
    String? detectedProductName,
    String? detectedBrandName,
  }) {
    return TextSearchStateModel(
      state: state ?? this.state,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      currentProcessingMessage: currentProcessingMessage ?? this.currentProcessingMessage,
      processingProgress: processingProgress ?? this.processingProgress,
      isProductRegistered: isProductRegistered ?? this.isProductRegistered,
      detectedProductName: detectedProductName ?? this.detectedProductName,
      detectedBrandName: detectedBrandName ?? this.detectedBrandName,
    );
  }

  // Helper getters
  bool get hasResults => searchResults.isNotEmpty;
  bool get isIdle => state == TextSearchState.idle;
  bool get isProcessing => state == TextSearchState.processing;
  bool get isCompleted => state == TextSearchState.completed;
  bool get hasError => state == TextSearchState.error;
}

class TextSearchNotifier extends StateNotifier<TextSearchStateModel> {
  // Processing messages
  final List<String> _processingMessages = [
    'Analyzing search query...',
    'Searching product database...',
    'Cross-referencing with FDA records...',
    'Verifying product authenticity...',
    'Generating detailed report...',
    'Finalizing results...',
  ];

  // Static counter to track search attempts for alternating results
  static int _searchCount = 0;

  TextSearchNotifier() : super(const TextSearchStateModel());

  Future<void> searchProduct(String query) async {
    if (query.trim().isEmpty) {
      _setError('Please enter a product name, brand, or registration number');
      return;
    }

    state = state.copyWith(
      state: TextSearchState.processing,
      searchQuery: query.trim(),
      processingProgress: 0.0,
      currentProcessingMessage: _processingMessages[0],
    );

    try {
      // Simulate processing with progress updates
      for (int i = 0; i < _processingMessages.length; i++) {
        if (state.state != TextSearchState.processing) break; // Check if cancelled
        
        state = state.copyWith(
          currentProcessingMessage: _processingMessages[i],
          processingProgress: (i + 1) / _processingMessages.length,
        );
        
        // Wait between messages
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Simulate API call for search results
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate text analysis
      final detectedProductName = _extractProductName(query);
      final detectedBrandName = _extractBrandName(query);
      
      // Simple alternating pattern: first search = verified, second = unverified, third = verified, etc.
      _searchCount++;
      final isRegistered = _searchCount % 2 == 1; // Odd numbers = verified, even numbers = unverified
      
      if (isRegistered) {
        // Product is registered - return single matching product
        final searchResults = mock.MockData.savedDrugProducts.take(1).toList();
        
        state = state.copyWith(
          state: TextSearchState.completed,
          searchResults: searchResults,
          isProductRegistered: true,
          detectedProductName: detectedProductName,
          detectedBrandName: detectedBrandName,
        );
      } else {
        // Product is not registered - no results
        state = state.copyWith(
          state: TextSearchState.completed,
          searchResults: [],
          isProductRegistered: false,
          detectedProductName: detectedProductName,
          detectedBrandName: detectedBrandName,
        );
      }
    } catch (e) {
      _setError('Error searching product: $e');
    }
  }

  String _extractProductName(String query) {
    // Simple extraction logic - in real app, this would be more sophisticated
    final words = query.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0]} ${words[1]}';
    }
    return words.isNotEmpty ? words[0] : 'Unknown Product';
  }

  String _extractBrandName(String query) {
    // Simple extraction logic - in real app, this would be more sophisticated
    final words = query.trim().split(' ');
    return words.isNotEmpty ? words[0] : 'Unknown Brand';
  }

  // Utility methods
  void clearResults() {
    state = state.copyWith(
      searchResults: [],
      state: TextSearchState.idle,
    );
  }

  void reset() {
    state = const TextSearchStateModel();
  }

  void cancelProcessing() {
    if (state.state == TextSearchState.processing) {
      state = state.copyWith(state: TextSearchState.idle);
    }
  }

  // Private helper methods
  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      state: TextSearchState.error,
    );
  }
}

// Provider
final textSearchProvider = StateNotifierProvider<TextSearchNotifier, TextSearchStateModel>((ref) {
  return TextSearchNotifier();
});
