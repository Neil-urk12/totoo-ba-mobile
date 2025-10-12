import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/report.dart';
import '../providers/reports_provider.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final String? detectedProductName;
  final String? detectedBrandName;
  
  const ReportFormScreen({
    super.key,
    this.imageFile,
    this.detectedProductName,
    this.detectedBrandName,
  });

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _reporterNameController = TextEditingController();
  
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with detected information if available
    if (widget.detectedProductName != null) {
      _productNameController.text = widget.detectedProductName!;
    }
    if (widget.detectedBrandName != null) {
      _brandNameController.text = widget.detectedBrandName!;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandNameController.dispose();
    _registrationNumberController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _storeNameController.dispose();
    _reporterNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Product'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitReport,
            child: Text(
              'Submit',
              style: TextStyle(
                color: _isSubmitting 
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Report Unregistered Product',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Help us identify and verify products by reporting unregistered items',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Image Preview (if available)
              if (widget.imageFile != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      widget.imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Product Information Section
              _buildSectionHeader(context, 'Product Information', Icons.inventory_2),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _productNameController,
                label: 'Product Name',
                hint: 'Enter the product name',
                isRequired: true,
                icon: Icons.label,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _brandNameController,
                label: 'Brand Name',
                hint: 'Enter the brand name (optional)',
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _registrationNumberController,
                label: 'Registration Number',
                hint: 'Enter registration number if visible (optional)',
                icon: Icons.confirmation_number,
              ),
              const SizedBox(height: 24),

              // Report Details Section
              _buildSectionHeader(context, 'Report Details', Icons.description),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe the product and why you think it might be unregistered',
                isRequired: true,
                icon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Where did you find this product?',
                isRequired: true,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _storeNameController,
                label: 'Store Name',
                hint: 'Name of the store where you found it',
                isRequired: true,
                icon: Icons.store,
              ),
              const SizedBox(height: 24),

              // Reporter Information Section
              _buildSectionHeader(context, 'Reporter Information', Icons.person),
              const SizedBox(height: 16),
              
              // Anonymous toggle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAnonymous ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAnonymous ? 'Anonymous Report' : 'Personal Report',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAnonymous 
                              ? 'Your identity will not be shared'
                              : 'Your name will be included in the report',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !_isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = !value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Reporter name field (only if not anonymous)
              if (!_isAnonymous) ...[
                _buildTextField(
                  controller: _reporterNameController,
                  label: 'Your Name',
                  hint: 'Enter your name',
                  isRequired: true,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
              ],

              // Privacy Notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy & Security',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your report will be reviewed by our team. All information is kept confidential and used only for product verification purposes.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Report'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null,
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create report
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: _productNameController.text.trim(),
        brandName: _brandNameController.text.trim().isEmpty 
          ? null 
          : _brandNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim().isEmpty 
          ? null 
          : _registrationNumberController.text.trim(),
        description: _descriptionController.text.trim(),
        reporterName: _isAnonymous 
          ? null 
          : _reporterNameController.text.trim(),
        reportDate: DateTime.now(),
        location: _locationController.text.trim(),
        storeName: _storeNameController.text.trim(),
      );

      // Add report to the reports provider
      ref.read(reportsStateProvider.notifier).addReport(report);
      await Future.delayed(const Duration(seconds: 1));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
