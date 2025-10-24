import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/generic_product.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

class ProductVerificationResponse {
  final String verificationStatus; // "verified", "uncertain", "not_found"
  final double confidence;
  final Map<String, dynamic>? matchedProduct;
  final Map<String, dynamic>? extractedFields;
  final String? aiReasoning;
  final List<Map<String, dynamic>>? alternativeMatches;
  
  // Computed properties for backward compatibility
  bool get isVerified => verificationStatus == "verified";
  String? get productType => matchedProduct?['product_type'];
  String? get productName => matchedProduct?['product_name'] ?? extractedFields?['product_description'];
  String? get brandName => matchedProduct?['brand_name'] ?? extractedFields?['brand_name'];
  String? get manufacturer => matchedProduct?['manufacturer'] ?? extractedFields?['manufacturer'];
  String? get registrationNumber => matchedProduct?['registration_number'] ?? extractedFields?['registration_number'];
  String? get licenseNumber => matchedProduct?['license_number'];
  String? get documentTrackingNumber => matchedProduct?['document_tracking_number'];
  String? get description => extractedFields?['product_description'];
  List<String>? get warnings => null; // Not provided by backend
  Map<String, dynamic>? get additionalData => extractedFields;
  DateTime? get issuanceDate => matchedProduct?['issuance_date'] != null ? DateTime.tryParse(matchedProduct!['issuance_date']) : null;
  DateTime? get expiryDate => matchedProduct?['expiry_date'] != null ? DateTime.tryParse(matchedProduct!['expiry_date']) : null;
  
  // Industry-specific fields (from matched product)
  String? get nameOfEstablishment => matchedProduct?['name_of_establishment'];
  String? get owner => matchedProduct?['owner'];
  String? get address => matchedProduct?['address'];
  String? get region => matchedProduct?['region'];
  String? get activity => matchedProduct?['activity'];
  String? get companyName => matchedProduct?['company_name'];
  String? get typeOfProduct => matchedProduct?['type_of_product'];
  
  // Drug-specific fields (from matched product)
  String? get genericName => matchedProduct?['generic_name'];
  String? get dosageStrength => matchedProduct?['dosage_strength'];
  String? get dosageForm => matchedProduct?['dosage_form'];
  String? get classification => matchedProduct?['classification'];
  String? get pharmacologicCategory => matchedProduct?['pharmacologic_category'];
  String? get applicationType => matchedProduct?['application_type'];
  String? get packaging => matchedProduct?['packaging'];
  String? get countryOfOrigin => matchedProduct?['country_of_origin'];
  
  // Applicant-specific fields (from matched product)
  String? get applicantCompany => matchedProduct?['applicant_company'];

  ProductVerificationResponse({
    required this.verificationStatus,
    required this.confidence,
    this.matchedProduct,
    this.extractedFields,
    this.aiReasoning,
    this.alternativeMatches,
  });

  factory ProductVerificationResponse.fromJson(Map<String, dynamic> json) {
    final rawConfidence = json['confidence'] ?? 0.0;
    
    return ProductVerificationResponse(
      verificationStatus: json['verification_status'] ?? 'not_found',
      confidence: rawConfidence.toDouble(),
      matchedProduct: json['matched_product'],
      extractedFields: json['extracted_fields'],
      aiReasoning: json['ai_reasoning'],
      alternativeMatches: json['alternative_matches'] != null 
          ? List<Map<String, dynamic>>.from(json['alternative_matches'])
          : null,
    );
  }

  // Convert to GenericProduct for unified handling
  GenericProduct toGenericProduct() {
    return GenericProduct(
      id: registrationNumber ?? licenseNumber ?? documentTrackingNumber ?? 'unknown',
      productType: productType ?? 'unknown',
      productName: productName,
      brandName: brandName,
      manufacturer: manufacturer,
      registrationNumber: registrationNumber,
      licenseNumber: licenseNumber,
      documentTrackingNumber: documentTrackingNumber,
      description: description,
      warnings: warnings,
      confidence: confidence,
      isVerified: isVerified,
      issuanceDate: issuanceDate,
      expiryDate: expiryDate,
      additionalData: additionalData,
      nameOfEstablishment: nameOfEstablishment,
      owner: owner,
      address: address,
      region: region,
      activity: activity,
      companyName: companyName,
      typeOfProduct: typeOfProduct,
      genericName: genericName,
      dosageStrength: dosageStrength,
      dosageForm: dosageForm,
      classification: classification,
      pharmacologicCategory: pharmacologicCategory,
      applicationType: applicationType,
      packaging: packaging,
      countryOfOrigin: countryOfOrigin,
      applicantCompany: applicantCompany,
    );
  }
}

class ImageVerificationService {
  static final ImageVerificationService _instance = ImageVerificationService._internal();
  factory ImageVerificationService() => _instance;
  ImageVerificationService._internal();

  final http.Client _client = http.Client();



  // Image verification endpoint
  Future<ApiResponse<ProductVerificationResponse>> verifyProductImage(File imageFile) async {
    return await _verifyProductImageMain(imageFile);
  }

  // Main verification method
  Future<ApiResponse<ProductVerificationResponse>> _verifyProductImageMain(File imageFile) async {
    try {
      
      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        return ApiResponse.error('Image file does not exist');
      }
      
      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        return ApiResponse.error('Image file is too large (max 5MB)');
      }
      
      // Check if file is empty
      if (fileSize == 0) {
        return ApiResponse.error('Image file is empty');
      }
      

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.verifyImageUrl),
      );

      // Add headers
      request.headers.addAll(ApiConfig.multipartHeaders);
      // Add additional headers that might help with PNG processing
      request.headers['User-Agent'] = 'Flutter-ProductChecker/1.0';
      request.headers['Cache-Control'] = 'no-cache';

      // Add image file
      final imageBytes = await imageFile.readAsBytes();
      
      // Detect image format from file content, not just extension
      final fileExtension = imageFile.path.toLowerCase().split('.').last;
      
      // Detect actual file format from content
      String actualFormat;
      String contentType;
      String filename;
      
      if (imageBytes.length >= 4) {
        final firstBytes = imageBytes.take(4).toList();
        
        // Check for JPEG signature (0xFF 0xD8 0xFF)
        if (firstBytes[0] == 0xFF && firstBytes[1] == 0xD8 && firstBytes[2] == 0xFF) {
          actualFormat = 'jpeg';
          contentType = 'image/jpeg';
          filename = 'product_image.jpg';
        }
        // Check for PNG signature (0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A)
        else if (imageBytes.length >= 8 &&
                 firstBytes[0] == 0x89 && firstBytes[1] == 0x50 && firstBytes[2] == 0x4E && firstBytes[3] == 0x47 &&
                 imageBytes[4] == 0x0D && imageBytes[5] == 0x0A && imageBytes[6] == 0x1A && imageBytes[7] == 0x0A) {
          actualFormat = 'png';
          contentType = 'image/png';
          filename = 'product_image.png';
        }
        // Check for WebP signature (RIFF...WEBP)
        else if (imageBytes.length >= 12 && 
                 firstBytes[0] == 0x52 && firstBytes[1] == 0x49 && firstBytes[2] == 0x46 && firstBytes[3] == 0x46 &&
                 imageBytes[8] == 0x57 && imageBytes[9] == 0x45 && imageBytes[10] == 0x42 && imageBytes[11] == 0x50) {
          actualFormat = 'webp';
          contentType = 'image/webp';
          filename = 'product_image.webp';
        }
        else {
          // Fallback to extension-based detection
          actualFormat = fileExtension;
          switch (fileExtension) {
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              filename = 'product_image.jpg';
              break;
            case 'png':
              contentType = 'image/png';
              filename = 'product_image.png';
              break;
            case 'webp':
              contentType = 'image/webp';
              filename = 'product_image.webp';
              break;
            default:
              return ApiResponse.error('Unsupported image format: $fileExtension. Please use JPG, PNG, or WebP format.');
          }
        }
      } else {
        return ApiResponse.error('Invalid image file: file too small');
      }
      
      // Validate that we have a supported format
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(actualFormat)) {
        return ApiResponse.error('Unsupported image format: $actualFormat. Please use JPG, PNG, or WebP format.');
      }
      
      
      // Use consistent approach for both JPG and WebP - fromBytes for better control
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      );
      request.files.add(multipartFile);
      
      
      
      // Send request
      
      final streamedResponse = await request.send().timeout(ApiConfig.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final verificationResponse = ProductVerificationResponse.fromJson(data);
        return ApiResponse.success(verificationResponse, statusCode: response.statusCode);
      } else {
        String errorMessage = 'Image verification failed';
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Image verification failed with status: ${response.statusCode}';
        }
        
        
        // Handle different HTTP status codes appropriately
        if (response.statusCode >= 500) {
          // Server error - backend processing failed
          return ApiResponse.error('Server processing error: $errorMessage', statusCode: response.statusCode);
        } else if (response.statusCode >= 400) {
          // Client error - bad request
          return ApiResponse.error('Request error: $errorMessage', statusCode: response.statusCode);
        } else {
          // Other errors
          return ApiResponse.error(errorMessage, statusCode: response.statusCode);
        }
      }
    } catch (e) {
      
      if (e is SocketException) {
        return ApiResponse.error('Network error: Unable to connect to server - ${e.message}');
      } else if (e is http.ClientException) {
        return ApiResponse.error('Connection error: ${e.message}');
      } else if (e is FormatException) {
        return ApiResponse.error('Invalid response format from server');
      } else if (e is TimeoutException) {
        return ApiResponse.error('Request timed out - please try again');
      } else {
        return ApiResponse.error('Image verification failed: $e');
      }
    }
  }


  // Dispose client when done
  void dispose() {
    _client.close();
  }
}
