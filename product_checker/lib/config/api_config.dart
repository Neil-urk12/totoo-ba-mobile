import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final url = dotenv.env['BACKEND_API_URL']!;
    // Remove trailing slash if present
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  static String get apiVersion => 'v1';
  
  // API endpoints
  static String get verifyImageEndpoint => '/api/$apiVersion/products/new-verify-image';
  
  // Full URLs
  static String get verifyImageUrl => '$baseUrl$verifyImageEndpoint';
  
  // API configuration
  static const Duration requestTimeout = Duration(seconds: 60);
  static const Duration connectTimeout = Duration(seconds: 10);
  
  // Multipart headers for file uploads
  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };
  
  static   bool get isConfigured {
    final url = dotenv.env['BACKEND_API_URL'];
    return url != null && url.isNotEmpty;
  }
}
