class VerificationRecord {
  final String id;
  final String productName;
  final String brand;
  final String cprNumber;
  final String category;
  final String status;
  final DateTime verificationDate;
  final String fdaStatus;
  final String? imageUrl;
  final Map<String, dynamic>? additionalData;

  const VerificationRecord({
    required this.id,
    required this.productName,
    required this.brand,
    required this.cprNumber,
    required this.category,
    required this.status,
    required this.verificationDate,
    required this.fdaStatus,
    this.imageUrl,
    this.additionalData,
  });

  factory VerificationRecord.fromJson(Map<String, dynamic> json) {
    return VerificationRecord(
      id: json['id'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      cprNumber: json['cprNumber'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      verificationDate: DateTime.parse(json['verificationDate'] as String),
      fdaStatus: json['fdaStatus'] as String,
      imageUrl: json['imageUrl'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'brand': brand,
      'cprNumber': cprNumber,
      'category': category,
      'status': status,
      'verificationDate': verificationDate.toIso8601String(),
      'fdaStatus': fdaStatus,
      'imageUrl': imageUrl,
      'additionalData': additionalData,
    };
  }

  VerificationRecord copyWith({
    String? id,
    String? productName,
    String? brand,
    String? cprNumber,
    String? category,
    String? status,
    DateTime? verificationDate,
    String? fdaStatus,
    String? imageUrl,
    Map<String, dynamic>? additionalData,
  }) {
    return VerificationRecord(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      cprNumber: cprNumber ?? this.cprNumber,
      category: category ?? this.category,
      status: status ?? this.status,
      verificationDate: verificationDate ?? this.verificationDate,
      fdaStatus: fdaStatus ?? this.fdaStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

enum VerificationStatus {
  verified,
  notVerified,
}

extension VerificationStatusExtension on VerificationStatus {
  String get displayName {
    switch (this) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.notVerified:
        return 'Not Verified';
    }
  }

  String get fdaStatus {
    switch (this) {
      case VerificationStatus.verified:
        return 'FDA Verified';
      case VerificationStatus.notVerified:
        return 'Not FDA Verified';
    }
  }
}
