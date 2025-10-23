import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_history.dart';
import '../models/generic_product.dart';
import '../services/search_history_service.dart';

class SearchHistoryState {
  final List<SearchHistory> searchHistory;
  final bool isLoading;
  final String? errorMessage;
  final String? filterType; // null = all, 'text', 'image'
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  static const int pageSize = 25;

  const SearchHistoryState({
    this.searchHistory = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterType,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentPage = 0,
  });

  SearchHistoryState copyWith({
    List<SearchHistory>? searchHistory,
    bool? isLoading,
    String? errorMessage,
    String? filterType,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return SearchHistoryState(
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filterType: filterType ?? this.filterType,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get hasHistory => searchHistory.isNotEmpty;
  int get totalSearches => searchHistory.length;
  int get textSearchCount => searchHistory.where((h) => h.searchType == 'text').length;
  int get imageSearchCount => searchHistory.where((h) => h.searchType == 'image').length;
}

class SearchHistoryNotifier extends StateNotifier<SearchHistoryState> {
  final SearchHistoryService _service = SearchHistoryService();

  SearchHistoryNotifier() : super(const SearchHistoryState());

  /// Load search history for a user (initial load)
  Future<void> loadSearchHistory(String userId, {String? filterType}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 0,
        hasMore: true,
      );

      List<SearchHistory> history;
      if (filterType != null && filterType.isNotEmpty) {
        history = await _service.getSearchHistoryByType(
          userId,
          filterType,
          limit: SearchHistoryState.pageSize,
          offset: 0,
        );
      } else {
        history = await _service.getSearchHistory(
          userId,
          limit: SearchHistoryState.pageSize,
          offset: 0,
        );
      }

      state = state.copyWith(
        searchHistory: history,
        isLoading: false,
        filterType: filterType,
        hasMore: history.length >= SearchHistoryState.pageSize,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load search history: $e',
      );
    }
  }

  /// Load more search history (pagination)
  Future<void> loadMoreSearchHistory(String userId) async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);

      final offset = state.currentPage * SearchHistoryState.pageSize;
      List<SearchHistory> moreHistory;

      if (state.filterType != null && state.filterType!.isNotEmpty) {
        moreHistory = await _service.getSearchHistoryByType(
          userId,
          state.filterType!,
          limit: SearchHistoryState.pageSize,
          offset: offset,
        );
      } else {
        moreHistory = await _service.getSearchHistory(
          userId,
          limit: SearchHistoryState.pageSize,
          offset: offset,
        );
      }

      state = state.copyWith(
        searchHistory: [...state.searchHistory, ...moreHistory],
        isLoadingMore: false,
        hasMore: moreHistory.length >= SearchHistoryState.pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more search history: $e',
      );
    }
  }

  /// Load recent searches (limited number)
  Future<void> loadRecentSearches(String userId, {int limit = 10}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final history = await _service.getRecentSearches(userId, limit: limit);

      state = state.copyWith(
        searchHistory: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recent searches: $e',
      );
    }
  }

  /// Add a new search to history (from text search)
  Future<void> addTextSearch({
    required String userId,
    required String searchQuery,
    required List<GenericProduct> results,
  }) async {
    try {
      // Check if similar search was made recently to avoid duplicates
      final hasSimilar = await _service.hasSimilarRecentSearch(
        userId,
        searchQuery,
        'text',
      );

      if (hasSimilar) {
        // Skip adding duplicate
        return;
      }

      // Extract product names from results
      final productNames = results
          .map((p) => p.productName ?? 'Unknown Product')
          .take(10) // Limit to first 10 products
          .toList();

      final history = SearchHistory(
        // id is auto-generated by database, don't set it
        userId: userId,
        searchQuery: searchQuery,
        searchType: 'text',
        resultCount: results.length,
        resultProductNames: productNames,
        searchedAt: DateTime.now(),
      );

      await _service.createSearchHistory(history);

      // Refresh the list if we're currently viewing history
      if (state.searchHistory.isNotEmpty) {
        await loadSearchHistory(userId, filterType: state.filterType);
      }
    } catch (e) {
      // Log error for debugging but don't interrupt user's search experience
      debugPrint('Error saving text search history: $e');
      state = state.copyWith(
        errorMessage: 'Failed to save search history: $e',
      );
    }
  }

  /// Add a new search to history (from image search)
  Future<void> addImageSearch({
    required String userId,
    required List<GenericProduct> results,
  }) async {
    try {
      // For image searches, we use a generic query text
      const searchQuery = 'Image Search';

      // Check if similar search was made recently
      final hasSimilar = await _service.hasSimilarRecentSearch(
        userId,
        searchQuery,
        'image',
        withinDuration: const Duration(seconds: 30), // Shorter duration for image searches
      );

      if (hasSimilar) {
        // Skip adding duplicate
        return;
      }

      // Extract product names from results
      final productNames = results
          .map((p) => p.productName ?? 'Unknown Product')
          .take(10) // Limit to first 10 products
          .toList();

      final history = SearchHistory(
        // id is auto-generated by database, don't set it
        userId: userId,
        searchQuery: searchQuery,
        searchType: 'image',
        resultCount: results.length,
        resultProductNames: productNames,
        searchedAt: DateTime.now(),
      );

      await _service.createSearchHistory(history);

      // Refresh the list if we're currently viewing history
      if (state.searchHistory.isNotEmpty) {
        await loadSearchHistory(userId, filterType: state.filterType);
      }
    } catch (e) {
      // Log error for debugging but don't interrupt user's search experience
      debugPrint('Error saving image search history: $e');
      state = state.copyWith(
        errorMessage: 'Failed to save search history: $e',
      );
    }
  }

  /// Delete a specific search history entry
  Future<void> deleteSearchHistory(String userId, String historyId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final success = await _service.deleteSearchHistory(historyId);

      if (success) {
        // Remove from local state
        final updatedHistory = state.searchHistory
            .where((h) => h.id != historyId)
            .toList();

        state = state.copyWith(
          searchHistory: updatedHistory,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to delete search history',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete search history: $e',
      );
    }
  }

  /// Clear all search history for a user
  Future<void> clearAllHistory(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final success = await _service.clearAllSearchHistory(userId);

      if (success) {
        state = state.copyWith(
          searchHistory: [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to clear search history',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear search history: $e',
      );
    }
  }

  /// Filter search history by type
  Future<void> filterByType(String userId, String? filterType) async {
    await loadSearchHistory(userId, filterType: filterType);
  }

  /// Search within history
  Future<void> searchInHistory(String userId, String query) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final history = await _service.searchInHistory(userId, query);

      state = state.copyWith(
        searchHistory: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to search in history: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    state = const SearchHistoryState();
  }

  /// Refresh search history (reload from beginning)
  Future<void> refreshSearchHistory(String userId) async {
    await loadSearchHistory(userId, filterType: state.filterType);
  }
}

// Provider
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, SearchHistoryState>((ref) {
  return SearchHistoryNotifier();
});
