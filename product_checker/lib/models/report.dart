class Report {
  final String id;
  final String productName;
  final String? brandName;
  final String? registrationNumber;
  final String description;
  final String? reporterName; // null if anonymous
  final DateTime reportDate;
  final String? location; // where the product was found
  final String? storeName; // store where product was found

  const Report({
    required this.id,
    required this.productName,
    this.brandName,
    this.registrationNumber,
    required this.description,
    this.reporterName,
    required this.reportDate,
    this.location,
    this.storeName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      productName: json['product_name'] as String,
      brandName: json['brand_name'] as String?,
      registrationNumber: json['registration_number'] as String?,
      description: json['description'] as String,
      reporterName: json['reporter_name'] as String?,
      reportDate: DateTime.parse(json['report_date'] as String),
      location: json['location'] as String?,
      storeName: json['store_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'brand_name': brandName,
      'registration_number': registrationNumber,
      'description': description,
      'reporter_name': reporterName,
      'report_date': reportDate.toIso8601String(),
      'location': location,
      'store_name': storeName,
    };
  }

  Report copyWith({
    String? id,
    String? productName,
    String? brandName,
    String? registrationNumber,
    String? description,
    String? reporterName,
    DateTime? reportDate,
    String? location,
    String? storeName,
  }) {
    return Report(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brandName: brandName ?? this.brandName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      description: description ?? this.description,
      reporterName: reporterName ?? this.reporterName,
      reportDate: reportDate ?? this.reportDate,
      location: location ?? this.location,
      storeName: storeName ?? this.storeName,
    );
  }

  // Helper getter for display name
  String get displayName {
    if (brandName != null) {
      return '$productName ($brandName)';
    }
    return productName;
  }

  // Helper getter for reporter display
  String get reporterDisplay {
    if (reporterName != null) {
      return reporterName!;
    }
    return 'Anonymous';
  }

  // Helper getter for time since report
  String get timeSinceReport {
    final now = DateTime.now();
    final difference = now.difference(reportDate);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

