import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generic_product.dart';
import '../services/text_verification_service.dart';

enum TextSearchState {
  idle,
  processing,
  completed,
  error,
}

enum TextSearchResult {
  verified,           // Product found and verified
  notFound,          // Product not found in database (can be reported)
  invalidQuery,      // Search query is invalid or too short
  apiError,          // API/Network error
  unknown,           // Unknown result
}

class TextSearchStateModel {
  final TextSearchState state;
  final String searchQuery;
  final List<GenericProduct> searchResults;
  final String errorMessage;
  final String currentProcessingMessage;
  final double processingProgress;
  final bool isProductRegistered;
  final String? detectedProductName;
  final String? detectedBrandName;
  final TextSearchResult searchResult;
  final String? resultMessage;

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
    this.searchResult = TextSearchResult.unknown,
    this.resultMessage,
  });

  TextSearchStateModel copyWith({
    TextSearchState? state,
    String? searchQuery,
    List<GenericProduct>? searchResults,
    String? errorMessage,
    String? currentProcessingMessage,
    double? processingProgress,
    bool? isProductRegistered,
    String? detectedProductName,
    String? detectedBrandName,
    TextSearchResult? searchResult,
    String? resultMessage,
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
      searchResult: searchResult ?? this.searchResult,
      resultMessage: resultMessage ?? this.resultMessage,
    );
  }

  // Helper getters
  bool get hasResults => searchResults.isNotEmpty;
  bool get isIdle => state == TextSearchState.idle;
  bool get isProcessing => state == TextSearchState.processing;
  bool get isCompleted => state == TextSearchState.completed;
  bool get hasError => state == TextSearchState.error;
  
  // Result state getters
  bool get isVerified => searchResult == TextSearchResult.verified;
  bool get isNotFound => searchResult == TextSearchResult.notFound;
  bool get isInvalidQuery => searchResult == TextSearchResult.invalidQuery;
  bool get isApiError => searchResult == TextSearchResult.apiError;
  bool get isUnknownResult => searchResult == TextSearchResult.unknown;
}

class TextSearchNotifier extends StateNotifier<TextSearchStateModel> {
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
      currentProcessingMessage: 'Starting search...',
    );

    try {
      // Perform actual Supabase search with real progress reporting
      final searchResults = await TextVerificationService.searchProducts(
        query.trim(),
        onProgress: (message, progress) {
          // Update state with real progress from the service
          state = state.copyWith(
            currentProcessingMessage: message,
            processingProgress: progress,
          );
        },
      );
      
      // Extract detected names from query
      final detectedProductName = _extractProductName(query);
      final detectedBrandName = _extractBrandName(query);
      
      // Determine search result type
      final searchResultType = _determineSearchResult(searchResults);
      
      // Complete when search is actually done and results are ready
      state = state.copyWith(
        state: TextSearchState.completed,
        searchResults: searchResults,
        isProductRegistered: searchResults.isNotEmpty,
        detectedProductName: detectedProductName,
        detectedBrandName: detectedBrandName,
        searchResult: searchResultType,
        resultMessage: _getResultMessage(searchResultType, searchResults.length),
        processingProgress: 1.0, // Ensure progress is at 100%
        currentProcessingMessage: 'Search completed successfully',
      );
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

  TextSearchResult _determineSearchResult(List<GenericProduct> results) {
    if (results.isEmpty) {
      return TextSearchResult.notFound;
    }
    
    // Check if any results have high confidence
    final highConfidenceResults = results.where((r) => (r.confidence ?? 0.0) > 0.7).toList();
    if (highConfidenceResults.isNotEmpty) {
      return TextSearchResult.verified;
    }
    
    // Check if any results have medium confidence
    final mediumConfidenceResults = results.where((r) => (r.confidence ?? 0.0) > 0.4).toList();
    if (mediumConfidenceResults.isNotEmpty) {
      return TextSearchResult.verified; // Still consider verified but with lower confidence
    }
    
    return TextSearchResult.notFound;
  }

  String _getResultMessage(TextSearchResult resultType, int resultCount) {
    switch (resultType) {
      case TextSearchResult.verified:
        if (resultCount == 1) {
          return 'Product found and verified';
        } else {
          return 'Found $resultCount matching products';
        }
      case TextSearchResult.notFound:
        return 'Product not found in database';
      case TextSearchResult.invalidQuery:
        return 'Please enter a valid search query';
      case TextSearchResult.apiError:
        return 'Search service temporarily unavailable';
      case TextSearchResult.unknown:
        return 'Search completed with unknown result';
    }
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
