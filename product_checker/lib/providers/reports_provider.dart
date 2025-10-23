import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../services/reported_products_service.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Sort option provider
final selectedSortOptionProvider = StateProvider<String>((ref) => 'Report Date (Newest First)');

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => true);

// Reported Products Service provider
final reportedProductsServiceProvider = Provider<ReportedProductsService>((ref) {
  return ReportedProductsService();
});

// Reports state provider
final reportsStateProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  final service = ref.watch(reportedProductsServiceProvider);
  return ReportsNotifier(service);
});

// Reports provider (now uses the state notifier)
final reportsProvider = Provider<List<Report>>((ref) {
  return ref.watch(reportsStateProvider).reports;
});

// Reports state class
class ReportsState {
  final List<Report> reports;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  static const int pageSize = 25;

  const ReportsState({
    this.reports = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentPage = 0,
  });

  ReportsState copyWith({
    List<Report>? reports,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Reports Notifier class
class ReportsNotifier extends StateNotifier<ReportsState> {
  final ReportedProductsService _service;

  ReportsNotifier(this._service) : super(const ReportsState());

  /// Load all reports from Supabase (initial load)
  Future<void> loadAllReports() async {
    final reports = await _service.getAllReports(
      limit: ReportsState.pageSize,
      offset: 0,
    );
    state = ReportsState(
      reports: reports,
      hasMore: reports.length >= ReportsState.pageSize,
      currentPage: 1,
    );
  }

  /// Load more reports (pagination)
  Future<void> loadMoreReports() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final offset = state.currentPage * ReportsState.pageSize;
    final moreReports = await _service.getAllReports(
      limit: ReportsState.pageSize,
      offset: offset,
    );

    state = state.copyWith(
      reports: [...state.reports, ...moreReports],
      isLoadingMore: false,
      hasMore: moreReports.length >= ReportsState.pageSize,
      currentPage: state.currentPage + 1,
    );
  }

  /// Load reports for a specific user
  Future<void> loadUserReports(String userId) async {
    final reports = await _service.getUserReports(
      userId,
      limit: ReportsState.pageSize,
      offset: 0,
    );
    state = ReportsState(
      reports: reports,
      hasMore: reports.length >= ReportsState.pageSize,
      currentPage: 1,
    );
  }

  /// Create a new report
  Future<Report?> createReport({
    String? userId, // Nullable for anonymous reports
    required String productName,
    String? brandName,
    String? registrationNumber,
    required String description,
    String? reporterName,
    String? location,
    String? storeName,
  }) async {
    final report = await _service.createReport(
      userId: userId,
      productName: productName,
      brandName: brandName,
      registrationNumber: registrationNumber,
      description: description,
      reporterName: reporterName,
      location: location,
      storeName: storeName,
    );

    if (report != null) {
      state = state.copyWith(reports: [report, ...state.reports]);
    }

    return report;
  }

  /// Delete a report
  Future<bool> deleteReport(String reportId) async {
    final success = await _service.deleteReport(reportId);
    
    if (success) {
      state = state.copyWith(
        reports: state.reports.where((report) => report.id != reportId).toList(),
      );
    }

    return success;
  }

  /// Update local state with a new report (for optimistic updates)
  void addReportLocally(Report report) {
    state = state.copyWith(reports: [report, ...state.reports]);
  }

  /// Remove report from local state (for optimistic updates)
  void removeReportLocally(String reportId) {
    state = state.copyWith(
      reports: state.reports.where((report) => report.id != reportId).toList(),
    );
  }

  /// Refresh reports (reload from beginning)
  Future<void> refreshReports() async {
    await loadAllReports();
  }
}

// Filtered reports provider with memoization
final filteredReportsProvider = Provider<List<Report>>((ref) {
  final reportsState = ref.watch(reportsStateProvider);
  final reports = reportsState.reports;
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedSortOption = ref.watch(selectedSortOptionProvider);

  // Early return if no search query
  if (searchQuery.isEmpty) {
    return _applySorting(reports, selectedSortOption);
  }

  // Apply search filter
  final filteredReports = reports.where((report) {
    final lowercaseQuery = searchQuery.toLowerCase();
    return report.productName.toLowerCase().contains(lowercaseQuery) ||
           report.brandName?.toLowerCase().contains(lowercaseQuery) == true ||
           report.description.toLowerCase().contains(lowercaseQuery) ||
           report.location?.toLowerCase().contains(lowercaseQuery) == true ||
           report.storeName?.toLowerCase().contains(lowercaseQuery) == true;
  }).toList();

  // Apply sorting
  return _applySorting(filteredReports, selectedSortOption);
});

// Pagination state provider
final reportsPaginationProvider = Provider<ReportsState>((ref) {
  return ref.watch(reportsStateProvider);
});

// Helper function to apply sorting
List<Report> _applySorting(List<Report> reports, String sortOption) {
  final sortedReports = List<Report>.from(reports);
  sortedReports.sort((a, b) {
    switch (sortOption) {
      case 'Report Date (Newest First)':
        return b.reportDate.compareTo(a.reportDate);
      case 'Report Date (Oldest First)':
        return a.reportDate.compareTo(b.reportDate);
      case 'Product Name (A-Z)':
        return a.productName.compareTo(b.productName);
      case 'Product Name (Z-A)':
        return b.productName.compareTo(a.productName);
      case 'Brand Name (A-Z)':
        return (a.brandName ?? '').compareTo(b.brandName ?? '');
      case 'Brand Name (Z-A)':
        return (b.brandName ?? '').compareTo(a.brandName ?? '');
      case 'Location (A-Z)':
        return (a.location ?? '').compareTo(b.location ?? '');
      case 'Location (Z-A)':
        return (b.location ?? '').compareTo(a.location ?? '');
      default:
        return b.reportDate.compareTo(a.reportDate);
    }
  });
  return sortedReports;
}

// Loading simulation provider
final loadingSimulationProvider = FutureProvider<void>((ref) async {
  // Minimal delay for smooth transition
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Set loading to false
  ref.read(isLoadingProvider.notifier).state = false;
});

// Reports screen controller
class ReportsScreenController extends StateNotifier<void> {
  ReportsScreenController(this.ref) : super(null);
  
  final Ref ref;

  void updateSearchQuery(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }

  void updateSortOption(String sortOption) {
    ref.read(selectedSortOptionProvider.notifier).state = sortOption;
  }

  void startLoading() {
    ref.read(isLoadingProvider.notifier).state = true;
  }

  void stopLoading() {
    ref.read(isLoadingProvider.notifier).state = false;
  }

  void simulateLoading() async {
    startLoading();
    await Future.delayed(const Duration(milliseconds: 300));
    stopLoading();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Reports screen controller provider
final reportsScreenControllerProvider = StateNotifierProvider<ReportsScreenController, void>((ref) {
  return ReportsScreenController(ref);
});

// Provider to trigger reset of reports screen state
final resetReportsScreenProvider = StateProvider<bool>((ref) => false);

// Sort options provider
final reportSortOptionsProvider = Provider<List<String>>((ref) => [
  'Report Date (Newest First)',
  'Report Date (Oldest First)',
  'Product Name (A-Z)',
  'Product Name (Z-A)',
  'Brand Name (A-Z)',
  'Brand Name (Z-A)',
  'Location (A-Z)',
  'Location (Z-A)',
]);
