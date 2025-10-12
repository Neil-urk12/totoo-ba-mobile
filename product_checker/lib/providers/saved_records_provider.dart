import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drug_product.dart';
import '../data/mock_data.dart';

class SavedRecordsNotifier extends StateNotifier<List<DrugProduct>> {
  SavedRecordsNotifier() : super(MockData.savedDrugProducts);

  // Add a new drug product
  void addRecord(DrugProduct record) {
    state = [...state, record];
  }

  // Remove a drug product
  void removeRecord(String id) {
    state = state.where((record) => record.id != id).toList();
  }

  // Update a drug product
  void updateRecord(DrugProduct updatedRecord) {
    state = state.map((record) {
      if (record.id == updatedRecord.id) {
        return updatedRecord;
      }
      return record;
    }).toList();
  }

  // Clear all records
  void clearAllRecords() {
    state = [];
  }

  // Search records by generic name, brand name, or registration number
  List<DrugProduct> searchRecords(String query) {
    if (query.isEmpty) return state;
    
    final lowercaseQuery = query.toLowerCase();
    return state.where((record) {
      return record.genericName.toLowerCase().contains(lowercaseQuery) ||
             record.brandName.toLowerCase().contains(lowercaseQuery) ||
             record.registrationNumber.toLowerCase().contains(lowercaseQuery) ||
             record.manufacturer.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter records by status
  List<DrugProduct> filterByStatus(String status) {
    if (status == 'All') return state;
    return state.where((record) => record.status == status).toList();
  }

  // Filter records by classification
  List<DrugProduct> filterByClassification(String classification) {
    if (classification == 'All') return state;
    return state.where((record) => record.classification == classification).toList();
  }

  // Sort records by issuance date (newest first)
  List<DrugProduct> sortByIssuanceDate() {
    final sortedList = List<DrugProduct>.from(state);
    sortedList.sort((a, b) => b.issuanceDate.compareTo(a.issuanceDate));
    return sortedList;
  }

  // Sort records by expiry date (soonest first)
  List<DrugProduct> sortByExpiryDate() {
    final sortedList = List<DrugProduct>.from(state);
    sortedList.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return sortedList;
  }

  // Sort records by generic name
  List<DrugProduct> sortByGenericName() {
    final sortedList = List<DrugProduct>.from(state);
    sortedList.sort((a, b) => a.genericName.compareTo(b.genericName));
    return sortedList;
  }

  // Sort records by brand name
  List<DrugProduct> sortByBrandName() {
    final sortedList = List<DrugProduct>.from(state);
    sortedList.sort((a, b) => a.brandName.compareTo(b.brandName));
    return sortedList;
  }

  // Sort records by manufacturer
  List<DrugProduct> sortByManufacturer() {
    final sortedList = List<DrugProduct>.from(state);
    sortedList.sort((a, b) => a.manufacturer.compareTo(b.manufacturer));
    return sortedList;
  }
}

// Provider for saved records
final savedRecordsProvider = StateNotifierProvider<SavedRecordsNotifier, List<DrugProduct>>((ref) {
  return SavedRecordsNotifier();
});

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for selected filter
final selectedFilterProvider = StateProvider<String>((ref) => 'All');

// Provider for selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Provider for selected sort option
final selectedSortProvider = StateProvider<String>((ref) => 'Issuance Date (Newest First)');

// Provider for filtered and searched records with memoization
final filteredRecordsProvider = Provider<List<DrugProduct>>((ref) {
  final records = ref.watch(savedRecordsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final statusFilter = ref.watch(selectedFilterProvider);
  final classificationFilter = ref.watch(selectedCategoryProvider);
  final sortOption = ref.watch(selectedSortProvider);

  // Early return if no filters applied
  if (searchQuery.isEmpty && statusFilter == 'All' && classificationFilter == 'All') {
    return _applySorting(records, sortOption);
  }

  var filteredRecords = records;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    final lowercaseQuery = searchQuery.toLowerCase();
    filteredRecords = filteredRecords.where((record) {
      return record.genericName.toLowerCase().contains(lowercaseQuery) ||
             record.brandName.toLowerCase().contains(lowercaseQuery) ||
             record.registrationNumber.toLowerCase().contains(lowercaseQuery) ||
             record.manufacturer.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Apply status filter
  if (statusFilter != 'All') {
    filteredRecords = filteredRecords.where((record) => 
        record.status == statusFilter).toList();
  }

  // Apply classification filter
  if (classificationFilter != 'All') {
    filteredRecords = filteredRecords.where((record) => 
        record.classification == classificationFilter).toList();
  }

  // Apply sorting
  return _applySorting(filteredRecords, sortOption);
});

// Helper function to apply sorting
List<DrugProduct> _applySorting(List<DrugProduct> records, String sortOption) {
  final sortedRecords = List<DrugProduct>.from(records);
  
  switch (sortOption) {
    case 'Issuance Date (Newest First)':
      sortedRecords.sort((a, b) => b.issuanceDate.compareTo(a.issuanceDate));
      break;
    case 'Issuance Date (Oldest First)':
      sortedRecords.sort((a, b) => a.issuanceDate.compareTo(b.issuanceDate));
      break;
    case 'Expiry Date (Soonest First)':
      sortedRecords.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      break;
    case 'Expiry Date (Latest First)':
      sortedRecords.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
      break;
    case 'Generic Name (A-Z)':
      sortedRecords.sort((a, b) => a.genericName.compareTo(b.genericName));
      break;
    case 'Generic Name (Z-A)':
      sortedRecords.sort((a, b) => b.genericName.compareTo(a.genericName));
      break;
    case 'Brand Name (A-Z)':
      sortedRecords.sort((a, b) => a.brandName.compareTo(b.brandName));
      break;
    case 'Brand Name (Z-A)':
      sortedRecords.sort((a, b) => b.brandName.compareTo(a.brandName));
      break;
    case 'Manufacturer (A-Z)':
      sortedRecords.sort((a, b) => a.manufacturer.compareTo(b.manufacturer));
      break;
    case 'Manufacturer (Z-A)':
      sortedRecords.sort((a, b) => b.manufacturer.compareTo(a.manufacturer));
      break;
    case 'Status':
      sortedRecords.sort((a, b) => a.status.compareTo(b.status));
      break;
    default:
      // Default to newest issuance date first
      sortedRecords.sort((a, b) => b.issuanceDate.compareTo(a.issuanceDate));
  }
  
  return sortedRecords;
}

// Provider for available categories
final availableCategoriesProvider = Provider<List<String>>((ref) {
  return MockData.availableCategories;
});

// Provider for available statuses
final availableStatusesProvider = Provider<List<String>>((ref) {
  return MockData.availableStatuses;
});

// Provider for sort options
final sortOptionsProvider = Provider<List<String>>((ref) {
  return MockData.sortOptions;
});

// Provider to trigger reset of saved screen state
final resetSavedScreenProvider = StateProvider<bool>((ref) => false);
