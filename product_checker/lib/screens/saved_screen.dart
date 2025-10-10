import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/saved_records_provider.dart';
import '../widgets/verification_record_card.dart';
import '../models/verification_record.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

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

  Future<void> _simulateLoading() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredRecordsProvider);
    final availableCategories = ref.watch(availableCategoriesProvider);
    final availableStatuses = ref.watch(availableStatusesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedFilterProvider);

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
                      hintText: 'Search by product, brand, or CPR number...',
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
                          'Category',
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
                  : filteredRecords.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            return VerificationRecordCard(
                              record: record,
                              onTap: () => _showRecordDetails(context, record),
                              onDelete: () => _showDeleteConfirmation(context, record),
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
              ),
            );
          }).toList(),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: Theme.of(context).textTheme.bodyMedium,
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
                        // Product name skeleton with shimmer effect
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
                        
                        // Brand skeleton
                        _buildAnimatedSkeleton(
                          context,
                          height: 16,
                          width: 120,
                          delay: Duration(milliseconds: index * 50 + 200),
                        ),
                        const SizedBox(height: 12),
                        
                        // CPR number and status row
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
                        const SizedBox(height: 12),
                        
                        // Date and category row
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
            'No Saved Verifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start verifying products to save them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home screen for verification
              DefaultTabController.of(context).animateTo(0);
            },
            icon: const Icon(Icons.search),
            label: const Text('Start Verifying'),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortOptions.map((option) {
              return ListTile(
                title: Text(option),
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
            }),
          ],
        ),
      ),
    );
  }

  void _showRecordDetails(BuildContext context, VerificationRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
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
                'Verification Details',
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
                      _buildDetailRow('Product Name', record.productName),
                      _buildDetailRow('Brand', record.brand),
                      _buildDetailRow('CPR Number', record.cprNumber),
                      _buildDetailRow('Category', record.category),
                      _buildDetailRow('Status', record.status.toUpperCase()),
                      _buildDetailRow('FDA Status', record.fdaStatus),
                      _buildDetailRow('Verification Date', 
                          '${record.verificationDate.day}/${record.verificationDate.month}/${record.verificationDate.year}'),
                    ],
                  ),
                ),
              ),
            ],
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

  void _showDeleteConfirmation(BuildContext context, VerificationRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Verification'),
        content: Text('Are you sure you want to delete "${record.productName}" from your saved verifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedRecordsProvider.notifier).removeRecord(record.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification deleted')),
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