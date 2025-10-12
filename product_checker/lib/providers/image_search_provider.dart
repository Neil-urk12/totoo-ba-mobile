import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/drug_product.dart';
import '../data/mock_data.dart' as mock;

enum ImageSearchState {
  idle,
  selectingImage,
  processing,
  completed,
  error,
}

class ImageSearchStateModel {
  final ImageSearchState state;
  final File? selectedImage;
  final List<DrugProduct> searchResults;
  final String errorMessage;
  final String currentProcessingMessage;
  final double processingProgress;

  const ImageSearchStateModel({
    this.state = ImageSearchState.idle,
    this.selectedImage,
    this.searchResults = const [],
    this.errorMessage = '',
    this.currentProcessingMessage = '',
    this.processingProgress = 0.0,
  });

  ImageSearchStateModel copyWith({
    ImageSearchState? state,
    File? selectedImage,
    List<DrugProduct>? searchResults,
    String? errorMessage,
    String? currentProcessingMessage,
    double? processingProgress,
  }) {
    return ImageSearchStateModel(
      state: state ?? this.state,
      selectedImage: selectedImage ?? this.selectedImage,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      currentProcessingMessage: currentProcessingMessage ?? this.currentProcessingMessage,
      processingProgress: processingProgress ?? this.processingProgress,
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
}

class ImageSearchNotifier extends StateNotifier<ImageSearchStateModel> {
  final ImagePicker _picker = ImagePicker();
  
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

    state = state.copyWith(
      state: ImageSearchState.processing,
      processingProgress: 0.0,
      currentProcessingMessage: _processingMessages[0],
    );

    try {
      // Simulate processing with progress updates
      for (int i = 0; i < _processingMessages.length; i++) {
        if (state.state != ImageSearchState.processing) break; // Check if cancelled
        
        state = state.copyWith(
          currentProcessingMessage: _processingMessages[i],
          processingProgress: (i + 1) / _processingMessages.length,
        );
        
        // Wait between messages
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Simulate API call for search results
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would be an API call
      final searchResults = mock.MockData.savedDrugProducts.take(3).toList();
      
      state = state.copyWith(
        state: ImageSearchState.completed,
        searchResults: searchResults,
      );
    } catch (e) {
      _setError('Error processing image: $e');
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

  // Private helper methods
  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      state: ImageSearchState.error,
    );
  }

  // Search result actions
  void saveProduct(DrugProduct product) {
    // In a real app, this would save to local storage or send to backend
    // For now, we'll just add it to a saved products list
    // This could be integrated with the existing saved records provider
  }

  void viewProductDetails(DrugProduct product) {
    // In a real app, this would navigate to a detailed product view
    // For now, this is a placeholder for future implementation
  }
}

// Provider
final imageSearchProvider = StateNotifierProvider<ImageSearchNotifier, ImageSearchStateModel>((ref) {
  return ImageSearchNotifier();
});