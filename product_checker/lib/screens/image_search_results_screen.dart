import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/generic_product.dart';
import '../providers/image_search_provider.dart';
import '../providers/saved_records_provider.dart';
import '../widgets/generic_product_card.dart';
import 'image_search_screen.dart';
import 'image_processing_screen.dart';
import 'report_form_screen.dart';

class ResultInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const ResultInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

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
            // Reset the provider state before going back
            ref.read(imageSearchProvider.notifier).reset();
            // Navigate back to ImageSearchScreen
            Navigator.of(context).pop();
          },
        ),
      ),
      body: provider.isCompleted 
        ? _buildResultsState(context, ref, provider)
        : _buildLoadingState(context),
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
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context, ImageSearchStateModel provider) {
    final resultInfo = _getResultInfo(provider.searchResult);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: resultInfo.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                resultInfo.icon,
                color: resultInfo.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  resultInfo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: resultInfo.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.resultMessage ?? resultInfo.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (provider.detectedProductType != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Detected Type: ${provider.detectedProductType}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (provider.confidence != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Confidence: ${_formatConfidence(provider.confidence!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    if (provider.isVerified && provider.searchResults.isNotEmpty) {
      final mainProduct = provider.searchResults.first;
      final alternativeMatches = provider.searchResults.length > 1 
          ? provider.searchResults.skip(1).toList() 
          : <GenericProduct>[];
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GenericProductCard(
            product: mainProduct,
            onTap: () => _showProductDetails(context, mainProduct),
          ),
          
          // Alternative matches section
          if (alternativeMatches.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Alternative Matches',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Fixed height for horizontal scroll
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: alternativeMatches.length,
                itemBuilder: (context, index) {
                  final product = alternativeMatches[index];
                  return Container(
                    width: 280, // Fixed width for each card
                    margin: EdgeInsets.only(
                      right: index < alternativeMatches.length - 1 ? 16 : 0,
                    ),
                    child: Card(
                      child: InkWell(
                        onTap: () => _showProductDetails(context, product),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with verification status
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      product.productTypeDisplay,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: product.isVerified 
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: product.isVerified 
                                            ? Colors.green.withValues(alpha: 0.3)
                                            : Colors.red.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          product.isVerified ? Icons.verified : Icons.warning,
                                          size: 12,
                                          color: product.isVerified ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.isVerified ? 'Verified' : 'Not Verified',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: product.isVerified ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Product name
                              Text(
                                product.displayName,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              
                              // Key details
                              if (product.manufacturer != null) ...[
                                _buildCompactDetailRow(context, Icons.business, product.manufacturer!),
                                const SizedBox(height: 4),
                              ],
                              if (product.registrationNumber != null) ...[
                                _buildCompactDetailRow(context, Icons.assignment, product.registrationNumber!),
                                const SizedBox(height: 4),
                              ],
                              if (product.dosageForm != null) ...[
                                _buildCompactDetailRow(context, Icons.medication, product.dosageForm!),
                                const SizedBox(height: 4),
                              ],
                              
                              const Spacer(),
                              
                              // Confidence score
                              if (product.confidence != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Confidence: ${_formatConfidence(product.confidence!)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      );
    } else {
      return _buildResultState(context, ref, provider);
    }
  }

  Widget _buildCompactDetailRow(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildResultState(BuildContext context, WidgetRef ref, ImageSearchStateModel provider) {
    final resultInfo = _getResultInfo(provider.searchResult);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: resultInfo.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: resultInfo.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            resultInfo.icon,
            size: 64,
            color: resultInfo.color,
          ),
          const SizedBox(height: 16),
          Text(
            resultInfo.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: resultInfo.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.resultMessage ?? resultInfo.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Detected information
          if (provider.detectedProductName != null || provider.detectedBrandName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Information',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (provider.detectedProductName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.label, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Product: ${provider.detectedProductName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (provider.detectedBrandName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Brand: ${provider.detectedBrandName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Action buttons based on result type
          ..._buildResultActions(context, ref, provider, resultInfo),
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
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
              // Reset state before going back
              ref.read(imageSearchProvider.notifier).reset();
              // Just pop back normally
              Navigator.of(context).pop();
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

  void _saveProduct(BuildContext context, WidgetRef ref, GenericProduct product) {
    // Convert to appropriate specific product type for saving
    dynamic specificProduct;
    
    switch (product.productType) {
      case 'drug':
        specificProduct = product.toDrugProduct();
        break;
      case 'food':
        specificProduct = product.toFoodProduct();
        break;
      case 'cosmetic':
        specificProduct = product.toCosmeticIndustry();
        break;
      case 'food_industry':
        specificProduct = product.toFoodIndustry();
        break;
      case 'medical_device':
        specificProduct = product.toMedicalDeviceIndustry();
        break;
      case 'drug_application':
        specificProduct = product.toDrugsNewApplications();
        break;
      default:
        // For unknown types, we'll save the generic product data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot save ${product.productTypeDisplay} - unsupported type'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
    }
    
    if (specificProduct != null) {
      // Add to saved records
      ref.read(savedRecordsProvider.notifier).addRecord(specificProduct);
      
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

  void _navigateToReportForm(BuildContext context, ImageSearchStateModel provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportFormScreen(
          imageFile: imageFile,
          detectedProductName: provider.detectedProductName,
          detectedBrandName: provider.detectedBrandName,
        ),
      ),
    );
  }

  void _retryProcessing(BuildContext context, WidgetRef ref) {
    // Reset the provider state completely
    ref.read(imageSearchProvider.notifier).reset();
    
    // Wait a moment for the reset to complete, then set image
    Future.delayed(const Duration(milliseconds: 50), () {
      ref.read(imageSearchProvider.notifier).setImage(imageFile);
      
      // Navigate back to processing screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ImageProcessingScreen(
              imageFile: imageFile,
            ),
          ),
        );
      }
    });
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
                              if (product.brandName != null) _buildDetailRow(context, 'Brand Name', product.brandName!),
                              if (product.genericName != null) _buildDetailRow(context, 'Generic Name', product.genericName!),
                              if (product.registrationNumber != null) _buildDetailRow(context, 'Registration Number', product.registrationNumber!),
                              if (product.licenseNumber != null) _buildDetailRow(context, 'License Number', product.licenseNumber!),
                              if (product.documentTrackingNumber != null) _buildDetailRow(context, 'Document Tracking Number', product.documentTrackingNumber!),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Dosage Information (for drugs)
                          if (product.productType == 'drug') ...[
                            _buildDetailSection(
                              context,
                              'Dosage Information',
                              [
                                if (product.dosageStrength != null) _buildDetailRow(context, 'Dosage Strength', product.dosageStrength!),
                                if (product.dosageForm != null) _buildDetailRow(context, 'Dosage Form', product.dosageForm!),
                                if (product.packaging != null) _buildDetailRow(context, 'Packaging', product.packaging!),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Classification Information (for drugs)
                          if (product.productType == 'drug') ...[
                            _buildDetailSection(
                              context,
                              'Classification Information',
                              [
                                if (product.classification != null) _buildDetailRow(context, 'Classification', product.classification!),
                                if (product.pharmacologicCategory != null) _buildDetailRow(context, 'Pharmacologic Category', product.pharmacologicCategory!),
                                if (product.applicationType != null) _buildDetailRow(context, 'Application Type', product.applicationType!),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Manufacturer Information
                          _buildDetailSection(
                            context,
                            'Manufacturer Information',
                            [
                              if (product.manufacturer != null) _buildDetailRow(context, 'Manufacturer', product.manufacturer!),
                              if (product.companyName != null) _buildDetailRow(context, 'Company Name', product.companyName!),
                              if (product.countryOfOrigin != null) _buildDetailRow(context, 'Country of Origin', product.countryOfOrigin!),
                              if (product.applicantCompany != null) _buildDetailRow(context, 'Applicant Company', product.applicantCompany!),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Additional Information
                          _buildDetailSection(
                            context,
                            'Additional Information',
                            [
                              if (product.description != null) _buildDetailRow(context, 'Description', product.description!),
                              if (product.typeOfProduct != null) _buildDetailRow(context, 'Type of Product', product.typeOfProduct!),
                              if (product.nameOfEstablishment != null) _buildDetailRow(context, 'Name of Establishment', product.nameOfEstablishment!),
                              if (product.owner != null) _buildDetailRow(context, 'Owner', product.owner!),
                              if (product.address != null) _buildDetailRow(context, 'Address', product.address!),
                              if (product.region != null) _buildDetailRow(context, 'Region', product.region!),
                              if (product.activity != null) _buildDetailRow(context, 'Activity', product.activity!),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Status Information
                          _buildDetailSection(
                            context,
                            'Status Information',
                            [
                              _buildDetailRow(context, 'Verification Status', product.isVerified ? 'Verified' : 'Not Verified'),
                              if (product.confidence != null) _buildDetailRow(context, 'Confidence', _formatConfidence(product.confidence!)),
                              if (product.issuanceDate != null) _buildDetailRow(context, 'Issuance Date', 
                                  '${product.issuanceDate!.day}/${product.issuanceDate!.month}/${product.issuanceDate!.year}'),
                              if (product.expiryDate != null) _buildDetailRow(context, 'Expiry Date', 
                                  '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}'),
                              if (product.daysUntilExpiry != null) _buildDetailRow(context, 'Days Until Expiry', '${product.daysUntilExpiry} days'),
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
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatConfidence(double confidence) {
    // Handle different confidence formats from backend
    if (confidence > 1.0) {
      // Backend sends percentage (e.g., 5.0 for 5%)
      return '${confidence.round()}%';
    } else {
      // Backend sends decimal (e.g., 0.05 for 5%)
      return '${(confidence * 100).round()}%';
    }
  }

  // Helper method to get result information
  ResultInfo _getResultInfo(ImageSearchResult result) {
    switch (result) {
      case ImageSearchResult.verified:
        return ResultInfo(
          title: 'Product Verified',
          description: 'This product is registered and verified in our database',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case ImageSearchResult.notFound:
        return ResultInfo(
          title: 'Product Not Found',
          description: 'This product was not found in our database. It may be unregistered or counterfeit.',
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
        );
      case ImageSearchResult.imageNotClear:
        return ResultInfo(
          title: 'Image Not Clear',
          description: 'The image quality is too poor to extract reliable data. Please try with a clearer image.',
          icon: Icons.blur_on,
          color: Colors.amber,
        );
      case ImageSearchResult.noDataExtracted:
        return ResultInfo(
          title: 'No Data Extracted',
          description: 'No meaningful product data could be extracted from the image. Please ensure the product is clearly visible.',
          icon: Icons.visibility_off,
          color: Colors.grey,
        );
      case ImageSearchResult.apiError:
        return ResultInfo(
          title: 'Service Error',
          description: 'The verification service is experiencing issues. This may be temporary - please try again.',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      case ImageSearchResult.unknown:
        return ResultInfo(
          title: 'Unknown Result',
          description: 'An unexpected result occurred. Please try again.',
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }

  // Helper method to build action buttons based on result type
  List<Widget> _buildResultActions(BuildContext context, WidgetRef ref, ImageSearchStateModel provider, ResultInfo resultInfo) {
    switch (provider.searchResult) {
      case ImageSearchResult.verified:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _saveProduct(context, ref, provider.searchResults.first),
              icon: const Icon(Icons.save),
              label: const Text('Save Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ];
        
      case ImageSearchResult.notFound:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToReportForm(context, provider),
              icon: const Icon(Icons.report),
              label: const Text('Report This Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ];
        
      case ImageSearchResult.imageNotClear:
      case ImageSearchResult.noDataExtracted:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: resultInfo.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ];
        
      case ImageSearchResult.apiError:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _retryProcessing(context, ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Try Different Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ];
        
      case ImageSearchResult.unknown:
        return [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Reset state before going back
                    ref.read(imageSearchProvider.notifier).reset();
                    // Just pop back normally
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ];
    }
  }
}
