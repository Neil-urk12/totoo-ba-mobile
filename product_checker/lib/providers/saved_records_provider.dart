import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generic_product.dart';
import '../models/saved_record.dart';
import '../services/saved_records_service.dart';

class SavedRecordsState {
  final List<SavedRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaving;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  static const int pageSize = 25;

  const SavedRecordsState({
    this.records = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSaving = false,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentPage = 0,
  });

  SavedRecordsState copyWith({
    List<SavedRecord>? records,
    bool? isLoading,
    String? errorMessage,
    bool? isSaving,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return SavedRecordsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool isProductSaved(String productId) {
    return records.any((record) => record.productId == productId);
  }

  bool get isEmpty => records.isEmpty;
}

class SavedRecordsNotifier extends StateNotifier<SavedRecordsState> {
  final SavedRecordsService _service = SavedRecordsService();

  SavedRecordsNotifier() : super(const SavedRecordsState());

  Future<void> loadSavedRecords(String userId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 0,
        hasMore: true,
      );

      final records = await _service.getSavedRecords(
        userId,
        limit: SavedRecordsState.pageSize,
        offset: 0,
      );

      state = state.copyWith(
        records: records,
        isLoading: false,
        errorMessage: null,
        hasMore: records.length >= SavedRecordsState.pageSize,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load saved records: ${e.toString()}',
      );
    }
  }

  Future<void> loadMoreSavedRecords(String userId) async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);

      final offset = state.currentPage * SavedRecordsState.pageSize;
      final moreRecords = await _service.getSavedRecords(
        userId,
        limit: SavedRecordsState.pageSize,
        offset: offset,
      );

      state = state.copyWith(
        records: [...state.records, ...moreRecords],
        isLoadingMore: false,
        hasMore: moreRecords.length >= SavedRecordsState.pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more saved records: ${e.toString()}',
      );
    }
  }

  Future<bool> saveProduct(GenericProduct product, String userId, String searchType) async {
    try {
      state = state.copyWith(isSaving: true, errorMessage: null);

      // Check if product is already saved
      final isAlreadySaved = await _service.isProductSaved(userId, product.id);
      if (isAlreadySaved) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Product is already saved',
        );
        return false;
      }

      final record = SavedRecord.fromGenericProduct(
        product: product,
        userId: userId,
        searchType: searchType,
      );

      // Save to Supabase
      final savedRecord = await _service.createSavedRecord(record);
      
      if (savedRecord != null) {
        state = state.copyWith(
          records: [savedRecord, ...state.records],
          isSaving: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save product',
        );
        return false;
      }
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

      // Delete from Supabase
      final success = await _service.deleteSavedRecord(
        recordToRemove.userId,
        productId,
      );

      if (success) {
        state = state.copyWith(
          records: state.records.where((record) => record.productId != productId).toList(),
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to remove product',
        );
        return false;
      }
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

  Future<void> refreshSavedRecords(String userId) async {
    await loadSavedRecords(userId);
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
  final categories = records.map((record) => record.searchType).toSet().toList();
  categories.insert(0, 'All');
  return categories;
});

final sortOptionsProvider = Provider<List<String>>((ref) => [
  'Issuance Date (Newest First)',
  'Issuance Date (Oldest First)',
  'Product Name (A-Z)',
  'Product Name (Z-A)',
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

    // Category filter (by search type)
    if (selectedCategory != 'All') {
      if (record.searchType != selectedCategory) {
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
  }

  return filteredRecords;
});

// Main provider
final savedRecordsProvider = StateNotifierProvider<SavedRecordsNotifier, SavedRecordsState>((ref) {
  return SavedRecordsNotifier();
});