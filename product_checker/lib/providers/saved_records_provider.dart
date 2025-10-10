import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verification_record.dart';
import '../data/mock_data.dart';

class SavedRecordsNotifier extends StateNotifier<List<VerificationRecord>> {
  SavedRecordsNotifier() : super(MockData.savedVerificationRecords);

  // Add a new verification record
  void addRecord(VerificationRecord record) {
    state = [...state, record];
  }

  // Remove a verification record
  void removeRecord(String id) {
    state = state.where((record) => record.id != id).toList();
  }

  // Update a verification record
  void updateRecord(VerificationRecord updatedRecord) {
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

  // Search records by product name, brand, or CPR number
  List<VerificationRecord> searchRecords(String query) {
    if (query.isEmpty) return state;
    
    final lowercaseQuery = query.toLowerCase();
    return state.where((record) {
      return record.productName.toLowerCase().contains(lowercaseQuery) ||
             record.brand.toLowerCase().contains(lowercaseQuery) ||
             record.cprNumber.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter records by status
  List<VerificationRecord> filterByStatus(String status) {
    if (status == 'All') return state;
    return state.where((record) => record.status == status.toLowerCase()).toList();
  }

  // Filter records by category
  List<VerificationRecord> filterByCategory(String category) {
    if (category == 'All') return state;
    return state.where((record) => record.category == category).toList();
  }

  // Sort records by date (newest first)
  List<VerificationRecord> sortByDate() {
    final sortedList = List<VerificationRecord>.from(state);
    sortedList.sort((a, b) => b.verificationDate.compareTo(a.verificationDate));
    return sortedList;
  }

  // Sort records by product name
  List<VerificationRecord> sortByName() {
    final sortedList = List<VerificationRecord>.from(state);
    sortedList.sort((a, b) => a.productName.compareTo(b.productName));
    return sortedList;
  }
}

// Provider for saved records
final savedRecordsProvider = StateNotifierProvider<SavedRecordsNotifier, List<VerificationRecord>>((ref) {
  return SavedRecordsNotifier();
});

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for selected filter
final selectedFilterProvider = StateProvider<String>((ref) => 'All');

// Provider for selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Provider for selected sort option
final selectedSortProvider = StateProvider<String>((ref) => 'Date (Newest First)');

// Provider for filtered and searched records
final filteredRecordsProvider = Provider<List<VerificationRecord>>((ref) {
  final records = ref.watch(savedRecordsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final statusFilter = ref.watch(selectedFilterProvider);
  final categoryFilter = ref.watch(selectedCategoryProvider);
  final sortOption = ref.watch(selectedSortProvider);

  var filteredRecords = records;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredRecords = filteredRecords.where((record) {
      final lowercaseQuery = searchQuery.toLowerCase();
      return record.productName.toLowerCase().contains(lowercaseQuery) ||
             record.brand.toLowerCase().contains(lowercaseQuery) ||
             record.cprNumber.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Apply status filter
  if (statusFilter != 'All') {
    filteredRecords = filteredRecords.where((record) => 
        record.status == statusFilter.toLowerCase()).toList();
  }

  // Apply category filter
  if (categoryFilter != 'All') {
    filteredRecords = filteredRecords.where((record) => 
        record.category == categoryFilter).toList();
  }

  // Apply sorting
  filteredRecords = _applySorting(filteredRecords, sortOption);

  return filteredRecords;
});

// Helper function to apply sorting
List<VerificationRecord> _applySorting(List<VerificationRecord> records, String sortOption) {
  final sortedRecords = List<VerificationRecord>.from(records);
  
  switch (sortOption) {
    case 'Date (Newest First)':
      sortedRecords.sort((a, b) => b.verificationDate.compareTo(a.verificationDate));
      break;
    case 'Date (Oldest First)':
      sortedRecords.sort((a, b) => a.verificationDate.compareTo(b.verificationDate));
      break;
    case 'Product Name (A-Z)':
      sortedRecords.sort((a, b) => a.productName.compareTo(b.productName));
      break;
    case 'Product Name (Z-A)':
      sortedRecords.sort((a, b) => b.productName.compareTo(a.productName));
      break;
    case 'Brand (A-Z)':
      sortedRecords.sort((a, b) => a.brand.compareTo(b.brand));
      break;
    case 'Brand (Z-A)':
      sortedRecords.sort((a, b) => b.brand.compareTo(a.brand));
      break;
    case 'Status':
      sortedRecords.sort((a, b) => a.status.compareTo(b.status));
      break;
    default:
      // Default to newest first
      sortedRecords.sort((a, b) => b.verificationDate.compareTo(a.verificationDate));
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
