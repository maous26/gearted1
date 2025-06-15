import 'package:flutter_dotenv/flutter_dotenv.dart';

class OAuthConfig {
  // Google OAuth Configuration
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // Facebook OAuth Configuration
  static String get facebookAppId => dotenv.env['FACEBOOK_APP_ID'] ?? '';

  // Instagram OAuth Configuration
  static String get instagramClientId =>
      dotenv.env['INSTAGRAM_CLIENT_ID'] ?? '';
  static String get instagramClientSecret =>
      dotenv.env['INSTAGRAM_CLIENT_SECRET'] ?? '';

  // API Configuration
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  // Validation methods
  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;
  static bool get isFacebookConfigured => facebookAppId.isNotEmpty;
  static bool get isInstagramConfigured =>
      instagramClientId.isNotEmpty && instagramClientSecret.isNotEmpty;

  static bool get isOAuthConfigured =>
      isGoogleConfigured && isFacebookConfigured && isInstagramConfigured;

  // Debug method
  static void printConfig() {
    print('=== OAuth Configuration ===');
    print('Google configured: $isGoogleConfigured');
    print('Facebook configured: $isFacebookConfigured');
    print('Instagram configured: $isInstagramConfigured');
    print('API URL: $apiUrl');
    print('==========================');
  }
}
