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
    _simulateLoading();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearchState() {
    if (mounted && _hasInitialized) {
      // Clear search query and reset filters
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(selectedFilterProvider.notifier).state = 'All';
      ref.read(selectedCategoryProvider.notifier).state = 'All';
      
      // Clear the search controller text
      _searchController.clear();
      
      // Force a rebuild to reflect the cleared state
      setState(() {});
    }
  }

  Future<void> _simulateLoading() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredRecordsProvider);
    final allRecords = ref.watch(savedRecordsProvider);
    final availableCategories = ref.watch(availableCategoriesProvider);
    final availableStatuses = ref.watch(availableStatusesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedFilterProvider);
    
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
                          selectedStatus,
                          availableStatuses,
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
                          selectedCategory,
                          availableCategories,
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
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)), // Staggered animation
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)), // Slide up animation
              child: Opacity(
                opacity: value,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Generic name skeleton with shimmer effect
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildAnimatedSkeleton(
                                context,
                                height: 24,
                                width: double.infinity,
                                delay: Duration(milliseconds: index * 50),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildAnimatedSkeleton(
                              context,
                              height: 24,
                              width: 24,
                              delay: Duration(milliseconds: index * 50 + 100),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Brand name skeleton
                        _buildAnimatedSkeleton(
                          context,
                          height: 16,
                          width: 120,
                          delay: Duration(milliseconds: index * 50 + 200),
                        ),
                        const SizedBox(height: 12),
                        
                        // Registration number and classification row
                        Row(
                          children: [
                            _buildAnimatedSkeleton(
                              context,
                              height: 16,
                              width: 16,
                              delay: Duration(milliseconds: index * 50 + 300),
                            ),
                            const SizedBox(width: 8),
                            _buildAnimatedSkeleton(
                              context,
                              height: 16,
                              width: 100,
                              delay: Duration(milliseconds: index * 50 + 400),
                            ),
                            const Spacer(),
                            _buildAnimatedSkeleton(
                              context,
                              height: 20,
                              width: 80,
                              delay: Duration(milliseconds: index * 50 + 500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Dosage and manufacturer row
                        Row(
                          children: [
                            _buildAnimatedSkeleton(
                              context,
                              height: 16,
                              width: 16,
                              delay: Duration(milliseconds: index * 50 + 600),
                            ),
                            const SizedBox(width: 8),
                            _buildAnimatedSkeleton(
                              context,
                              height: 16,
                              width: 80,
                              delay: Duration(milliseconds: index * 50 + 700),
                            ),
                            const Spacer(),
                            _buildAnimatedSkeleton(
                              context,
                              height: 16,
                              width: 100,
                              delay: Duration(milliseconds: index * 50 + 800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedSkeleton(BuildContext context, {
    required double height,
    required double width,
    required Duration delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08 + (value * 0.12)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: AlwaysStoppedAnimation(value),
              builder: (context, child) {
                return CustomPaint(
                  painter: ShimmerPainter(
                    progress: value,
                    baseColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                );
              },
            ),
          ),
        );
      },
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
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Drug Product Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                
                // Details
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Generic Name', product.genericName),
                        _buildDetailRow('Brand Name', product.brandName),
                        _buildDetailRow('Registration Number', product.registrationNumber),
                        _buildDetailRow('Dosage Strength', product.dosageStrength),
                        _buildDetailRow('Dosage Form', product.dosageForm),
                        _buildDetailRow('Classification', product.classification),
                        _buildDetailRow('Pharmacologic Category', product.pharmacologicCategory),
                        _buildDetailRow('Manufacturer', product.manufacturer),
                        _buildDetailRow('Country of Origin', product.countryOfOrigin),
                        _buildDetailRow('Application Type', product.applicationType),
                        _buildDetailRow('Issuance Date', 
                            '${product.issuanceDate.day}/${product.issuanceDate.month}/${product.issuanceDate.year}'),
                        _buildDetailRow('Expiry Date', 
                            '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}'),
                        _buildDetailRow('Status', product.status),
                        _buildDetailRow('Days Until Expiry', '${product.daysUntilExpiry} days'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
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

class ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  ShimmerPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          baseColor,
          highlightColor,
          baseColor,
        ],
        stops: [
          0.0,
          0.5,
          1.0,
        ],
        transform: GradientRotation(progress * 2 * 3.14159),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.baseColor != baseColor ||
           oldDelegate.highlightColor != highlightColor;
  }
}