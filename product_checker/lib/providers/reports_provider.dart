import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/report.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Sort option provider
final selectedSortOptionProvider = StateProvider<String>((ref) => 'Report Date (Newest First)');

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => true);

// Reports provider
final reportsProvider = Provider<List<Report>>((ref) {
  return MockData.savedReports;
});

// Filtered reports provider
final filteredReportsProvider = Provider<List<Report>>((ref) {
  final reports = ref.watch(reportsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedSortOption = ref.watch(selectedSortOptionProvider);

  List<Report> filteredReports = reports;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredReports = filteredReports.where((report) {
      return report.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
             report.brandName?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
             report.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
             report.location?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
             report.storeName?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
    }).toList();
  }

  // Apply sorting
  filteredReports.sort((a, b) {
    switch (selectedSortOption) {
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

  return filteredReports;
});

// Loading simulation provider
final loadingSimulationProvider = FutureProvider<void>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 1500));
  
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
    await Future.delayed(const Duration(milliseconds: 1500));
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
