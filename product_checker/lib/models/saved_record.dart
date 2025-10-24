import 'generic_product.dart';

class SavedRecord {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String? brandName;
  final String? genericName;
  final String? registrationNumber;
  final String? manufacturer;
  final bool isVerified;
  final double? confidence;
  final DateTime savedAt;
  final String searchType; // 'text' or 'image'

  const SavedRecord({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.brandName,
    this.genericName,
    this.registrationNumber,
    this.manufacturer,
    required this.isVerified,
    this.confidence,
    required this.savedAt,
    required this.searchType,
  });

  factory SavedRecord.fromMap(Map<String, dynamic> map) {
    return SavedRecord(
      id: map['id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      brandName: map['brand_name'],
      genericName: map['generic_name'],
      registrationNumber: map['registration_number'],
      manufacturer: map['manufacturer'],
      isVerified: map['is_verified'] ?? false,
      confidence: map['confidence']?.toDouble(),
      savedAt: map['saved_at'] is String 
          ? DateTime.parse(map['saved_at'])
          : (map['saved_at'] as DateTime?) ?? DateTime.now(),
      searchType: map['search_type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'brand_name': brandName,
      'generic_name': genericName,
      'registration_number': registrationNumber,
      'manufacturer': manufacturer,
      'is_verified': isVerified,
      'confidence': confidence,
      'saved_at': savedAt.toIso8601String(),
      'search_type': searchType,
    };
  }

  factory SavedRecord.fromGenericProduct({
    required GenericProduct product,
    required String userId,
    required String searchType,
  }) {
    return SavedRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      productId: product.id,
      productName: product.productName ?? 'Unknown Product',
      brandName: product.brandName,
      genericName: product.genericName,
      registrationNumber: product.registrationNumber,
      manufacturer: product.manufacturer,
      isVerified: product.isVerified,
      confidence: product.confidence,
      savedAt: DateTime.now(),
      searchType: searchType,
    );
  }

  GenericProduct toGenericProduct() {
    return GenericProduct(
      id: productId,
      productType: 'unknown', // Default since we don't store product type anymore
      productName: productName,
      brandName: brandName,
      genericName: genericName,
      registrationNumber: registrationNumber,
      manufacturer: manufacturer,
      isVerified: isVerified,
      confidence: confidence,
    );
  }
}
