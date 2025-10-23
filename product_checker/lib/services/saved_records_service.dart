import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_record.dart';

class SavedRecordsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create: Save a new record
  Future<SavedRecord?> createSavedRecord(SavedRecord record) async {
    try {
      final response = await _supabase
          .from('saved_records')
          .insert(record.toMap())
          .select()
          .single();

      return SavedRecord.fromMap(response);
    } catch (e) {
      debugPrint('Error creating saved record: $e');
      rethrow;
    }
  }

  // Read: Get all saved records for a user
  Future<List<SavedRecord>> getSavedRecords(String userId, {int? limit, int offset = 0}) async {
    try {
      var query = _supabase
          .from('saved_records')
          .select()
          .eq('user_id', userId)
          .order('saved_at', ascending: false);

      if (limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      return (await query as List)
          .map((record) => SavedRecord.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching saved records: $e');
      rethrow;
    }
  }

  // Read: Check if a product is already saved
  Future<bool> isProductSaved(String userId, String productId) async {
    try {
      final response = await _supabase
          .from('saved_records')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking if product is saved: $e');
      return false;
    }
  }

  // Read: Get a single saved record by product ID
  Future<SavedRecord?> getSavedRecordByProductId(String userId, String productId) async {
    try {
      final response = await _supabase
          .from('saved_records')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (response != null) {
        return SavedRecord.fromMap(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching saved record: $e');
      return null;
    }
  }

  // Delete: Remove a saved record by product ID
  Future<bool> deleteSavedRecord(String userId, String productId) async {
    try {
      await _supabase
          .from('saved_records')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);

      return true;
    } catch (e) {
      debugPrint('Error deleting saved record: $e');
      return false;
    }
  }

  // Delete: Remove a saved record by record ID
  Future<bool> deleteSavedRecordById(String recordId) async {
    try {
      await _supabase
          .from('saved_records')
          .delete()
          .eq('id', recordId);

      return true;
    } catch (e) {
      debugPrint('Error deleting saved record by ID: $e');
      return false;
    }
  }

  // Read: Get saved records count for a user
  Future<int> getSavedRecordsCount(String userId) async {
    try {
      final response = await _supabase
          .from('saved_records')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting saved records count: $e');
      return 0;
    }
  }

  // Read: Get saved records filtered by search type
  Future<List<SavedRecord>> getSavedRecordsBySearchType(
    String userId,
    String searchType, {
    int? limit,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('saved_records')
          .select()
          .eq('user_id', userId)
          .eq('search_type', searchType)
          .order('saved_at', ascending: false);

      if (limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      return (await query as List)
          .map((record) => SavedRecord.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching saved records by search type: $e');
      rethrow;
    }
  }

  // Read: Get saved records filtered by verification status
  Future<List<SavedRecord>> getSavedRecordsByVerificationStatus(
    String userId,
    bool isVerified, {
    int? limit,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('saved_records')
          .select()
          .eq('user_id', userId)
          .eq('is_verified', isVerified)
          .order('saved_at', ascending: false);

      if (limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      return (await query as List)
          .map((record) => SavedRecord.fromMap(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching saved records by verification status: $e');
      rethrow;
    }
  }
}
