import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generic_product.dart';
import '../providers/auth_provider.dart';
import '../providers/saved_records_provider.dart';
import '../screens/signin_screen.dart';

class GenericProductCard extends ConsumerStatefulWidget {
  final GenericProduct product;
  final VoidCallback? onTap;
  final String searchType; // 'text' or 'image'

  const GenericProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.searchType = 'text',
  });

  @override
  ConsumerState<GenericProductCard> createState() => _GenericProductCardState();
}

class _GenericProductCardState extends ConsumerState<GenericProductCard> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final savedRecordsState = ref.watch(savedRecordsProvider);
    final isSaved = savedRecordsState.isProductSaved(widget.product.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header with product type and verification status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getProductTypeColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getProductTypeColor(context).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      widget.product.productTypeDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getProductTypeColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.product.isVerified 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.product.isVerified 
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.product.isVerified ? Icons.verified : Icons.warning,
                          size: 14,
                          color: widget.product.isVerified ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.product.isVerified ? 'Verified' : 'Not Verified',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.product.isVerified ? Colors.green : Colors.red,
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
                widget.product.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Product details based on type
              ..._buildProductDetails(context),
              
              // Confidence score if available
              if (widget.product.confidence != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confidence: ${_formatConfidence(widget.product.confidence!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Status and expiry information
              if (widget.product.expiryDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: _getStatusColor(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${widget.product.status}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.product.daysUntilExpiry != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${widget.product.daysUntilExpiry} days left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              
              // Save button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSaveProduct(context, authState, isSaved),
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    isSaved ? 'Saved' : 'Save Product',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSaved 
                        ? Colors.green.shade600
                        : Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    side: BorderSide.none,
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

  Future<void> _handleSaveProduct(BuildContext context, AuthState authState, bool isSaved) async {
    if (isSaved) {
      // Product is already saved, show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product is already saved'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!authState.isAuthenticated) {
      // User not authenticated, show login dialog
      final navigator = Navigator.of(context);
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login or create an account to save products.'),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => navigator.pop(true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Navigate to login screen
        final loginResult = await navigator.push<bool>(
          MaterialPageRoute(
            builder: (_) => const SignInScreen(),
          ),
        );

        // If login was successful, automatically save the product
        if (loginResult == true && mounted) {
          final newAuthState = ref.read(authProvider);
          if (newAuthState.isAuthenticated) {
            await _saveProductToSupabase(newAuthState.user!.id);
          }
        }
      }
    } else {
      // User is authenticated, save the product
      await _saveProductToSupabase(authState.user!.id);
    }
  }

  Future<void> _saveProductToSupabase(String userId) async {
    final savedRecordsNotifier = ref.read(savedRecordsProvider.notifier);
    
    final success = await savedRecordsNotifier.saveProduct(
      widget.product,
      userId,
      widget.searchType,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Product saved successfully!' 
                : 'Failed to save product. Please try again.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Widget> _buildProductDetails(BuildContext context) {
    final details = <Widget>[];
    
    switch (widget.product.productType) {
      case 'drug':
        if (widget.product.manufacturer != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Manufacturer', widget.product.manufacturer!));
        }
        if (widget.product.registrationNumber != null) {
          details.add(_buildDetailRow(context, Icons.assignment, 'Registration', widget.product.registrationNumber!));
        }
        if (widget.product.dosageStrength != null && widget.product.dosageForm != null) {
          details.add(_buildDetailRow(context, Icons.medication, 'Dosage', '${widget.product.dosageStrength} ${widget.product.dosageForm}'));
        }
        if (widget.product.genericName != null) {
          details.add(_buildDetailRow(context, Icons.science, 'Generic Name', widget.product.genericName!));
        }
        if (widget.product.classification != null) {
          details.add(_buildDetailRow(context, Icons.category, 'Classification', widget.product.classification!));
        }
        if (widget.product.countryOfOrigin != null) {
          details.add(_buildDetailRow(context, Icons.public, 'Country', widget.product.countryOfOrigin!));
        }
        break;
        
      case 'food':
        if (widget.product.companyName != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Company', widget.product.companyName!));
        }
        if (widget.product.typeOfProduct != null) {
          details.add(_buildDetailRow(context, Icons.category, 'Type', widget.product.typeOfProduct!));
        }
        if (widget.product.registrationNumber != null) {
          details.add(_buildDetailRow(context, Icons.assignment, 'Registration', widget.product.registrationNumber!));
        }
        if (widget.product.manufacturer != null) {
          details.add(_buildDetailRow(context, Icons.factory, 'Manufacturer', widget.product.manufacturer!));
        }
        break;
        
      case 'cosmetic':
      case 'food_industry':
      case 'medical_device':
        if (widget.product.owner != null) {
          details.add(_buildDetailRow(context, Icons.person, 'Owner', widget.product.owner!));
        }
        if (widget.product.address != null) {
          details.add(_buildDetailRow(context, Icons.location_on, 'Address', widget.product.address!));
        }
        if (widget.product.activity != null) {
          details.add(_buildDetailRow(context, Icons.work, 'Activity', widget.product.activity!));
        }
        if (widget.product.nameOfEstablishment != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Establishment', widget.product.nameOfEstablishment!));
        }
        break;
        
      case 'drug_application':
        if (widget.product.applicantCompany != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Applicant', widget.product.applicantCompany!));
        }
        if (widget.product.documentTrackingNumber != null) {
          details.add(_buildDetailRow(context, Icons.track_changes, 'Tracking', widget.product.documentTrackingNumber!));
        }
        if (widget.product.applicationType != null) {
          details.add(_buildDetailRow(context, Icons.description, 'Application Type', widget.product.applicationType!));
        }
        if (widget.product.genericName != null) {
          details.add(_buildDetailRow(context, Icons.science, 'Generic Name', widget.product.genericName!));
        }
        break;
        
      default:
        // For unknown product types, show available fields
        if (widget.product.manufacturer != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Manufacturer', widget.product.manufacturer!));
        }
        if (widget.product.registrationNumber != null) {
          details.add(_buildDetailRow(context, Icons.assignment, 'Registration', widget.product.registrationNumber!));
        }
        if (widget.product.description != null) {
          details.add(_buildDetailRow(context, Icons.description, 'Description', widget.product.description!));
        }
        if (widget.product.genericName != null) {
          details.add(_buildDetailRow(context, Icons.science, 'Generic Name', widget.product.genericName!));
        }
        break;
    }
    
    return details;
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProductTypeColor(BuildContext context) {
    switch (widget.product.productType) {
      case 'drug':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'cosmetic':
        return Colors.purple;
      case 'food_industry':
        return Colors.green;
      case 'medical_device':
        return Colors.teal;
      case 'drug_application':
        return Colors.indigo;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (widget.product.status) {
      case 'Active':
        return Colors.green;
      case 'Expiring Soon':
        return Colors.orange;
      case 'Expired':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }

  String _formatConfidence(double confidence) {
    // Handle different confidence formats from backend
    if (confidence > 1.0) {
      // Backend sends percentage (e.g., 40.0 for 40%)
      return '${confidence.round()}%';
    } else {
      // Backend sends decimal (e.g., 0.40 for 40%)
      return '${(confidence * 100).round()}%';
    }
  }
}
