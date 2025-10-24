class FoodProduct {
  final String registrationNumber;
  final String? companyName;
  final String? productName;
  final String? brandName;
  final String? typeOfProduct;
  final DateTime? issuanceDate;
  final DateTime? expiryDate;

  const FoodProduct({
    required this.registrationNumber,
    this.companyName,
    this.productName,
    this.brandName,
    this.typeOfProduct,
    this.issuanceDate,
    this.expiryDate,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    return FoodProduct(
      registrationNumber: json['registration_number'] as String,
      companyName: json['company_name'] as String?,
      productName: json['product_name'] as String?,
      brandName: json['brand_name'] as String?,
      typeOfProduct: json['type_of_product'] as String?,
      issuanceDate: json['issuance_date'] != null 
          ? DateTime.parse(json['issuance_date'] as String)
          : null,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registration_number': registrationNumber,
      'company_name': companyName,
      'product_name': productName,
      'brand_name': brandName,
      'type_of_product': typeOfProduct,
      'issuance_date': issuanceDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  FoodProduct copyWith({
    String? registrationNumber,
    String? companyName,
    String? productName,
    String? brandName,
    String? typeOfProduct,
    DateTime? issuanceDate,
    DateTime? expiryDate,
  }) {
    return FoodProduct(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      companyName: companyName ?? this.companyName,
      productName: productName ?? this.productName,
      brandName: brandName ?? this.brandName,
      typeOfProduct: typeOfProduct ?? this.typeOfProduct,
      issuanceDate: issuanceDate ?? this.issuanceDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  // Helper getter for display name (combines product and brand name)
  String get displayName {
    if (productName != null && brandName != null) {
      return '$productName ($brandName)';
    } else if (productName != null) {
      return productName!;
    } else if (brandName != null) {
      return brandName!;
    } else {
      return registrationNumber;
    }
  }

  // Helper getter for status based on expiry date
  String get status {
    if (expiryDate == null) return 'Unknown';
    
    final now = DateTime.now();
    if (expiryDate!.isBefore(now)) {
      return 'Expired';
    } else if (expiryDate!.isBefore(now.add(const Duration(days: 30)))) {
      return 'Expiring Soon';
    } else {
      return 'Active';
    }
  }

  // Helper getter for days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    return expiryDate!.difference(now).inDays;
  }

  // Helper getter for company display name
  String get companyDisplayName => companyName ?? 'Unknown Company';

  // Helper getter for type display name
  String get typeDisplayName => typeOfProduct ?? 'Unknown Type';
}

enum FoodProductStatus {
  active,
  expiringSoon,
  expired,
  unknown,
}

extension FoodProductStatusExtension on FoodProductStatus {
  String get displayName {
    switch (this) {
      case FoodProductStatus.active:
        return 'Active';
      case FoodProductStatus.expiringSoon:
        return 'Expiring Soon';
      case FoodProductStatus.expired:
        return 'Expired';
      case FoodProductStatus.unknown:
        return 'Unknown';
    }
  }
}
