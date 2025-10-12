class DrugsNewApplications {
  final String documentTrackingNumber;
  final String? applicantCompany;
  final String? brandName;
  final String? genericName;
  final String? dosageStrength;
  final String? dosageForm;
  final String? packaging;
  final String? pharmacologicCategory;
  final String? applicationType;

  const DrugsNewApplications({
    required this.documentTrackingNumber,
    this.applicantCompany,
    this.brandName,
    this.genericName,
    this.dosageStrength,
    this.dosageForm,
    this.packaging,
    this.pharmacologicCategory,
    this.applicationType,
  });

  factory DrugsNewApplications.fromJson(Map<String, dynamic> json) {
    return DrugsNewApplications(
      documentTrackingNumber: json['document_tracking_number'] as String,
      applicantCompany: json['applicant_company'] as String?,
      brandName: json['brand_name'] as String?,
      genericName: json['generic_name'] as String?,
      dosageStrength: json['dosage_strength'] as String?,
      dosageForm: json['dosage_form'] as String?,
      packaging: json['packaging'] as String?,
      pharmacologicCategory: json['pharmacologic_category'] as String?,
      applicationType: json['application_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_tracking_number': documentTrackingNumber,
      'applicant_company': applicantCompany,
      'brand_name': brandName,
      'generic_name': genericName,
      'dosage_strength': dosageStrength,
      'dosage_form': dosageForm,
      'packaging': packaging,
      'pharmacologic_category': pharmacologicCategory,
      'application_type': applicationType,
    };
  }

  DrugsNewApplications copyWith({
    String? documentTrackingNumber,
    String? applicantCompany,
    String? brandName,
    String? genericName,
    String? dosageStrength,
    String? dosageForm,
    String? packaging,
    String? pharmacologicCategory,
    String? applicationType,
  }) {
    return DrugsNewApplications(
      documentTrackingNumber: documentTrackingNumber ?? this.documentTrackingNumber,
      applicantCompany: applicantCompany ?? this.applicantCompany,
      brandName: brandName ?? this.brandName,
      genericName: genericName ?? this.genericName,
      dosageStrength: dosageStrength ?? this.dosageStrength,
      dosageForm: dosageForm ?? this.dosageForm,
      packaging: packaging ?? this.packaging,
      pharmacologicCategory: pharmacologicCategory ?? this.pharmacologicCategory,
      applicationType: applicationType ?? this.applicationType,
    );
  }

  // Helper getter for display name (combines generic and brand name)
  String get displayName {
    if (genericName != null && brandName != null) {
      return '$genericName ($brandName)';
    } else if (genericName != null) {
      return genericName!;
    } else if (brandName != null) {
      return brandName!;
    } else {
      return documentTrackingNumber;
    }
  }

  // Helper getter for company display name
  String get companyDisplayName => applicantCompany ?? 'Unknown Company';

  // Helper getter for dosage display
  String get dosageDisplay {
    if (dosageStrength != null && dosageForm != null) {
      return '$dosageStrength $dosageForm';
    } else if (dosageStrength != null) {
      return dosageStrength!;
    } else if (dosageForm != null) {
      return dosageForm!;
    } else {
      return 'Not specified';
    }
  }

  // Helper getter for category display
  String get categoryDisplay => pharmacologicCategory ?? 'Not specified';

  // Helper getter for application type display
  String get applicationTypeDisplay => applicationType ?? 'Not specified';

  // Helper getter for packaging display
  String get packagingDisplay => packaging ?? 'Not specified';

  // Helper getter for tracking number display
  String get trackingNumberDisplay => 'Tracking: $documentTrackingNumber';
}

enum DrugsNewApplicationsStatus {
  pending,
  underReview,
  approved,
  rejected,
  withdrawn,
}

extension DrugsNewApplicationsStatusExtension on DrugsNewApplicationsStatus {
  String get displayName {
    switch (this) {
      case DrugsNewApplicationsStatus.pending:
        return 'Pending';
      case DrugsNewApplicationsStatus.underReview:
        return 'Under Review';
      case DrugsNewApplicationsStatus.approved:
        return 'Approved';
      case DrugsNewApplicationsStatus.rejected:
        return 'Rejected';
      case DrugsNewApplicationsStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  String get colorCode {
    switch (this) {
      case DrugsNewApplicationsStatus.pending:
        return 'orange';
      case DrugsNewApplicationsStatus.underReview:
        return 'blue';
      case DrugsNewApplicationsStatus.approved:
        return 'green';
      case DrugsNewApplicationsStatus.rejected:
        return 'red';
      case DrugsNewApplicationsStatus.withdrawn:
        return 'gray';
    }
  }
}
