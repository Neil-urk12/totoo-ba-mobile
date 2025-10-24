import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../widgets/report_card_widget.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load reports from Supabase and clear search state when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
      _clearSearchState();
    });
  }

  Future<void> _loadReports() async {
    ref.read(isLoadingProvider.notifier).state = true;
    await ref.read(reportsStateProvider.notifier).loadAllReports();
    if (mounted) {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearchState() {
    if (mounted) {
      // Clear search query and reset sort option
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(selectedSortOptionProvider.notifier).state = 'Report Date (Newest First)';
      
      // Clear the search controller text
      _searchController.clear();
      
      // Mark as initialized
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final filteredReports = ref.watch(filteredReportsProvider);
    final controller = ref.read(reportsScreenControllerProvider.notifier);

    // Listen for reset trigger
    ref.listen(resetReportsScreenProvider, (previous, next) {
      if (_hasInitialized) {
        _clearSearchState();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Reports',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Products reported by users as unregistered or suspicious',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search and Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    controller.updateSearchQuery(value);
                  },
                ),

                const SizedBox(height: 16),

                // Sort Dropdown
                Row(
                  children: [
                    Icon(
                      Icons.sort,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showSortOptionsBottomSheet(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ref.watch(selectedSortOptionProvider),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: isLoading ? _buildSkeletonLoading() : _buildReportsList(filteredReports),
          ),
        ],
      ),
    );
  }


  Widget _buildReportsList(List<Report> filteredReports) {
    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No reports found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search query',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final reportsState = ref.watch(reportsStateProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!reportsState.isLoadingMore &&
            reportsState.hasMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(reportsStateProvider.notifier).loadMoreReports();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: filteredReports.length + (reportsState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredReports.length) {
            return _buildPaginationLoadingIndicator();
          }
          final report = filteredReports[index];
          return ReportCardWidget(
            report: report,
            onTap: () => _showReportDetails(report, ref.read(reportsScreenControllerProvider.notifier)),
          );
        },
      ),
    );
  }

  void _showReportDetails(Report report, ReportsScreenController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, dragScrollController) {
          // Create a separate scroll controller for the content
          final contentScrollController = ScrollController();
          
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Report Details',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: contentScrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Info
                          _buildDetailSection(
                            'Product Information',
                            [
                              _buildDetailRow('Product Name', report.productName),
                              if (report.brandName != null)
                                _buildDetailRow('Brand Name', report.brandName!),
                              if (report.registrationNumber != null)
                                _buildDetailRow('Registration Number', report.registrationNumber!),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Report Info
                          _buildDetailSection(
                            'Report Information',
                            [
                              _buildDetailRow('Reported By', report.reporterDisplay),
                              _buildDetailRow('Report Date', controller.formatDate(report.reportDate)),
                              _buildDetailRow('Time Since Report', report.timeSinceReport),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Location Info
                          if (report.location != null || report.storeName != null)
                            _buildDetailSection(
                              'Location Information',
                              [
                                if (report.storeName != null)
                                  _buildDetailRow('Store Name', report.storeName!),
                                if (report.location != null)
                                  _buildDetailRow('Location', report.location!),
                              ],
                            ),

                          if (report.location != null || report.storeName != null)
                            const SizedBox(height: 20),

                          // Description
                          _buildDetailSection(
                            'Description',
                            [
                              Text(
                                report.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptionsBottomSheet(BuildContext context, ReportsScreenController controller) {
    final sortOptions = ref.read(reportSortOptionsProvider);
    final currentSort = ref.read(selectedSortOptionProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: sortOptions.map((option) {
                  final isSelected = currentSort == option;
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: isSelected 
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      controller.updateSortOption(option);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4, // Reduced from 6 to 4
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          elevation: 1, // Reduced elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name skeleton
                _buildSimpleSkeleton(context, height: 20),
                const SizedBox(height: 8),
                
                // Registration number skeleton
                _buildSimpleSkeleton(context, height: 14, width: 150),
                const SizedBox(height: 8),
                
                // Reporter skeleton
                _buildSimpleSkeleton(context, height: 14, width: 120),
                const SizedBox(height: 12),
                
                // Description skeleton (3 lines)
                _buildSimpleSkeleton(context, height: 14),
                const SizedBox(height: 6),
                _buildSimpleSkeleton(context, height: 14, width: double.infinity * 0.8),
                const SizedBox(height: 6),
                _buildSimpleSkeleton(context, height: 14, width: double.infinity * 0.6),
                const SizedBox(height: 12),
                
                // Location skeleton
                Row(
                  children: [
                    _buildSimpleSkeleton(context, height: 16, width: 16),
                    const SizedBox(width: 8),
                    _buildSimpleSkeleton(context, height: 14, width: 200),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Time skeleton
                Row(
                  children: [
                    _buildSimpleSkeleton(context, height: 16, width: 16),
                    const SizedBox(width: 8),
                    _buildSimpleSkeleton(context, height: 14, width: 80),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleSkeleton(BuildContext context, {
    required double height,
    double? width,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPaginationLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}