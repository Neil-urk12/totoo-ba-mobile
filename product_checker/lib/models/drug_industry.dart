class DrugIndustry {
  final String licenseNumber;
  final String nameOfEstablishment;
  final String owner;
  final String address;
  final String region;
  final String activity;
  final DateTime issuanceDate;
  final DateTime expiryDate;

  const DrugIndustry({
    required this.licenseNumber,
    required this.nameOfEstablishment,
    required this.owner,
    required this.address,
    required this.region,
    required this.activity,
    required this.issuanceDate,
    required this.expiryDate,
  });

  factory DrugIndustry.fromJson(Map<String, dynamic> json) {
    return DrugIndustry(
      licenseNumber: json['license_number'] as String,
      nameOfEstablishment: json['name_of_establishment'] as String,
      owner: json['owner'] as String,
      address: json['address'] as String,
      region: json['region'] as String,
      activity: json['activity'] as String,
      issuanceDate: DateTime.parse(json['issuance_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_number': licenseNumber,
      'name_of_establishment': nameOfEstablishment,
      'owner': owner,
      'address': address,
      'region': region,
      'activity': activity,
      'issuance_date': issuanceDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
    };
  }

  DrugIndustry copyWith({
    String? licenseNumber,
    String? nameOfEstablishment,
    String? owner,
    String? address,
    String? region,
    String? activity,
    DateTime? issuanceDate,
    DateTime? expiryDate,
  }) {
    return DrugIndustry(
      licenseNumber: licenseNumber ?? this.licenseNumber,
      nameOfEstablishment: nameOfEstablishment ?? this.nameOfEstablishment,
      owner: owner ?? this.owner,
      address: address ?? this.address,
      region: region ?? this.region,
      activity: activity ?? this.activity,
      issuanceDate: issuanceDate ?? this.issuanceDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  // Helper getter for display name
  String get displayName => nameOfEstablishment;

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

  // Helper getter for short address (first part before comma)
  String get shortAddress {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.first.trim() : address;
  }

  // Helper getter for full address with region
  String get fullAddress => '$address, $region';

  // Helper getter for license display
  String get licenseDisplay => 'License: $licenseNumber';
}

enum DrugIndustryStatus {
  active,
  expiringSoon,
  expired,
}

extension DrugIndustryStatusExtension on DrugIndustryStatus {
  String get displayName {
    switch (this) {
      case DrugIndustryStatus.active:
        return 'Active';
      case DrugIndustryStatus.expiringSoon:
        return 'Expiring Soon';
      case DrugIndustryStatus.expired:
        return 'Expired';
    }
  }

  String get colorCode {
    switch (this) {
      case DrugIndustryStatus.active:
        return 'green';
      case DrugIndustryStatus.expiringSoon:
        return 'orange';
      case DrugIndustryStatus.expired:
        return 'red';
    }
  }
}
