import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/drug_product.dart';
import '../providers/image_search_provider.dart';
import '../providers/saved_records_provider.dart';
import 'image_search_screen.dart';

class ImageSearchResultsScreen extends ConsumerWidget {
  final File imageFile;
  
  const ImageSearchResultsScreen({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(imageSearchProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
          body: provider.searchResults.isEmpty && !provider.isCompleted 
            ? _buildLoadingState(context) 
            : _buildResultsState(context, ref, provider),
        );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading results...'),
        ],
      ),
    );
  }

  Widget _buildResultsState(BuildContext context, WidgetRef ref, ImageSearchStateModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search summary
          _buildSearchSummary(context, provider),
          const SizedBox(height: 24),
          
          // Image preview
          _buildImagePreview(context),
          const SizedBox(height: 24),
          
          // Results section
          _buildResultsSection(context, ref, provider),
          const SizedBox(height: 24),
          
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context, ImageSearchStateModel provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search Completed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Found ${provider.searchResults.length} matching products',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, WidgetRef ref, ImageSearchStateModel provider) {
    if (provider.searchResults.isEmpty) {
      return _buildNoResults(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matching Products',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.searchResults.map((product) => _buildProductCard(context, ref, product)),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any matching products in our database. Try taking a clearer photo or check if the product is in our system.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, DrugProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.manufacturer,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              _buildVerificationBadge(context, product.status == 'Active'),
            ],
          ),
          const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(context, 'Reg: ${product.registrationNumber}'),
                const SizedBox(width: 8),
                _buildInfoChip(context, 'Exp: ${product.expiryDate.year}-${product.expiryDate.month.toString().padLeft(2, '0')}-${product.expiryDate.day.toString().padLeft(2, '0')}'),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showProductDetails(context, product),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveProduct(context, ref, product),
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(BuildContext context, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.warning,
            size: 14,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isVerified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate back to home screen, then to image search screen
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Navigate to image search screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ImageSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Search Another Product'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
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
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
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
                          'Product Details',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: dragScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product.displayName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.manufacturer,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Details
                        _buildDetailRow('Registration Number', product.registrationNumber),
                        _buildDetailRow('Dosage Strength', product.dosageStrength),
                        _buildDetailRow('Dosage Form', product.dosageForm),
                        _buildDetailRow('Classification', product.classification),
                        _buildDetailRow('Pharmacologic Category', product.pharmacologicCategory),
                        _buildDetailRow('Country of Origin', product.countryOfOrigin),
                        _buildDetailRow('Application Type', product.applicationType),
                        _buildDetailRow('Issuance Date', '${product.issuanceDate.day}/${product.issuanceDate.month}/${product.issuanceDate.year}'),
                        _buildDetailRow('Expiry Date', '${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}'),
                        _buildDetailRow('Status', product.status),
                        _buildDetailRow('Days Until Expiry', '${product.daysUntilExpiry} days'),
                        
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct(BuildContext context, WidgetRef ref, DrugProduct product) {
    // Add to saved records
    ref.read(savedRecordsProvider.notifier).addRecord(product);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.displayName} saved to records'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
