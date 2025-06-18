import 'package:flutter_dotenv/flutter_dotenv.dart';

class OAuthConfig {
  // Google OAuth Configuration
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // Facebook OAuth Configuration - DÉSACTIVÉ
  static String get facebookAppId => '';

  // Instagram OAuth Configuration - DÉSACTIVÉ
  static String get instagramClientId => '';
  static String get instagramClientSecret => '';

  // API Configuration
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  // Validation methods
  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;
  static bool get isFacebookConfigured => false; // Désactivé
  static bool get isInstagramConfigured => false; // Désactivé

  static bool get isOAuthConfigured => isGoogleConfigured; // Seulement Google

  // Debug method
  static void printConfig() {
    print('=== OAuth Configuration ===');
    print('Google configured: $isGoogleConfigured');
    print('Facebook configured: $isFacebookConfigured (DÉSACTIVÉ)');
    print('Instagram configured: $isInstagramConfigured (DÉSACTIVÉ)');
    print('API URL: $apiUrl');
    print('==========================');
  }
}
