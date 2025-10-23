import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/search_history.dart';

class SearchHistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create: Save a new search history entry
  Future<SearchHistory?> createSearchHistory(SearchHistory history) async {
    try {
      // Verify user is authenticated
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('Cannot save search history: User not authenticated');
        return null;
      }

      // Verify the user_id matches the authenticated user
      if (history.userId != currentUser.id) {
        debugPrint('Cannot save search history: User ID mismatch');
        return null;
      }

      final response = await _supabase
          .from('search_history')
          .insert(history.toMap())
          .select()
          .single();

      return SearchHistory.fromMap(response);
    } catch (e) {
      debugPrint('Error creating search history: $e');
      rethrow;
    }
  }

  /// Read: Get all search history for a user (sorted by most recent)
  Future<List<SearchHistory>> getSearchHistory(String userId, {int? limit}) async {
    try {
      var query = _supabase
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .order('searched_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((record) => SearchHistory.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching search history: $e');
      rethrow;
    }
  }

  /// Read: Get search history filtered by search type
  Future<List<SearchHistory>> getSearchHistoryByType(
    String userId,
    String searchType, {
    int? limit,
  }) async {
    try {
      var query = _supabase
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .eq('search_type', searchType)
          .order('searched_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((record) => SearchHistory.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching search history by type: $e');
      rethrow;
    }
  }

  /// Read: Get recent searches (last N searches)
  Future<List<SearchHistory>> getRecentSearches(String userId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((record) => SearchHistory.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recent searches: $e');
      rethrow;
    }
  }

  /// Read: Get search history count for a user
  Future<int> getSearchHistoryCount(String userId) async {
    try {
      final response = await _supabase
          .from('search_history')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting search history count: $e');
      return 0;
    }
  }

  /// Read: Search within search history (find past searches matching a query)
  Future<List<SearchHistory>> searchInHistory(String userId, String query) async {
    try {
      final response = await _supabase
          .from('search_history')
          .select()
          .eq('user_id', userId)
          .ilike('search_query', '%$query%')
          .order('searched_at', ascending: false);

      return (response as List)
          .map((record) => SearchHistory.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error searching in history: $e');
      rethrow;
    }
  }

  /// Delete: Remove a specific search history entry
  Future<bool> deleteSearchHistory(String historyId) async {
    try {
      await _supabase
          .from('search_history')
          .delete()
          .eq('id', historyId);

      return true;
    } catch (e) {
      debugPrint('Error deleting search history: $e');
      return false;
    }
  }

  /// Delete: Clear all search history for a user
  Future<bool> clearAllSearchHistory(String userId) async {
    try {
      await _supabase
          .from('search_history')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error clearing all search history: $e');
      return false;
    }
  }

  /// Delete: Clear search history older than specified days
  Future<bool> clearOldSearchHistory(String userId, int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      await _supabase
          .from('search_history')
          .delete()
          .eq('user_id', userId)
          .lt('searched_at', cutoffDate.toIso8601String());

      return true;
    } catch (e) {
      debugPrint('Error clearing old search history: $e');
      return false;
    }
  }

  /// Utility: Check if a similar search was recently made (to avoid duplicates)
  Future<bool> hasSimilarRecentSearch(
    String userId,
    String searchQuery,
    String searchType, {
    Duration withinDuration = const Duration(minutes: 5),
  }) async {
    try {
      final cutoffTime = DateTime.now().subtract(withinDuration);
      
      final response = await _supabase
          .from('search_history')
          .select('id')
          .eq('user_id', userId)
          .eq('search_query', searchQuery)
          .eq('search_type', searchType)
          .gte('searched_at', cutoffTime.toIso8601String())
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking for similar recent search: $e');
      return false;
    }
  }
}
