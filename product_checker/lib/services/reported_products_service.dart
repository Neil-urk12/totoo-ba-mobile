import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report.dart';

class ReportedProductsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new report
  Future<Report?> createReport({
    String? userId, // Now nullable for anonymous reports
    required String productName,
    String? brandName,
    String? registrationNumber,
    required String description,
    String? reporterName,
    String? location,
    String? storeName,
  }) async {
    try {
      final reportData = {
        'user_id': userId, // Can be null for anonymous reports
        'product_name': productName,
        'brand_name': brandName,
        'registration_number': registrationNumber,
        'description': description,
        'reporter_name': reporterName,
        'location': location,
        'store_name': storeName,
        'report_date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('reported_products')
          .insert(reportData)
          .select()
          .single();

      return Report(
        id: response['id'].toString(), // Convert int8 to string
        productName: response['product_name'] as String,
        brandName: response['brand_name'] as String?,
        registrationNumber: response['registration_number'] as String?,
        description: response['description'] as String,
        reporterName: response['reporter_name'] as String?,
        reportDate: DateTime.parse(response['report_date'] as String),
        location: response['location'] as String?,
        storeName: response['store_name'] as String?,
      );
    } catch (e) {
      debugPrint('Error creating report: $e');
      return null;
    }
  }

  /// Get all reports (for all users - public view)
  Future<List<Report>> getAllReports({int? limit, int offset = 0}) async {
    try {
      var query = _supabase
          .from('reported_products')
          .select()
          .order('report_date', ascending: false);

      if (limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      final response = await query;

      return (response as List)
          .map((item) => Report(
                id: item['id'].toString(),
                productName: item['product_name'] as String,
                brandName: item['brand_name'] as String?,
                registrationNumber: item['registration_number'] as String?,
                description: item['description'] as String,
                reporterName: item['reporter_name'] as String?,
                reportDate: DateTime.parse(item['report_date'] as String),
                location: item['location'] as String?,
                storeName: item['store_name'] as String?,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all reports: $e');
      return [];
    }
  }

  /// Get reports for a specific user
  Future<List<Report>> getUserReports(String userId, {int? limit, int offset = 0}) async {
    try {
      var query = _supabase
          .from('reported_products')
          .select()
          .eq('user_id', userId)
          .order('report_date', ascending: false);

      if (limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      final response = await query;

      return (response as List)
          .map((item) => Report(
                id: item['id'].toString(),
                productName: item['product_name'] as String,
                brandName: item['brand_name'] as String?,
                registrationNumber: item['registration_number'] as String?,
                description: item['description'] as String,
                reporterName: item['reporter_name'] as String?,
                reportDate: DateTime.parse(item['report_date'] as String),
                location: item['location'] as String?,
                storeName: item['store_name'] as String?,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user reports: $e');
      return [];
    }
  }

  /// Delete a report
  Future<bool> deleteReport(String reportId) async {
    try {
      await _supabase
          .from('reported_products')
          .delete()
          .eq('id', reportId);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting report: $e');
      return false;
    }
  }

  /// Search reports by query
  Future<List<Report>> searchReports(String query) async {
    try {
      final response = await _supabase
          .from('reported_products')
          .select()
          .or('product_name.ilike.%$query%,brand_name.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%,store_name.ilike.%$query%')
          .order('report_date', ascending: false);

      return (response as List)
          .map((item) => Report(
                id: item['id'].toString(),
                productName: item['product_name'] as String,
                brandName: item['brand_name'] as String?,
                registrationNumber: item['registration_number'] as String?,
                description: item['description'] as String,
                reporterName: item['reporter_name'] as String?,
                reportDate: DateTime.parse(item['report_date'] as String),
                location: item['location'] as String?,
                storeName: item['store_name'] as String?,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error searching reports: $e');
      return [];
    }
  }
}
