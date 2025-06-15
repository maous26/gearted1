import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../config/oauth_config.dart';

class InstagramAuthService {
  static const String _baseUrl = 'https://api.instagram.com';
  static const String _redirectUri =
      'https://your-app.com/auth/instagram/callback';

  // Generate a random state parameter for security
  static String _generateState() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        32, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Step 1: Get authorization URL and launch browser
  static Future<String?> initiateAuthentication() async {
    if (!OAuthConfig.isInstagramConfigured) {
      throw Exception('Instagram OAuth not properly configured');
    }

    final state = _generateState();
    final authUrl =
        Uri.parse('https://api.instagram.com/oauth/authorize').replace(
      queryParameters: {
        'client_id': OAuthConfig.instagramClientId,
        'redirect_uri': _redirectUri,
        'scope': 'user_profile,user_media',
        'response_type': 'code',
        'state': state,
      },
    );

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );
      return state;
    } else {
      throw Exception('Could not launch Instagram authentication URL');
    }
  }

  // Step 2: Exchange authorization code for access token
  static Future<Map<String, dynamic>> exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('https://api.instagram.com/oauth/access_token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': OAuthConfig.instagramClientId,
        'client_secret': OAuthConfig.instagramClientSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to exchange code for token: ${response.body}');
    }
  }

  // Step 3: Get user profile information
  static Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/users/self').replace(
        queryParameters: {
          'access_token': accessToken,
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to get user profile: ${response.body}');
    }
  }

  // Alternative: Simplified Instagram auth using WebView
  static Future<Map<String, dynamic>?> signInWithInstagramWebView(
      BuildContext context) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => InstagramWebViewDialog(),
    );
  }
}

// Instagram WebView Dialog for in-app authentication
class InstagramWebViewDialog extends StatefulWidget {
  @override
  _InstagramWebViewDialogState createState() => _InstagramWebViewDialogState();
}

class _InstagramWebViewDialogState extends State<InstagramWebViewDialog> {
  late String authUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _buildAuthUrl();
  }

  void _buildAuthUrl() {
    final state = InstagramAuthService._generateState();
    authUrl = Uri.parse('https://api.instagram.com/oauth/authorize').replace(
      queryParameters: {
        'client_id': OAuthConfig.instagramClientId,
        'redirect_uri': 'https://your-app.com/auth/instagram/callback',
        'scope': 'user_profile,user_media',
        'response_type': 'code',
        'state': state,
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Connexion Instagram'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildWebViewPlaceholder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Instagram Authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'WebView implementation would go here',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Simulate successful authentication for demo
                Navigator.of(context).pop({
                  'access_token': 'demo_instagram_token',
                  'user': {
                    'id': '123456789',
                    'username': 'demo_user',
                    'full_name': 'Demo User',
                    'profile_picture': 'https://via.placeholder.com/150',
                  },
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1306C), // Instagram color
                foregroundColor: Colors.white,
              ),
              child: const Text('Simuler la connexion Instagram'),
            ),
          ],
        ),
      ),
    );
  }
}
