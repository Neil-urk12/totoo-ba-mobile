class DrugProduct {
  final String id;
  final String registrationNumber;
  final String genericName;
  final String brandName;
  final String dosageStrength;
  final String dosageForm;
  final String classification;
  final String pharmacologicCategory;
  final String manufacturer;
  final String countryOfOrigin;
  final String applicationType;
  final DateTime issuanceDate;
  final DateTime expiryDate;
  final String? imageUrl;
  final Map<String, dynamic>? additionalData;

  const DrugProduct({
    required this.id,
    required this.registrationNumber,
    required this.genericName,
    required this.brandName,
    required this.dosageStrength,
    required this.dosageForm,
    required this.classification,
    required this.pharmacologicCategory,
    required this.manufacturer,
    required this.countryOfOrigin,
    required this.applicationType,
    required this.issuanceDate,
    required this.expiryDate,
    this.imageUrl,
    this.additionalData,
  });

  factory DrugProduct.fromJson(Map<String, dynamic> json) {
    return DrugProduct(
      id: json['id'] as String,
      registrationNumber: json['registrationNumber'] as String,
      genericName: json['genericName'] as String,
      brandName: json['brandName'] as String,
      dosageStrength: json['dosageStrength'] as String,
      dosageForm: json['dosageForm'] as String,
      classification: json['classification'] as String,
      pharmacologicCategory: json['pharmacologicCategory'] as String,
      manufacturer: json['manufacturer'] as String,
      countryOfOrigin: json['countryOfOrigin'] as String,
      applicationType: json['applicationType'] as String,
      issuanceDate: DateTime.parse(json['issuanceDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      imageUrl: json['imageUrl'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'genericName': genericName,
      'brandName': brandName,
      'dosageStrength': dosageStrength,
      'dosageForm': dosageForm,
      'classification': classification,
      'pharmacologicCategory': pharmacologicCategory,
      'manufacturer': manufacturer,
      'countryOfOrigin': countryOfOrigin,
      'applicationType': applicationType,
      'issuanceDate': issuanceDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'imageUrl': imageUrl,
      'additionalData': additionalData,
    };
  }

  DrugProduct copyWith({
    String? id,
    String? registrationNumber,
    String? genericName,
    String? brandName,
    String? dosageStrength,
    String? dosageForm,
    String? classification,
    String? pharmacologicCategory,
    String? manufacturer,
    String? countryOfOrigin,
    String? applicationType,
    DateTime? issuanceDate,
    DateTime? expiryDate,
    String? imageUrl,
    Map<String, dynamic>? additionalData,
  }) {
    return DrugProduct(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      genericName: genericName ?? this.genericName,
      brandName: brandName ?? this.brandName,
      dosageStrength: dosageStrength ?? this.dosageStrength,
      dosageForm: dosageForm ?? this.dosageForm,
      classification: classification ?? this.classification,
      pharmacologicCategory: pharmacologicCategory ?? this.pharmacologicCategory,
      manufacturer: manufacturer ?? this.manufacturer,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      applicationType: applicationType ?? this.applicationType,
      issuanceDate: issuanceDate ?? this.issuanceDate,
      expiryDate: expiryDate ?? this.expiryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Helper getter for display name (combines generic and brand name)
  String get displayName => '$genericName ($brandName)';

  // Helper getter for status based on expiry date
  String get status {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) {
      return 'Expired';
    } else if (expiryDate.isBefore(now.add(const Duration(days: 30)))) {
      return 'Expiring Soon';
    } else {
      return 'Active';
    }
  }

  // Helper getter for days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}

enum DrugProductStatus {
  active,
  expiringSoon,
  expired,
}

extension DrugProductStatusExtension on DrugProductStatus {
  String get displayName {
    switch (this) {
      case DrugProductStatus.active:
        return 'Active';
      case DrugProductStatus.expiringSoon:
        return 'Expiring Soon';
      case DrugProductStatus.expired:
        return 'Expired';
    }
  }

  String get colorCode {
    switch (this) {
      case DrugProductStatus.active:
        return 'green';
      case DrugProductStatus.expiringSoon:
        return 'orange';
      case DrugProductStatus.expired:
        return 'red';
    }
  }
}
