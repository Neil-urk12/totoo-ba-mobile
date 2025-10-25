import 'drug_product.dart';
import 'food_product.dart';
import 'cosmetic_industry.dart';
import 'food_industry.dart';
import 'medical_device_industry.dart';
import 'drugs_new_applications.dart';

// Generic product model that can represent all product types
class GenericProduct {
  final String id;
  final String productType; // 'drug', 'food', 'cosmetic', 'medical_device', 'drug_application'
  final String? productName;
  final String? brandName;
  final String? manufacturer;
  final String? registrationNumber;
  final String? licenseNumber;
  final String? documentTrackingNumber;
  final String? description;
  final List<String>? warnings;
  final double? confidence;
  final bool isVerified;
  final DateTime? issuanceDate;
  final DateTime? expiryDate;
  final Map<String, dynamic>? additionalData;
  
  // Industry-specific fields
  final String? nameOfEstablishment;
  final String? owner;
  final String? address;
  final String? region;
  final String? activity;
  final String? companyName;
  final String? typeOfProduct;
  
  // Drug-specific fields
  final String? genericName;
  final String? dosageStrength;
  final String? dosageForm;
  final String? classification;
  final String? pharmacologicCategory;
  final String? applicationType;
  final String? packaging;
  final String? countryOfOrigin;
  
  // Applicant-specific fields
  final String? applicantCompany;

  const GenericProduct({
    required this.id,
    required this.productType,
    this.productName,
    this.brandName,
    this.manufacturer,
    this.registrationNumber,
    this.licenseNumber,
    this.documentTrackingNumber,
    this.description,
    this.warnings,
    this.confidence,
    this.isVerified = false,
    this.issuanceDate,
    this.expiryDate,
    this.additionalData,
    this.nameOfEstablishment,
    this.owner,
    this.address,
    this.region,
    this.activity,
    this.companyName,
    this.typeOfProduct,
    this.genericName,
    this.dosageStrength,
    this.dosageForm,
    this.classification,
    this.pharmacologicCategory,
    this.applicationType,
    this.packaging,
    this.countryOfOrigin,
    this.applicantCompany,
  });

  factory GenericProduct.fromJson(Map<String, dynamic> json) {
    return GenericProduct(
      id: json['id'] ?? json['registration_number'] ?? json['license_number'] ?? json['document_tracking_number'] ?? 'unknown',
      productType: json['product_type'] ?? 'unknown',
      productName: json['product_name'],
      brandName: json['brand_name'],
      manufacturer: json['manufacturer'],
      registrationNumber: json['registration_number'],
      licenseNumber: json['license_number'],
      documentTrackingNumber: json['document_tracking_number'],
      description: json['description'],
      warnings: json['warnings'] != null ? List<String>.from(json['warnings']) : null,
      confidence: json['confidence']?.toDouble(),
      isVerified: json['is_verified'] ?? false,
      issuanceDate: json['issuance_date'] != null ? DateTime.parse(json['issuance_date']) : null,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      additionalData: json['additional_data'],
      nameOfEstablishment: json['name_of_establishment'],
      owner: json['owner'],
      address: json['address'],
      region: json['region'],
      activity: json['activity'],
      companyName: json['company_name'],
      typeOfProduct: json['type_of_product'],
      genericName: json['generic_name'],
      dosageStrength: json['dosage_strength'],
      dosageForm: json['dosage_form'],
      classification: json['classification'],
      pharmacologicCategory: json['pharmacologic_category'],
      applicationType: json['application_type'],
      packaging: json['packaging'],
      countryOfOrigin: json['country_of_origin'],
      applicantCompany: json['applicant_company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_type': productType,
      'product_name': productName,
      'brand_name': brandName,
      'manufacturer': manufacturer,
      'registration_number': registrationNumber,
      'license_number': licenseNumber,
      'document_tracking_number': documentTrackingNumber,
      'description': description,
      'warnings': warnings,
      'confidence': confidence,
      'is_verified': isVerified,
      'issuance_date': issuanceDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'additional_data': additionalData,
      'name_of_establishment': nameOfEstablishment,
      'owner': owner,
      'address': address,
      'region': region,
      'activity': activity,
      'company_name': companyName,
      'type_of_product': typeOfProduct,
      'generic_name': genericName,
      'dosage_strength': dosageStrength,
      'dosage_form': dosageForm,
      'classification': classification,
      'pharmacologic_category': pharmacologicCategory,
      'application_type': applicationType,
      'packaging': packaging,
      'country_of_origin': countryOfOrigin,
      'applicant_company': applicantCompany,
    };
  }

  // Helper getters for display
  String get displayName {
    switch (productType) {
      case 'drug':
        if (genericName != null && brandName != null) {
          return '$genericName ($brandName)';
        } else if (genericName != null) {
          return genericName!;
        } else if (brandName != null) {
          return brandName!;
        } else if (productName != null) {
          return productName!;
        }
        break;
      case 'food':
        if (productName != null && brandName != null) {
          return '$productName ($brandName)';
        } else if (productName != null) {
          return productName!;
        } else if (brandName != null) {
          return brandName!;
        }
        break;
      case 'cosmetic':
      case 'food_industry':
      case 'medical_device':
        return nameOfEstablishment ?? 'Unknown Establishment';
      case 'drug_application':
        if (genericName != null && brandName != null) {
          return '$genericName ($brandName)';
        } else if (genericName != null) {
          return genericName!;
        } else if (brandName != null) {
          return brandName!;
        }
        break;
      case 'unknown':
      default:
        // For unknown types, try to find any available name
        if (productName != null && brandName != null) {
          return '$productName ($brandName)';
        } else if (productName != null) {
          return productName!;
        } else if (brandName != null) {
          return brandName!;
        } else if (genericName != null) {
          return genericName!;
        } else if (nameOfEstablishment != null) {
          return nameOfEstablishment!;
        }
        break;
    }
    return id;
  }

  String get productTypeDisplay {
    switch (productType) {
      case 'drug':
        return 'Drug Product';
      case 'food':
        return 'Food Product';
      case 'cosmetic':
        return 'Cosmetic Industry';
      case 'food_industry':
        return 'Food Industry';
      case 'medical_device':
        return 'Medical Device Industry';
      case 'drug_application':
        return 'Drug Application';
      default:
        return 'Unknown Product';
    }
  }

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

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    return expiryDate!.difference(now).inDays;
  }

  // Convert to specific product types for compatibility
  DrugProduct? toDrugProduct() {
    if (productType != 'drug') return null;
    
    return DrugProduct(
      id: id,
      registrationNumber: registrationNumber ?? 'Not Available',
      genericName: genericName ?? productName ?? 'Unknown',
      brandName: brandName ?? 'Unknown Brand',
      dosageStrength: dosageStrength ?? 'Unknown',
      dosageForm: dosageForm ?? 'Unknown',
      classification: classification ?? 'Unknown',
      pharmacologicCategory: pharmacologicCategory ?? 'Unknown',
      manufacturer: manufacturer ?? 'Unknown Manufacturer',
      countryOfOrigin: countryOfOrigin ?? 'Unknown',
      applicationType: applicationType ?? 'Unknown',
      issuanceDate: issuanceDate ?? DateTime.now().subtract(const Duration(days: 365)),
      expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      additionalData: additionalData,
    );
  }

  FoodProduct? toFoodProduct() {
    if (productType != 'food') return null;
    
    return FoodProduct(
      registrationNumber: registrationNumber ?? id,
      companyName: companyName ?? manufacturer,
      productName: productName,
      brandName: brandName,
      typeOfProduct: typeOfProduct,
      issuanceDate: issuanceDate,
      expiryDate: expiryDate,
    );
  }

  CosmeticIndustry? toCosmeticIndustry() {
    if (productType != 'cosmetic') return null;
    
    return CosmeticIndustry(
      licenseNumber: licenseNumber ?? id,
      nameOfEstablishment: nameOfEstablishment ?? 'Unknown Establishment',
      owner: owner ?? 'Unknown Owner',
      address: address ?? 'Unknown Address',
      region: region ?? 'Unknown Region',
      activity: activity ?? 'Unknown Activity',
      issuanceDate: issuanceDate ?? DateTime.now().subtract(const Duration(days: 365)),
      expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
    );
  }

  FoodIndustry? toFoodIndustry() {
    if (productType != 'food_industry') return null;
    
    return FoodIndustry(
      licenseNumber: licenseNumber ?? id,
      nameOfEstablishment: nameOfEstablishment ?? 'Unknown Establishment',
      owner: owner ?? 'Unknown Owner',
      address: address ?? 'Unknown Address',
      region: region ?? 'Unknown Region',
      activity: activity ?? 'Unknown Activity',
      issuanceDate: issuanceDate ?? DateTime.now().subtract(const Duration(days: 365)),
      expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
    );
  }

  MedicalDeviceIndustry? toMedicalDeviceIndustry() {
    if (productType != 'medical_device') return null;
    
    return MedicalDeviceIndustry(
      licenseNumber: licenseNumber ?? id,
      nameOfEstablishment: nameOfEstablishment ?? 'Unknown Establishment',
      owner: owner ?? 'Unknown Owner',
      address: address ?? 'Unknown Address',
      region: region ?? 'Unknown Region',
      activity: activity ?? 'Unknown Activity',
      issuanceDate: issuanceDate ?? DateTime.now().subtract(const Duration(days: 365)),
      expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
    );
  }

  DrugsNewApplications? toDrugsNewApplications() {
    if (productType != 'drug_application') return null;
    
    return DrugsNewApplications(
      documentTrackingNumber: documentTrackingNumber ?? id,
      applicantCompany: applicantCompany ?? manufacturer,
      brandName: brandName,
      genericName: genericName,
      dosageStrength: dosageStrength,
      dosageForm: dosageForm,
      packaging: packaging,
      pharmacologicCategory: pharmacologicCategory,
      applicationType: applicationType,
    );
  }
}

enum ProductType {
  drug,
  food,
  cosmetic,
  foodIndustry,
  medicalDevice,
  drugApplication,
  unknown,
}

extension ProductTypeExtension on ProductType {
  String get displayName {
    switch (this) {
      case ProductType.drug:
        return 'Drug Product';
      case ProductType.food:
        return 'Food Product';
      case ProductType.cosmetic:
        return 'Cosmetic Industry';
      case ProductType.foodIndustry:
        return 'Food Industry';
      case ProductType.medicalDevice:
        return 'Medical Device Industry';
      case ProductType.drugApplication:
        return 'Drug Application';
      case ProductType.unknown:
        return 'Unknown Product';
    }
  }

  String get apiValue {
    switch (this) {
      case ProductType.drug:
        return 'drug';
      case ProductType.food:
        return 'food';
      case ProductType.cosmetic:
        return 'cosmetic';
      case ProductType.foodIndustry:
        return 'food_industry';
      case ProductType.medicalDevice:
        return 'medical_device';
      case ProductType.drugApplication:
        return 'drug_application';
      case ProductType.unknown:
        return 'unknown';
    }
  }
}
