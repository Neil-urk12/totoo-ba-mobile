import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/saved_records_provider.dart';
import '../widgets/drug_product_card.dart';
import '../models/drug_product.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Clear search state when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearSearchState();
      _simulateLoading();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearchState() {
    if (mounted) {
      // Clear search query and reset filters
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(selectedFilterProvider.notifier).state = 'All';
      ref.read(selectedCategoryProvider.notifier).state = 'All';
      ref.read(selectedSortProvider.notifier).state = 'Issuance Date (Newest First)';
      
      // Clear the search controller text
      _searchController.clear();
      
      // Mark as initialized
      _hasInitialized = true;
      
      // Force a rebuild to reflect the cleared state
      setState(() {});
    }
  }

  Future<void> _simulateLoading() async {
    setState(() {
      _isLoading = true;
    });
    
    // Minimal delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredRecordsProvider);
    final allRecords = ref.watch(savedRecordsProvider);
    
    // Listen for reset trigger
    ref.listen(resetSavedScreenProvider, (previous, next) {
      if (_hasInitialized) {
        _clearSearchState();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saved Verifications',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      IconButton(
                        onPressed: _showSortOptions,
                        icon: const Icon(Icons.sort),
                        tooltip: 'Sort Options',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by generic name, brand, registration number, or manufacturer...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          context,
                          'Status',
                          ref.read(selectedFilterProvider),
                          ref.read(availableStatusesProvider),
                          (value) {
                            ref.read(selectedFilterProvider.notifier).state = value ?? 'All';
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDropdown(
                          context,
                          'Classification',
                          ref.read(selectedCategoryProvider),
                          ref.read(availableCategoriesProvider),
                          (value) {
                            ref.read(selectedCategoryProvider.notifier).state = value ?? 'All';
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Records List
            Expanded(
              child: _isLoading
                  ? _buildSkeletonLoading(context)
                  : allRecords.isEmpty
                      ? _buildEmptyState(context)
                      : filteredRecords.isEmpty
                          ? _buildNoResultsState(context)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final product = filteredRecords[index];
                                return DrugProductCard(
                                  product: product,
                                  onTap: () => _showProductDetails(context, product),
                                  onDelete: () => _showDeleteConfirmation(context, product),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    String selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selectedValue,
          onChanged: onChanged,
          isExpanded: true,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: Theme.of(context).textTheme.bodyMedium,
          selectedItemBuilder: (BuildContext context) {
            return options.map<Widget>((String item) {
              return Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4, // Reduced from 6 to 4
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          elevation: 1, // Reduced elevation
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generic name skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSimpleSkeleton(context, height: 24),
                    ),
                    const SizedBox(width: 16),
                    _buildSimpleSkeleton(context, height: 24, width: 24),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Brand name skeleton
                _buildSimpleSkeleton(context, height: 16, width: 120),
                const SizedBox(height: 12),
                
                // Registration number and classification row
                Row(
                  children: [
                    _buildSimpleSkeleton(context, height: 16, width: 16),
                    const SizedBox(width: 8),
                    _buildSimpleSkeleton(context, height: 16, width: 100),
                    const Spacer(),
                    _buildSimpleSkeleton(context, height: 20, width: 80),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Dosage and manufacturer row
                Row(
                  children: [
                    _buildSimpleSkeleton(context, height: 16, width: 16),
                    const SizedBox(width: 8),
                    _buildSimpleSkeleton(context, height: 16, width: 80),
                    const Spacer(),
                    _buildSimpleSkeleton(context, height: 16, width: 100),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Saved Drug Products',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding drug products to save them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    final sortOptions = ref.read(sortOptionsProvider);
    final currentSort = ref.read(selectedSortProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: sortOptions.map((option) {
                  return ListTile(
                    title: Text(
                      option,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: currentSort == option 
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      ref.read(selectedSortProvider.notifier).state = option;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sorted by $option'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
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

  void _showProductDetails(BuildContext context, DrugProduct product) {
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
                          'Drug Product Details',
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
                          // Product Information
                          _buildDetailSection(
                            'Product Information',
                            [
                              _buildDetailRow('Generic Name', product.genericName),
                              _buildDetailRow('Brand Name', product.brandName),
                              _buildDetailRow('Registration Number', product.registrationNumber),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Dosage Information
                          _buildDetailSection(
                            'Dosage Information',
                            [
                              _buildDetailRow('Dosage Strength', product.dosageStrength),
                              _buildDetailRow('Dosage Form', product.dosageForm),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Classification Information
                          _buildDetailSection(
                            'Classification Information',
                            [
                              _buildDetailRow('Classification', product.classification),
                              _buildDetailRow('Pharmacologic Category', product.pharmacologicCategory),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Manufacturer Information
                          _buildDetailSection(
                            'Manufacturer Information',
                            [
                              _buildDetailRow('Manufacturer', product.manufacturer),
                              _buildDetailRow('Country of Origin', product.countryOfOrigin),
                              _buildDetailRow('Application Type', product.applicationType),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Status Information
                          _buildDetailSection(
                            'Status Information',
                            [
                              _buildDetailRow('Status', product.status),
                              _buildDetailRow('Issuance Date', 
                                  '${product.issuanceDate.day}/${product.issuanceDate.month}/${product.issuanceDate.year}'),
                              _buildDetailRow('Expiry Date', 
                                  '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}'),
                              _buildDetailRow('Days Until Expiry', '${product.daysUntilExpiry} days'),
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

  void _showDeleteConfirmation(BuildContext context, DrugProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drug Product'),
        content: Text('Are you sure you want to delete "${product.genericName} (${product.brandName})" from your saved products?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedRecordsProvider.notifier).removeRecord(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Drug product deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
