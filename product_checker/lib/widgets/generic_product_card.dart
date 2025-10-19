import 'package:flutter/material.dart';
import '../models/generic_product.dart';

class GenericProductCard extends StatelessWidget {
  final GenericProduct product;
  final VoidCallback? onTap;

  const GenericProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      product.productTypeDisplay,
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
                          size: 14,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Product details based on type
              ..._buildProductDetails(context),
              
              // Confidence score if available
              if (product.confidence != null) ...[
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
                      'Confidence: ${_formatConfidence(product.confidence!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Status and expiry information
              if (product.expiryDate != null) ...[
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
                      'Status: ${product.status}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (product.daysUntilExpiry != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${product.daysUntilExpiry} days left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProductDetails(BuildContext context) {
    final details = <Widget>[];
    
    switch (product.productType) {
      case 'drug':
        if (product.manufacturer != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Manufacturer', product.manufacturer!));
        }
        if (product.registrationNumber != null) {
          details.add(_buildDetailRow(context, Icons.assignment, 'Registration', product.registrationNumber!));
        }
        if (product.dosageStrength != null && product.dosageForm != null) {
          details.add(_buildDetailRow(context, Icons.medication, 'Dosage', '${product.dosageStrength} ${product.dosageForm}'));
        }
        if (product.genericName != null) {
          details.add(_buildDetailRow(context, Icons.science, 'Generic Name', product.genericName!));
        }
        if (product.classification != null) {
          details.add(_buildDetailRow(context, Icons.category, 'Classification', product.classification!));
        }
        if (product.countryOfOrigin != null) {
          details.add(_buildDetailRow(context, Icons.public, 'Country', product.countryOfOrigin!));
        }
        break;
        
      case 'food':
        if (product.companyName != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Company', product.companyName!));
        }
        if (product.typeOfProduct != null) {
          details.add(_buildDetailRow(context, Icons.category, 'Type', product.typeOfProduct!));
        }
        if (product.registrationNumber != null) {
          details.add(_buildDetailRow(context, Icons.assignment, 'Registration', product.registrationNumber!));
        }
        if (product.manufacturer != null) {
          details.add(_buildDetailRow(context, Icons.factory, 'Manufacturer', product.manufacturer!));
        }
        break;
        
      case 'cosmetic':
      case 'food_industry':
      case 'medical_device':
        if (product.owner != null) {
          details.add(_buildDetailRow(context, Icons.person, 'Owner', product.owner!));
        }
        if (product.address != null) {
          details.add(_buildDetailRow(context, Icons.location_on, 'Address', product.address!));
        }
        if (product.activity != null) {
          details.add(_buildDetailRow(context, Icons.work, 'Activity', product.activity!));
        }
        if (product.nameOfEstablishment != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Establishment', product.nameOfEstablishment!));
        }
        break;
        
      case 'drug_application':
        if (product.applicantCompany != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Applicant', product.applicantCompany!));
        }
        if (product.documentTrackingNumber != null) {
          details.add(_buildDetailRow(context, Icons.track_changes, 'Tracking', product.documentTrackingNumber!));
        }
        if (product.applicationType != null) {
          details.add(_buildDetailRow(context, Icons.description, 'Application Type', product.applicationType!));
        }
        if (product.genericName != null) {
          details.add(_buildDetailRow(context, Icons.science, 'Generic Name', product.genericName!));
        }
        break;
        
      default:
        // For unknown product types, show available fields
        if (product.manufacturer != null) {
          details.add(_buildDetailRow(context, Icons.business, 'Manufacturer', product.manufacturer!));
        }
        if (product.registrationNumber != null) {
          details.add(_buildDetailRow(context, Icons.assignment, 'Registration', product.registrationNumber!));
        }
        if (product.description != null) {
          details.add(_buildDetailRow(context, Icons.description, 'Description', product.description!));
        }
        if (product.genericName != null) {
          details.add(_buildDetailRow(context, Icons.science, 'Generic Name', product.genericName!));
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
    switch (product.productType) {
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
    switch (product.status) {
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
