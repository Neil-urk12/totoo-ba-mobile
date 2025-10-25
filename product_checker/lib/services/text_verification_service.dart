import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/generic_product.dart';

class TextVerificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Perform full-text search using Supabase FTS with real progress reporting
  static Future<List<GenericProduct>> searchProducts(String query, {Function(String message, double progress)? onProgress}) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception('Supabase is not configured');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    // Optimize query for mobile - remove extra spaces and limit length
    final optimizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ').substring(0, query.length > 50 ? 50 : query.length);

    try {
      // Report initial progress
      onProgress?.call('Starting search...', 0.0);
      
      // First try websearch (primary) with timeout
      List<GenericProduct> results = await _performWebSearchWithProgress(optimizedQuery, onProgress);
      
      // If no results, try plaintext search (fallback) with timeout
      if (results.isEmpty) {
        onProgress?.call('Trying alternative search method...', 0.7);
        results = await _performPlainTextSearchWithProgress(optimizedQuery, onProgress);
      }
      
      // Report completion
      onProgress?.call('Search completed', 1.0);
      
      return results;
    } catch (e) {
      onProgress?.call('Search failed: ${e.toString()}', 1.0);
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  /// Primary search method using websearch FTS with real progress reporting
  static Future<List<GenericProduct>> _performWebSearchWithProgress(String query, Function(String message, double progress)? onProgress) async {
    try {
      List<GenericProduct> allResults = [];
      
      onProgress?.call('Searching drug products...', 0.1);
      
      // Try parallel queries first with timeout (optimized for mobile)
      try {
        final futures = await Future.wait([
          // Search drug_products table using FTS (most common)
          _supabase
              .from('drug_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.websearch, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertDrugResults(results))
              .catchError((e) => <GenericProduct>[]),
          
          // Search food_products table using FTS
          _supabase
              .from('food_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.websearch, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertFoodResults(results))
              .catchError((e) => <GenericProduct>[]),
          
          // Search cosmetic_products table using FTS
          _supabase
              .from('cosmetic_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.websearch, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertCosmeticResults(results))
              .catchError((e) => <GenericProduct>[]),
          
          // Search medical_device_products table using FTS
          _supabase
              .from('medical_device_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.websearch, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertMedicalDeviceResults(results))
              .catchError((e) => <GenericProduct>[]),
        ]).timeout(const Duration(seconds: 15)); // Overall timeout
        
        onProgress?.call('Processing search results...', 0.5);
        
        // Combine all results from parallel queries
        for (final results in futures) {
          allResults.addAll(results);
        }
        
        // If we got results, return them
        if (allResults.isNotEmpty) {
          onProgress?.call('Found ${allResults.length} results', 0.6);
          return allResults;
        }
      } catch (e) {
        onProgress?.call('Parallel search failed, trying sequential...', 0.3);
        // Parallel failed, try sequential as fallback
        allResults = await _performSequentialSearchWithProgress(query, TextSearchType.websearch, onProgress);
        if (allResults.isNotEmpty) {
          return allResults;
        }
      }
      
      return [];
    } catch (e) {
      // If websearch fails, return empty list to trigger fallback
      return [];
    }
  }

  /// Fallback search method using plaintext FTS with real progress reporting
  static Future<List<GenericProduct>> _performPlainTextSearchWithProgress(String query, Function(String message, double progress)? onProgress) async {
    try {
      List<GenericProduct> allResults = [];
      
      onProgress?.call('Searching with plaintext method...', 0.8);
      
      // Try parallel queries first with timeout (optimized for mobile)
      try {
        final futures = await Future.wait([
          // Search drug_products table using plaintext FTS
          _supabase
              .from('drug_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.plain, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertDrugResults(results))
              .catchError((e) => <GenericProduct>[]),
          
          // Search food_products table using plaintext FTS
          _supabase
              .from('food_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.plain, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertFoodResults(results))
              .catchError((e) => <GenericProduct>[]),
          
          // Search cosmetic_products table using plaintext FTS
          _supabase
              .from('cosmetic_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.plain, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertCosmeticResults(results))
              .catchError((e) => <GenericProduct>[]),
          
          // Search medical_device_products table using plaintext FTS
          _supabase
              .from('medical_device_products')
              .select()
              .textSearch('search_vector', query, type: TextSearchType.plain, config: 'english')
              .limit(5) // Reduced limit for mobile
              .timeout(const Duration(seconds: 10)) // Add timeout
              .then((results) => _convertMedicalDeviceResults(results))
              .catchError((e) => <GenericProduct>[]),
        ]).timeout(const Duration(seconds: 15)); // Overall timeout
        
        onProgress?.call('Processing plaintext results...', 0.9);
        
        // Combine all results from parallel queries
        for (final results in futures) {
          allResults.addAll(results);
        }
        
        // If we got results, return them
        if (allResults.isNotEmpty) {
          onProgress?.call('Found ${allResults.length} results', 0.95);
          return allResults;
        }
      } catch (e) {
        onProgress?.call('Plaintext parallel failed, trying sequential...', 0.85);
        // Parallel failed, try sequential as fallback
        allResults = await _performSequentialSearchWithProgress(query, TextSearchType.plain, onProgress);
        if (allResults.isNotEmpty) {
          return allResults;
        }
      }
      
      return [];
    } catch (e) {
      // Return empty results instead of throwing exception
      return [];
    }
  }

  /// Sequential search fallback for mobile when parallel fails with progress reporting
  static Future<List<GenericProduct>> _performSequentialSearchWithProgress(String query, TextSearchType searchType, Function(String message, double progress)? onProgress) async {
    List<GenericProduct> allResults = [];
    
    // Search tables one by one with shorter timeouts
    final tables = [
      ('drug_products', _convertDrugResults, 'Searching drug products sequentially...'),
      ('food_products', _convertFoodResults, 'Searching food products sequentially...'),
      ('cosmetic_products', _convertCosmeticResults, 'Searching cosmetic products sequentially...'),
      ('medical_device_products', _convertMedicalDeviceResults, 'Searching medical devices sequentially...'),
    ];
    
    for (int i = 0; i < tables.length; i++) {
      final (tableName, converter, message) = tables[i];
      final progress = 0.3 + (i * 0.15); // Progress from 0.3 to 0.9
      
      try {
        onProgress?.call(message, progress);
        
        final results = await _supabase
            .from(tableName)
            .select()
            .textSearch('search_vector', query, type: searchType, config: 'english')
            .limit(3) // Even smaller limit for sequential
            .timeout(const Duration(seconds: 5)); // Shorter timeout
        
        allResults.addAll(converter(results));
        
        // If we found some results, we can return early
        if (allResults.length >= 5) {
          onProgress?.call('Found sufficient results', progress + 0.05);
          break;
        }
      } catch (e) {
        // Continue to next table if this one fails
        continue;
      }
    }
    
    return allResults;
  }

  /// Generic conversion method for all product types
  static List<GenericProduct> _convertResults(
    List<Map<String, dynamic>> results,
    String productType,
    String Function(Map<String, dynamic>) getProductName,
    String Function(Map<String, dynamic>) getDescription,
    String? Function(Map<String, dynamic>) getManufacturer,
    String? Function(Map<String, dynamic>) getGenericName,
  ) {
    return results.map((result) => GenericProduct(
      id: result['id'] ?? result['registration_number'] ?? 'unknown',
      productType: productType,
      productName: getProductName(result),
      brandName: result['brand_name'],
      manufacturer: getManufacturer(result),
      registrationNumber: result['registration_number'],
      licenseNumber: result['license_number'],
      documentTrackingNumber: result['document_tracking_number'],
      description: getDescription(result),
      confidence: _calculateConfidence(result),
      isVerified: true,
      genericName: getGenericName(result),
      dosageStrength: result['dosage_strength'],
      dosageForm: result['dosage_form'],
      classification: result['classification'],
      pharmacologicCategory: result['pharmacologic_category'],
      applicationType: result['application_type'],
      packaging: result['packaging'],
      countryOfOrigin: result['country_of_origin'],
      applicantCompany: result['applicant_company'],
    )).toList();
  }

  /// Convert drug product results to GenericProduct
  static List<GenericProduct> _convertDrugResults(List<Map<String, dynamic>> results) {
    return _convertResults(
      results,
      'drug',
      (result) => result['generic_name'] ?? result['brand_name'],
      (result) => result['generic_name'],
      (result) => result['manufacturer'],
      (result) => result['generic_name'],
    );
  }

  /// Convert food product results to GenericProduct
  static List<GenericProduct> _convertFoodResults(List<Map<String, dynamic>> results) {
    return results.map((result) => GenericProduct(
      id: result['id'] ?? result['registration_number'] ?? 'unknown',
      productType: 'food',
      productName: result['product_name'],
      brandName: result['brand_name'],
      manufacturer: result['company_name'],
      registrationNumber: result['registration_number'],
      description: result['product_name'],
      confidence: _calculateConfidence(result),
      isVerified: true,
      companyName: result['company_name'],
      typeOfProduct: result['type_of_product'],
      issuanceDate: result['issuance_date'] != null ? DateTime.tryParse(result['issuance_date']) : null,
      expiryDate: result['expiry_date'] != null ? DateTime.tryParse(result['expiry_date']) : null,
    )).toList();
  }

  /// Convert cosmetic product results to GenericProduct
  static List<GenericProduct> _convertCosmeticResults(List<Map<String, dynamic>> results) {
    return _convertResults(
      results,
      'cosmetic',
      (result) => result['product_name'] ?? result['brand_name'],
      (result) => result['product_name'],
      (result) => result['manufacturer'],
      (result) => null, // Cosmetic products don't have genericName
    );
  }

  /// Convert medical device product results to GenericProduct
  static List<GenericProduct> _convertMedicalDeviceResults(List<Map<String, dynamic>> results) {
    return _convertResults(
      results,
      'medical_device',
      (result) => result['product_name'] ?? result['brand_name'],
      (result) => result['product_name'],
      (result) => result['manufacturer'],
      (result) => null, // Medical device products don't have genericName
    );
  }

  /// Calculate confidence score based on search result metadata
  static double _calculateConfidence(Map<String, dynamic> result) {
    // If there's a relevance score from FTS, use it
    if (result['relevance_score'] != null) {
      return (result['relevance_score'] as num).toDouble();
    }
    
    // If there's a rank from FTS, convert it to confidence
    if (result['rank'] != null) {
      final rank = result['rank'] as num;
      // Convert rank to confidence (higher rank = lower confidence)
      return (1.0 - (rank / 100.0)).clamp(0.0, 1.0);
    }
    
    // Default confidence based on data completeness
    double confidence = 0.5; // Base confidence
    
    if (result['brand_name'] != null && result['brand_name'].toString().isNotEmpty) {
      confidence += 0.2;
    }
    if (result['generic_name'] != null && result['generic_name'].toString().isNotEmpty) {
      confidence += 0.2;
    }
    if (result['manufacturer'] != null && result['manufacturer'].toString().isNotEmpty) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
}
