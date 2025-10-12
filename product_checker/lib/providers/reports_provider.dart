import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/report.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Sort option provider
final selectedSortOptionProvider = StateProvider<String>((ref) => 'Report Date (Newest First)');

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => true);

// Reports state provider
final reportsStateProvider = StateNotifierProvider<ReportsNotifier, List<Report>>((ref) {
  return ReportsNotifier();
});

// Reports provider (now uses the state notifier)
final reportsProvider = Provider<List<Report>>((ref) {
  return ref.watch(reportsStateProvider);
});

// Reports Notifier class
class ReportsNotifier extends StateNotifier<List<Report>> {
  ReportsNotifier() : super(MockData.savedReports);

  void addReport(Report report) {
    state = [report, ...state];
  }

  void removeReport(String reportId) {
    state = state.where((report) => report.id != reportId).toList();
  }

  void updateReport(Report updatedReport) {
    state = state.map((report) {
      if (report.id == updatedReport.id) {
        return updatedReport;
      }
      return report;
    }).toList();
  }
}

// Filtered reports provider with memoization
final filteredReportsProvider = Provider<List<Report>>((ref) {
  final reports = ref.watch(reportsProvider);
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
