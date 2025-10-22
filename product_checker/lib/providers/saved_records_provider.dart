import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/generic_product.dart';

class SavedRecord {
  final String id;
  final String userId;
  final String productId;
  final String productType;
  final String productName;
  final String? brandName;
  final String? manufacturer;
  final String? registrationNumber;
  final String? genericName;
  final String? dosageStrength;
  final String? dosageForm;
  final String? classification;
  final String? countryOfOrigin;
  final String? applicantCompany;
  final String? description;
  final double? confidence;
  final bool isVerified;
  final DateTime savedAt;
  final String searchType; // 'text' or 'image'

  const SavedRecord({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productType,
    required this.productName,
    this.brandName,
    this.manufacturer,
    this.registrationNumber,
    this.genericName,
    this.dosageStrength,
    this.dosageForm,
    this.classification,
    this.countryOfOrigin,
    this.applicantCompany,
    this.description,
    this.confidence,
    required this.isVerified,
    required this.savedAt,
    required this.searchType,
  });

  factory SavedRecord.fromMap(Map<String, dynamic> map) {
    return SavedRecord(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      productId: map['product_id'] ?? '',
      productType: map['product_type'] ?? '',
      productName: map['product_name'] ?? '',
      brandName: map['brand_name'],
      manufacturer: map['manufacturer'],
      registrationNumber: map['registration_number'],
      genericName: map['generic_name'],
      dosageStrength: map['dosage_strength'],
      dosageForm: map['dosage_form'],
      classification: map['classification'],
      countryOfOrigin: map['country_of_origin'],
      applicantCompany: map['applicant_company'],
      description: map['description'],
      confidence: map['confidence']?.toDouble(),
      isVerified: map['is_verified'] ?? false,
      savedAt: DateTime.parse(map['saved_at']),
      searchType: map['search_type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'product_id': productId,
      'product_type': productType,
      'product_name': productName,
      'brand_name': brandName,
      'manufacturer': manufacturer,
      'registration_number': registrationNumber,
      'generic_name': genericName,
      'dosage_strength': dosageStrength,
      'dosage_form': dosageForm,
      'classification': classification,
      'country_of_origin': countryOfOrigin,
      'applicant_company': applicantCompany,
      'description': description,
      'confidence': confidence,
      'is_verified': isVerified,
      'search_type': searchType,
    };
  }

  GenericProduct toGenericProduct() {
    return GenericProduct(
      id: productId,
      productType: productType,
      productName: productName,
      brandName: brandName,
      manufacturer: manufacturer,
      registrationNumber: registrationNumber,
      description: description,
      confidence: confidence,
      isVerified: isVerified,
      genericName: genericName,
      dosageStrength: dosageStrength,
      dosageForm: dosageForm,
      classification: classification,
      countryOfOrigin: countryOfOrigin,
      applicantCompany: applicantCompany,
    );
  }
}

class SavedRecordsState {
  final List<SavedRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaving;

  const SavedRecordsState({
    this.records = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSaving = false,
  });

  SavedRecordsState copyWith({
    List<SavedRecord>? records,
    bool? isLoading,
    String? errorMessage,
    bool? isSaving,
  }) {
    return SavedRecordsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  bool isProductSaved(String productId) {
    return records.any((record) => record.productId == productId);
  }

  bool get isEmpty => records.isEmpty;
}

class SavedRecordsNotifier extends StateNotifier<SavedRecordsState> {
  SavedRecordsNotifier() : super(const SavedRecordsState());

  Future<void> loadSavedRecords(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('saved_records_$userId') ?? [];
      
      final records = recordsJson
          .map((json) => SavedRecord.fromMap(jsonDecode(json)))
          .toList();

      // Sort by saved date (newest first)
      records.sort((a, b) => b.savedAt.compareTo(a.savedAt));

      state = state.copyWith(
        records: records,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load saved records: ${e.toString()}',
      );
    }
  }

  Future<bool> saveProduct(GenericProduct product, String userId, String searchType) async {
    try {
      state = state.copyWith(isSaving: true, errorMessage: null);

      // Check if product is already saved
      if (state.isProductSaved(product.id)) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Product is already saved',
        );
        return false;
      }

      final record = SavedRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
        userId: userId,
        productId: product.id,
        productType: product.productType,
        productName: product.productName ?? 'Unknown Product',
        brandName: product.brandName,
        manufacturer: product.manufacturer,
        registrationNumber: product.registrationNumber,
        genericName: product.genericName,
        dosageStrength: product.dosageStrength,
        dosageForm: product.dosageForm,
        classification: product.classification,
        countryOfOrigin: product.countryOfOrigin,
        applicantCompany: product.applicantCompany,
        description: product.description,
        confidence: product.confidence,
        isVerified: product.isVerified,
        savedAt: DateTime.now(),
        searchType: searchType,
      );

      // Load existing records
      final prefs = await SharedPreferences.getInstance();
      final existingRecordsJson = prefs.getStringList('saved_records_$userId') ?? [];
      
      // Add new record
      existingRecordsJson.add(jsonEncode(record.toMap()));
      
      // Save back to SharedPreferences
      await prefs.setStringList('saved_records_$userId', existingRecordsJson);
      
      state = state.copyWith(
        records: [record, ...state.records],
        isSaving: false,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save product: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> removeProduct(String productId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Find the record to get the userId
      final recordToRemove = state.records.firstWhere(
        (record) => record.productId == productId,
        orElse: () => throw Exception('Record not found'),
      );

      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('saved_records_${recordToRemove.userId}') ?? [];
      
      // Remove the record
      final updatedRecordsJson = recordsJson.where((json) {
        final record = SavedRecord.fromMap(jsonDecode(json));
        return record.productId != productId;
      }).toList();
      
      // Save back to SharedPreferences
      await prefs.setStringList('saved_records_${recordToRemove.userId}', updatedRecordsJson);

      state = state.copyWith(
        records: state.records.where((record) => record.productId != productId).toList(),
        isLoading: false,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to remove product: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> removeRecord(String productId) async {
    return await removeProduct(productId);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Additional providers for saved screen functionality
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFilterProvider = StateProvider<String>((ref) => 'All');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedSortProvider = StateProvider<String>((ref) => 'Issuance Date (Newest First)');
final resetSavedScreenProvider = StateProvider<bool>((ref) => false);

// Computed providers
final availableStatusesProvider = Provider<List<String>>((ref) {
  final records = ref.watch(savedRecordsProvider).records;
  final statuses = records.map((record) => record.isVerified ? 'Verified' : 'Not Verified').toSet().toList();
  statuses.insert(0, 'All');
  return statuses;
});

final availableCategoriesProvider = Provider<List<String>>((ref) {
  final records = ref.watch(savedRecordsProvider).records;
  final categories = records.map((record) => record.productType).toSet().toList();
  categories.insert(0, 'All');
  return categories;
});

final sortOptionsProvider = Provider<List<String>>((ref) => [
  'Issuance Date (Newest First)',
  'Issuance Date (Oldest First)',
  'Product Name (A-Z)',
  'Product Name (Z-A)',
  'Product Type (A-Z)',
  'Product Type (Z-A)',
]);

final filteredRecordsProvider = Provider<List<SavedRecord>>((ref) {
  final records = ref.watch(savedRecordsProvider).records;
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedFilter = ref.watch(selectedFilterProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedSort = ref.watch(selectedSortProvider);

  var filteredRecords = records.where((record) {
    // Search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      if (!record.productName.toLowerCase().contains(query) &&
          !(record.brandName?.toLowerCase().contains(query) ?? false) &&
          !(record.manufacturer?.toLowerCase().contains(query) ?? false) &&
          !(record.registrationNumber?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    // Status filter
    if (selectedFilter != 'All') {
      final isVerified = selectedFilter == 'Verified';
      if (record.isVerified != isVerified) {
        return false;
      }
    }

    // Category filter
    if (selectedCategory != 'All') {
      if (record.productType != selectedCategory) {
        return false;
      }
    }

    return true;
  }).toList();

  // Sort records
  switch (selectedSort) {
    case 'Issuance Date (Newest First)':
      filteredRecords.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      break;
    case 'Issuance Date (Oldest First)':
      filteredRecords.sort((a, b) => a.savedAt.compareTo(b.savedAt));
      break;
    case 'Product Name (A-Z)':
      filteredRecords.sort((a, b) => a.productName.compareTo(b.productName));
      break;
    case 'Product Name (Z-A)':
      filteredRecords.sort((a, b) => b.productName.compareTo(a.productName));
      break;
    case 'Product Type (A-Z)':
      filteredRecords.sort((a, b) => a.productType.compareTo(b.productType));
      break;
    case 'Product Type (Z-A)':
      filteredRecords.sort((a, b) => b.productType.compareTo(a.productType));
      break;
  }

  return filteredRecords;
});

// Main provider
final savedRecordsProvider = StateNotifierProvider<SavedRecordsNotifier, SavedRecordsState>((ref) {
  return SavedRecordsNotifier();
});