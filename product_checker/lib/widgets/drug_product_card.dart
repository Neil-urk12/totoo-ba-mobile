import 'package:flutter/material.dart';
import '../models/drug_product.dart';

class DrugProductCard extends StatelessWidget {
  final DrugProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DrugProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and expiry date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(context),
                  Text(
                    'Expires: ${_formatDate(product.expiryDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Generic name
              Text(
                product.genericName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Brand name
              Text(
                product.brandName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              
              // Registration Number and Classification
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      'Reg: ${product.registrationNumber}',
                      Icons.assignment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      product.classification,
                      Icons.category,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Dosage and Manufacturer
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      '${product.dosageStrength} ${product.dosageForm}',
                      Icons.medication,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      product.manufacturer,
                      Icons.business,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Status and Delete button
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: _getStatusColor(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.status,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      iconSize: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusColor = _getStatusColor(context);
    final statusText = product.status;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (product.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expiring soon':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  IconData _getStatusIcon() {
    switch (product.status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'expiring soon':
        return Icons.warning;
      case 'expired':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference < 0) {
      return 'Expired';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 30) {
      return '$difference days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
