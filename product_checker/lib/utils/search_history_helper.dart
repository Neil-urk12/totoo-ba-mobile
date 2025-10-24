import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generic_product.dart';
import '../providers/auth_provider.dart';
import '../providers/search_history_provider.dart';

/// Helper class for saving search history
/// Use this in your search results screens to track user searches
class SearchHistoryHelper {
  /// Save text search to history
  /// Call this after text search results are displayed
  static void saveTextSearch({
    required WidgetRef ref,
    required String searchQuery,
    required List<GenericProduct> results,
  }) {
    final authState = ref.read(authProvider);
    
    // Only save if user is authenticated
    if (authState.isAuthenticated && authState.user != null) {
      // Use Future.microtask to avoid calling during build
      Future.microtask(() {
        ref.read(searchHistoryProvider.notifier).addTextSearch(
          userId: authState.user!.id,
          searchQuery: searchQuery,
          results: results,
        );
      });
    }
  }

  /// Save image search to history
  /// Call this after image search results are displayed
  static void saveImageSearch({
    required WidgetRef ref,
    required List<GenericProduct> results,
  }) {
    final authState = ref.read(authProvider);
    
    // Only save if user is authenticated
    if (authState.isAuthenticated && authState.user != null) {
      // Use Future.microtask to avoid calling during build
      Future.microtask(() {
        ref.read(searchHistoryProvider.notifier).addImageSearch(
          userId: authState.user!.id,
          results: results,
        );
      });
    }
  }

  /// Check if user is authenticated before attempting to save
  static bool canSaveHistory(WidgetRef ref) {
    final authState = ref.read(authProvider);
    return authState.isAuthenticated && authState.user != null;
  }
}
