import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/generic_product.dart';
import '../services/image_verification_service.dart';
import '../config/api_config.dart';

enum ImageSearchState {
  idle,
  selectingImage,
  processing,
  completed,
  error,
}

enum ImageSearchResult {
  verified,           // Product found and verified
  notFound,           // Product not found in database (can be reported)
  imageNotClear,      // Image quality too poor to extract data
  noDataExtracted,    // No meaningful data could be extracted
  apiError,           // API/Network error
  unknown,            // Unknown result
}

class ImageSearchStateModel {
  final ImageSearchState state;
  final File? selectedImage;
  final List<GenericProduct> searchResults;
  final String errorMessage;
  final String currentProcessingMessage;
  final double processingProgress;
  final bool isProductRegistered;
  final String? detectedProductName;
  final String? detectedBrandName;
  final String? detectedProductType;
  final ImageSearchResult searchResult;
  final String? resultMessage;
  final double? confidence;

  const ImageSearchStateModel({
    this.state = ImageSearchState.idle,
    this.selectedImage,
    this.searchResults = const [],
    this.errorMessage = '',
    this.currentProcessingMessage = '',
    this.processingProgress = 0.0,
    this.isProductRegistered = false,
    this.detectedProductName,
    this.detectedBrandName,
    this.detectedProductType,
    this.searchResult = ImageSearchResult.unknown,
    this.resultMessage,
    this.confidence,
  });

  ImageSearchStateModel copyWith({
    ImageSearchState? state,
    File? selectedImage,
    List<GenericProduct>? searchResults,
    String? errorMessage,
    String? currentProcessingMessage,
    double? processingProgress,
    bool? isProductRegistered,
    String? detectedProductName,
    String? detectedBrandName,
    String? detectedProductType,
    ImageSearchResult? searchResult,
    String? resultMessage,
    double? confidence,
  }) {
    return ImageSearchStateModel(
      state: state ?? this.state,
      selectedImage: selectedImage ?? this.selectedImage,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      currentProcessingMessage: currentProcessingMessage ?? this.currentProcessingMessage,
      processingProgress: processingProgress ?? this.processingProgress,
      isProductRegistered: isProductRegistered ?? this.isProductRegistered,
      detectedProductName: detectedProductName ?? this.detectedProductName,
      detectedBrandName: detectedBrandName ?? this.detectedBrandName,
      detectedProductType: detectedProductType ?? this.detectedProductType,
      searchResult: searchResult ?? this.searchResult,
      resultMessage: resultMessage ?? this.resultMessage,
      confidence: confidence ?? this.confidence,
    );
  }

  // Helper getters
  bool get hasImage => selectedImage != null;
  bool get hasResults => searchResults.isNotEmpty;
  bool get isIdle => state == ImageSearchState.idle;
  bool get isSelectingImage => state == ImageSearchState.selectingImage;
  bool get isProcessing => state == ImageSearchState.processing;
  bool get isCompleted => state == ImageSearchState.completed;
  bool get hasError => state == ImageSearchState.error;
  
  // Result state getters
  bool get isVerified => searchResult == ImageSearchResult.verified;
  bool get isNotFound => searchResult == ImageSearchResult.notFound;
  bool get isImageNotClear => searchResult == ImageSearchResult.imageNotClear;
  bool get isNoDataExtracted => searchResult == ImageSearchResult.noDataExtracted;
  bool get isApiError => searchResult == ImageSearchResult.apiError;
  bool get isUnknownResult => searchResult == ImageSearchResult.unknown;
}

class ImageSearchNotifier extends StateNotifier<ImageSearchStateModel> {
  final ImagePicker _picker = ImagePicker();
  final ImageVerificationService _apiService = ImageVerificationService();
  
  // Processing messages
  final List<String> _processingMessages = [
    'Analyzing image quality...',
    'Detecting product features...',
    'Extracting text and product details...',
    'Searching product database...',
    'Verifying product authenticity...',
    'Generating detailed report...',
    'Finalizing results...',
  ];

  ImageSearchNotifier() : super(const ImageSearchStateModel());

  // Image selection methods
  Future<bool> pickImage(ImageSource source) async {
    try {
      state = state.copyWith(state: ImageSearchState.selectingImage);
      
      // Check if running on web
      if (kIsWeb) {
        return await _pickImageWeb(source);
      }

      // Request permissions for mobile platforms
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await _requestCameraPermission();
      } else {
        hasPermission = await _requestStoragePermission();
      }

      if (!hasPermission) {
        _setError('Permission denied. Please enable ${source == ImageSource.camera ? 'camera' : 'storage'} permission in settings.');
        return false;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        state = state.copyWith(
          selectedImage: File(image.path),
          state: ImageSearchState.idle,
        );
        return true;
      } else {
        state = state.copyWith(state: ImageSearchState.idle);
        return false;
      }
    } catch (e) {
      _setError('Error picking image: $e');
      return false;
    }
  }

  Future<bool> _pickImageWeb(ImageSource source) async {
    try {
      // For web, we can only use gallery (file picker)
      if (source == ImageSource.camera) {
        _setError('Camera is not supported on web. Please use "Upload Image" instead.');
        return false;
      }

      // Use file picker for web
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // For web, we need to handle the file differently
        await image.readAsBytes(); // Read bytes to ensure file is accessible
        state = state.copyWith(
          selectedImage: File(image.path),
          state: ImageSearchState.idle,
        );
        return true;
      } else {
        state = state.copyWith(state: ImageSearchState.idle);
        return false;
      }
    } catch (e) {
      _setError('Error picking image: $e');
      return false;
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
      if (await Permission.photos.isGranted) {
        return true;
      }
      
      final status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      }
      
      // Fallback to storage permission for older Android versions
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else {
      // For iOS, use photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  // Image processing and search
  Future<void> processImage() async {
    if (state.selectedImage == null) {
      _setError('No image selected');
      return;
    }

    // Check if API is configured
    if (!ApiConfig.isConfigured) {
      _setError('Backend API is not configured. Please check your environment settings.');
      return;
    }

    state = state.copyWith(
      state: ImageSearchState.processing,
      processingProgress: 0.0,
      currentProcessingMessage: _processingMessages[0],
    );

    try {
      // Simulate processing with progress updates
      for (int i = 0; i < _processingMessages.length - 1; i++) {
        if (state.state != ImageSearchState.processing) break; // Check if cancelled
        
        state = state.copyWith(
          currentProcessingMessage: _processingMessages[i],
          processingProgress: (i + 1) / _processingMessages.length,
        );
        
        // Wait between messages
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // Update to final processing message
      state = state.copyWith(
        currentProcessingMessage: _processingMessages.last,
        processingProgress: 0.9,
      );

      // Make actual API call
      final response = await _apiService.verifyProductImage(state.selectedImage!);
      
      if (response.success && response.data != null) {
        final verificationResponse = response.data!;
        final genericProduct = verificationResponse.toGenericProduct();
        
        // Determine result type based on API response
        ImageSearchResult resultType;
        String resultMessage;
        
        if (verificationResponse.verificationStatus == "verified") {
          resultType = ImageSearchResult.verified;
          resultMessage = 'Product verified successfully';
        } else if (verificationResponse.verificationStatus == "uncertain") {
          // If we have extracted fields and confidence > 0, treat as verified
          if (verificationResponse.extractedFields != null && 
              verificationResponse.extractedFields!.isNotEmpty &&
              verificationResponse.confidence > 0) {
            resultType = ImageSearchResult.verified;
            resultMessage = 'Product found with uncertain verification - may need manual review';
          } else {
            resultType = ImageSearchResult.notFound;
            resultMessage = 'Product verification uncertain - can be reported';
          }
        } else if (verificationResponse.confidence < 30) {
          resultType = ImageSearchResult.imageNotClear;
          resultMessage = 'Image quality is too poor to extract reliable data';
        } else if (verificationResponse.extractedFields == null || verificationResponse.extractedFields!.isEmpty) {
          resultType = ImageSearchResult.noDataExtracted;
          resultMessage = 'No meaningful product data could be extracted from the image';
        } else {
          // If we have extracted fields and confidence > 0, treat as verified
          if (verificationResponse.extractedFields != null && 
              verificationResponse.extractedFields!.isNotEmpty &&
              verificationResponse.confidence > 0) {
            resultType = ImageSearchResult.verified;
            resultMessage = 'Product found in database';
          } else {
            resultType = ImageSearchResult.notFound;
            resultMessage = 'Product not found in database - can be reported';
          }
        }

        // Create a properly verified GenericProduct with correct isVerified status
        // Use productType from genericProduct (already determined by toGenericProduct method)
        // or fall back to _determineProductType if genericProduct.productType is 'unknown'
        final determinedProductType = (genericProduct.productType == 'unknown' || genericProduct.productType.isEmpty)
            ? _determineProductType(verificationResponse)
            : genericProduct.productType;
        
        final verifiedGenericProduct = GenericProduct(
          id: genericProduct.id,
          productType: determinedProductType,
          productName: genericProduct.productName,
          brandName: genericProduct.brandName,
          manufacturer: genericProduct.manufacturer,
          registrationNumber: genericProduct.registrationNumber,
          licenseNumber: genericProduct.licenseNumber,
          documentTrackingNumber: genericProduct.documentTrackingNumber,
          description: genericProduct.description,
          warnings: genericProduct.warnings,
          confidence: genericProduct.confidence,
          isVerified: resultType == ImageSearchResult.verified, // Use our frontend logic
          issuanceDate: genericProduct.issuanceDate,
          expiryDate: genericProduct.expiryDate,
          additionalData: genericProduct.additionalData,
          nameOfEstablishment: genericProduct.nameOfEstablishment,
          owner: genericProduct.owner,
          address: genericProduct.address,
          region: genericProduct.region,
          activity: genericProduct.activity,
          companyName: genericProduct.companyName,
          typeOfProduct: genericProduct.typeOfProduct,
          genericName: genericProduct.genericName,
          dosageStrength: genericProduct.dosageStrength,
          dosageForm: genericProduct.dosageForm,
          classification: genericProduct.classification,
          pharmacologicCategory: genericProduct.pharmacologicCategory,
          applicationType: genericProduct.applicationType,
          packaging: genericProduct.packaging,
          countryOfOrigin: genericProduct.countryOfOrigin,
          applicantCompany: genericProduct.applicantCompany,
        );

        // Create alternative matches based on backend findings
        final alternativeMatches = _createAlternativeMatches(verificationResponse);

        state = state.copyWith(
          state: ImageSearchState.completed,
          processingProgress: 1.0,
          searchResults: resultType == ImageSearchResult.verified ? [verifiedGenericProduct, ...alternativeMatches] : [],
          isProductRegistered: resultType == ImageSearchResult.verified,
          detectedProductName: verificationResponse.productName,
          detectedBrandName: verificationResponse.brandName,
          detectedProductType: verificationResponse.productType,
          searchResult: resultType,
          resultMessage: resultMessage,
          confidence: verificationResponse.confidence,
        );
      } else {
        // Handle API errors
        final errorMessage = response.error ?? 'Failed to verify product image';
        ImageSearchResult resultType = ImageSearchResult.apiError;
        String resultMessage = 'API error occurred during verification';
        
        // Check if it's a server processing error
        if (errorMessage.contains('Server processing error')) {
          resultType = ImageSearchResult.apiError;
          resultMessage = 'Server is temporarily unable to process images. Please try again later or contact support.';
        } else if (errorMessage.contains('Request error')) {
          resultType = ImageSearchResult.apiError;
          resultMessage = 'Unable to process this image. Please try with a clearer image or different product.';
        } else if (errorMessage.contains('Network error') || errorMessage.contains('Connection error')) {
          resultMessage = 'Network connection failed - please check your internet connection';
        } else if (errorMessage.contains('timeout')) {
          resultMessage = 'Request timed out - please try again';
        } else if (errorMessage.contains('500')) {
          resultType = ImageSearchResult.apiError;
          resultMessage = 'Server error occurred. The backend service may be experiencing issues.';
        }
        
        state = state.copyWith(
          state: ImageSearchState.completed,
          processingProgress: 1.0,
          searchResult: resultType,
          resultMessage: resultMessage,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      // Handle different types of errors
      ImageSearchResult resultType = ImageSearchResult.apiError;
      String resultMessage = 'An unexpected error occurred';
      
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        resultType = ImageSearchResult.apiError;
        resultMessage = 'Network connection failed - please check your internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        resultType = ImageSearchResult.apiError;
        resultMessage = 'Request timed out - please try again';
      } else if (e.toString().contains('FormatException')) {
        resultType = ImageSearchResult.apiError;
        resultMessage = 'Invalid response format from server';
      }
      
      state = state.copyWith(
        state: ImageSearchState.completed,
        processingProgress: 1.0,
        searchResult: resultType,
        resultMessage: resultMessage,
        errorMessage: e.toString(),
      );
    }
  }


  // Utility methods
  void clearImage() {
    state = state.copyWith(
      selectedImage: null,
      state: ImageSearchState.idle,
    );
  }

  void setImage(File imageFile) {
    state = state.copyWith(
      selectedImage: imageFile,
      state: ImageSearchState.idle,
    );
  }

  void clearResults() {
    state = state.copyWith(
      searchResults: [],
      state: ImageSearchState.idle,
    );
  }

  void reset() {
    state = const ImageSearchStateModel();
  }

  void cancelProcessing() {
    if (state.state == ImageSearchState.processing) {
      state = state.copyWith(state: ImageSearchState.idle);
    }
  }

  // Retry processing with the same image
  Future<void> retryProcessing() async {
    if (state.selectedImage != null) {
      await processImage();
    }
  }

  // Private helper methods
  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      state: ImageSearchState.error,
    );
  }

  String _determineProductType(ProductVerificationResponse response) {
    // Try to determine product type from backend response (matched_product)
    if (response.productType != null && response.productType != 'unknown' && response.productType!.isNotEmpty) {
      return response.productType!;
    }
    
    // Fallback: analyze extracted fields to determine type
    final extractedFields = response.extractedFields;
    final matchedProduct = response.matchedProduct;
    
    // First check if matched product has type information
    if (matchedProduct != null && matchedProduct['product_type'] != null && matchedProduct['product_type'] != 'unknown') {
      return matchedProduct['product_type'];
    }
    
    if (extractedFields != null) {
      final productDescription = extractedFields['product_description']?.toString().toLowerCase() ?? '';
      final brandName = extractedFields['brand_name']?.toString().toLowerCase() ?? '';
      final registrationNumber = extractedFields['registration_number']?.toString().toUpperCase() ?? '';
      
      // Check registration number pattern (e.g., FR-XXXXXX for food)
      if (registrationNumber.startsWith('FR-')) {
        return 'food';
      } else if (registrationNumber.startsWith('DR-') || registrationNumber.startsWith('CPR-')) {
        return 'drug';
      }
      
      // Check for drug-related keywords
      if (productDescription.contains('syrup') || 
          productDescription.contains('tablet') ||
          productDescription.contains('capsule') ||
          productDescription.contains('injection') ||
          productDescription.contains('drops') ||
          productDescription.contains('mg') ||
          productDescription.contains('ml') ||
          productDescription.contains('phenylephrine') ||
          productDescription.contains('chlorphenamine') ||
          productDescription.contains('maleate') ||
          productDescription.contains('paracetamol') ||
          productDescription.contains('ibuprofen') ||
          brandName.contains('neozep') ||
          brandName.contains('forte') ||
          brandName.contains('med') ||
          brandName.contains('pharma')) {
        return 'drug';
      }
      
      // Check for food-related keywords
      if (productDescription.contains('food') ||
          productDescription.contains('snack') ||
          productDescription.contains('beverage') ||
          productDescription.contains('drink') ||
          productDescription.contains('juice') ||
          productDescription.contains('coffee') ||
          productDescription.contains('tea') ||
          productDescription.contains('candy') ||
          productDescription.contains('chocolate') ||
          productDescription.contains('biscuit') ||
          productDescription.contains('cookie')) {
        return 'food';
      }
      
      // Check for cosmetic-related keywords
      if (productDescription.contains('cosmetic') ||
          productDescription.contains('beauty') ||
          productDescription.contains('skincare') ||
          productDescription.contains('makeup') ||
          productDescription.contains('lotion') ||
          productDescription.contains('cream') ||
          productDescription.contains('shampoo')) {
        return 'cosmetic';
      }
    }
    
    // If we have a matched product but no type, it's likely a drug (most common in database)
    if (matchedProduct != null && matchedProduct.isNotEmpty) {
      return 'drug';
    }
    
    // Default to unknown if we can't determine
    return 'unknown';
  }

  List<GenericProduct> _createAlternativeMatches(ProductVerificationResponse response) {
    final alternatives = <GenericProduct>[];
    
    // If we have alternative matches from backend, use them
    if (response.alternativeMatches != null && response.alternativeMatches!.isNotEmpty) {
      for (final match in response.alternativeMatches!) {
        // Get product type from the match itself, not from the main response
        final matchProductType = match['product_type'] ?? _determineProductType(response);
        final isDrugOrApp = matchProductType == 'drug' || matchProductType == 'drug_application';
        
        final altProduct = GenericProduct(
          id: match['id'] ?? match['registration_number'] ?? 'unknown',
          productType: matchProductType,
          productName: match['product_name'] ?? match['generic_name'],
          brandName: match['brand_name'],
          manufacturer: matchProductType == 'food' ? (match['company_name'] ?? match['manufacturer']) : match['manufacturer'],
          registrationNumber: match['registration_number'],
          licenseNumber: match['license_number'],
          documentTrackingNumber: match['document_tracking_number'],
          description: match['generic_name'],
          confidence: (match['relevance_score'] ?? 0.0).toDouble(),
          isVerified: true,
          companyName: match['company_name'],
          typeOfProduct: match['type_of_product'],
          genericName: isDrugOrApp ? match['generic_name'] : null,
          dosageStrength: isDrugOrApp ? match['dosage_strength'] : null,
          dosageForm: isDrugOrApp ? match['dosage_form'] : null,
          classification: isDrugOrApp ? match['classification'] : null,
          pharmacologicCategory: isDrugOrApp ? match['pharmacologic_category'] : null,
          applicationType: match['application_type'],
          packaging: match['packaging'],
          countryOfOrigin: match['country_of_origin'],
          applicantCompany: match['applicant_company'],
        );
        alternatives.add(altProduct);
      }
    }
    
    return alternatives;
  }
}

// Provider
final imageSearchProvider = StateNotifierProvider<ImageSearchNotifier, ImageSearchStateModel>((ref) {
  return ImageSearchNotifier();
});