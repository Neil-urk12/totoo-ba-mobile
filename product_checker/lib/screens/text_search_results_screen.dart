import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generic_product.dart';
import '../providers/text_search_provider.dart';
import '../widgets/generic_product_card.dart';
import 'report_form_screen.dart';

class TextSearchResultsScreen extends ConsumerWidget {
  final String searchQuery;
  final bool skipLoadingState;
  
  const TextSearchResultsScreen({
    super.key,
    required this.searchQuery,
    this.skipLoadingState = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(textSearchProvider);
    
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
      body: (!skipLoadingState && provider.searchResults.isEmpty && !provider.isCompleted) ||
             (skipLoadingState && provider.searchResult == TextSearchResult.unknown)
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

  Widget _buildResultsState(BuildContext context, WidgetRef ref, TextSearchStateModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search summary
          _buildSearchSummary(context, provider),
          const SizedBox(height: 24),
          
          // Search query display
          _buildSearchQueryDisplay(context),
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

  Widget _buildSearchSummary(BuildContext context, TextSearchStateModel provider) {
    // Determine color scheme based on search result
    Color statusColor;
    Color backgroundColor;
    Color borderColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (provider.searchResult) {
      case TextSearchResult.verified:
        statusColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green.withValues(alpha: 0.3);
        statusIcon = Icons.check_circle;
        statusText = 'Product Verified';
        statusDescription = 'This product is registered and verified in our database';
        break;
      case TextSearchResult.notFound:
        statusColor = Colors.orange;
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        borderColor = Colors.orange.withValues(alpha: 0.3);
        statusIcon = Icons.warning;
        statusText = 'Product Not Found';
        statusDescription = 'This product was not found in our database';
        break;
      case TextSearchResult.invalidQuery:
        statusColor = Colors.yellow;
        backgroundColor = Colors.yellow.withValues(alpha: 0.1);
        borderColor = Colors.yellow.withValues(alpha: 0.3);
        statusIcon = Icons.info;
        statusText = 'Invalid Search Query';
        statusDescription = 'Please provide a more specific search term';
        break;
      case TextSearchResult.apiError:
        statusColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red.withValues(alpha: 0.3);
        statusIcon = Icons.error;
        statusText = 'Search Error';
        statusDescription = 'Unable to search the database at this time';
        break;
      case TextSearchResult.unknown:
        statusColor = Colors.grey;
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        borderColor = Colors.grey.withValues(alpha: 0.3);
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
        statusDescription = 'Unable to determine product status';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          // Show result count if we have results
          if (provider.searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Found ${provider.searchResults.length} matching product${provider.searchResults.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchQueryDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Search Query',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, WidgetRef ref, TextSearchStateModel provider) {
    if (provider.isProductRegistered && provider.searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Main product card
          GenericProductCard(
            product: provider.searchResults.first,
            onTap: () => _showProductDetails(context, provider.searchResults.first),
            searchType: 'text',
          ),
          
          // Show additional results if available
          if (provider.searchResults.length > 1) ...[
            const SizedBox(height: 16),
            Text(
              'Additional Matches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280, // Increased height from 200 to 280
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.searchResults.length - 1,
                itemBuilder: (context, index) {
                  final product = provider.searchResults[index + 1];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < provider.searchResults.length - 2 ? 8 : 0, // Reduced spacing between cards
                      left: index == 0 ? 0 : 4, // Small left margin for non-first items
                    ),
                    child: GenericProductCard(
                      product: product,
                      onTap: () => _showProductDetails(context, product),
                      searchType: 'text',
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      );
    } else {
      return _buildUnregisteredProduct(context, ref, provider);
    }
  }

  Widget _buildUnregisteredProduct(BuildContext context, WidgetRef ref, TextSearchStateModel provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Product Not Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This product was not found in our database. You can report it to help us improve our records.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToReportForm(context, provider),
              icon: const Icon(Icons.report),
              label: const Text('Report Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate back to home screen
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

  void _showProductDetails(BuildContext context, GenericProduct product) {
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
                          '${product.productTypeDisplay} Details',
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
                            context,
                            'Product Information',
                            [
                              _buildDetailRow(context, 'Product Name', product.displayName),
                              if (product.brandName != null && product.brandName!.isNotEmpty)
                                _buildDetailRow(context, 'Brand Name', product.brandName!),
                              if (product.genericName != null && product.genericName!.isNotEmpty)
                                _buildDetailRow(context, 'Generic Name', product.genericName!),
                              if (product.registrationNumber != null && product.registrationNumber!.isNotEmpty)
                                _buildDetailRow(context, 'Registration Number', product.registrationNumber!),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Dosage Information (for drugs)
                          if (product.productType == 'drug' && 
                              (product.dosageStrength != null || product.dosageForm != null))
                            _buildDetailSection(
                              context,
                              'Dosage Information',
                              [
                                if (product.dosageStrength != null && product.dosageStrength!.isNotEmpty)
                                  _buildDetailRow(context, 'Dosage Strength', product.dosageStrength!),
                                if (product.dosageForm != null && product.dosageForm!.isNotEmpty)
                                  _buildDetailRow(context, 'Dosage Form', product.dosageForm!),
                              ],
                            ),

                          if (product.productType == 'drug' && 
                              (product.dosageStrength != null || product.dosageForm != null))
                            const SizedBox(height: 20),

                          // Classification Information
                          if (product.classification != null || product.pharmacologicCategory != null)
                            _buildDetailSection(
                              context,
                              'Classification Information',
                              [
                                if (product.classification != null && product.classification!.isNotEmpty)
                                  _buildDetailRow(context, 'Classification', product.classification!),
                                if (product.pharmacologicCategory != null && product.pharmacologicCategory!.isNotEmpty)
                                  _buildDetailRow(context, 'Pharmacologic Category', product.pharmacologicCategory!),
                              ],
                            ),

                          if (product.classification != null || product.pharmacologicCategory != null)
                            const SizedBox(height: 20),

                          // Manufacturer Information
                          _buildDetailSection(
                            context,
                            'Manufacturer Information',
                            [
                              if (product.manufacturer != null && product.manufacturer!.isNotEmpty)
                                _buildDetailRow(context, 'Manufacturer', product.manufacturer!),
                              if (product.countryOfOrigin != null && product.countryOfOrigin!.isNotEmpty)
                                _buildDetailRow(context, 'Country of Origin', product.countryOfOrigin!),
                              if (product.applicationType != null && product.applicationType!.isNotEmpty)
                                _buildDetailRow(context, 'Application Type', product.applicationType!),
                              if (product.applicantCompany != null && product.applicantCompany!.isNotEmpty)
                                _buildDetailRow(context, 'Applicant Company', product.applicantCompany!),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Additional Information
                          _buildDetailSection(
                            context,
                            'Additional Information',
                            [
                              if (product.licenseNumber != null && product.licenseNumber!.isNotEmpty)
                                _buildDetailRow(context, 'License Number', product.licenseNumber!),
                              if (product.documentTrackingNumber != null && product.documentTrackingNumber!.isNotEmpty)
                                _buildDetailRow(context, 'Document Tracking Number', product.documentTrackingNumber!),
                              if (product.packaging != null && product.packaging!.isNotEmpty)
                                _buildDetailRow(context, 'Packaging', product.packaging!),
                              if (product.confidence != null)
                                _buildDetailRow(context, 'Confidence', '${(product.confidence! * 100).round()}%'),
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

  Widget _buildDetailSection(BuildContext context, String title, List<Widget> children) {
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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

  void _navigateToReportForm(BuildContext context, TextSearchStateModel provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportFormScreen(
          imageFile: null, // No image for text search
          detectedProductName: provider.detectedProductName,
          detectedBrandName: provider.detectedBrandName,
        ),
      ),
    );
  }
}