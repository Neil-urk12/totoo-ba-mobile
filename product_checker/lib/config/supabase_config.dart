import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String get redirectUrl => dotenv.env['OAUTH_REDIRECT_URL']!;
  static String get appName => dotenv.env['APP_NAME']!;
  static String get appVersion => dotenv.env['APP_VERSION']!;
  static String get enableOAuth => dotenv.env['ENABLE_OAUTH']!;
  static String get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']!;
  static String get enableCrashReporting => dotenv.env['ENABLE_CRASH_REPORTING']!;

  static bool get isConfigured {
    try {
      return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
