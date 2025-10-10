import 'package:flutter/material.dart';
import '../models/verification_record.dart';

class VerificationRecordCard extends StatelessWidget {
  final VerificationRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const VerificationRecordCard({
    super.key,
    required this.record,
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
              // Header with status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(context),
                  Text(
                    _formatDate(record.verificationDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Product name
              Text(
                record.productName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Brand
              Text(
                record.brand,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              
              // CPR Number and Category
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      'CPR: ${record.cprNumber}',
                      Icons.assignment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      record.category,
                      Icons.category,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // FDA Status
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: _getStatusColor(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    record.fdaStatus,
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
    final statusText = _getStatusText();
    
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
    switch (record.status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'notverified':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  String _getStatusText() {
    switch (record.status.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'notverified':
        return 'Not Verified';
      default:
        return record.status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
