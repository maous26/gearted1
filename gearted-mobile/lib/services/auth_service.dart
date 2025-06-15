import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';
import 'instagram_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final GoogleSignIn _googleSignIn;
  late final ApiService _apiService;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    // Configure Google Sign-In based on environment
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: kIsWeb ? dotenv.env['GOOGLE_WEB_CLIENT_ID'] : null,
    );
    _apiService = ApiService();
  }

  // Google Sign In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // Configuration validation would be done here if needed
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // L'utilisateur a annulé la connexion
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        throw Exception('Impossible d\'obtenir les tokens Google');
      }

      // Envoyer les données au backend
      final response = await _apiService.post('/auth/google/mobile', {
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });

      // Sauvegarder le token
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
      }

      return response;
    } catch (error) {
      await _googleSignIn.signOut(); // Nettoyage en cas d'erreur
      rethrow;
    }
  }

  // Facebook Sign In
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    // Configuration validation would be done here if needed
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        if (result.accessToken == null) {
          throw Exception('Impossible d\'obtenir le token Facebook');
        }

        // Envoyer les données au backend
        final response = await _apiService.post('/auth/facebook/mobile', {
          'accessToken': result.accessToken!.token,
          'email': userData['email'],
          'name': userData['name'],
          'picture': userData['picture']['data']['url'],
        });

        // Sauvegarder le token
        if (response['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', response['token']);
        }

        return response;
      } else if (result.status == LoginStatus.cancelled) {
        return null; // L'utilisateur a annulé la connexion
      } else {
        throw Exception('Erreur Facebook: ${result.message}');
      }
    } catch (error) {
      await FacebookAuth.instance.logOut(); // Nettoyage en cas d'erreur
      rethrow;
    }
  }

  // Instagram Sign In
  Future<Map<String, dynamic>?> signInWithInstagram(
      BuildContext context) async {
    try {
      final instagramData =
          await InstagramAuthService.signInWithInstagramWebView(context);

      if (instagramData == null) {
        return null; // L'utilisateur a annulé la connexion
      }

      // Envoyer les données au backend
      final response = await _apiService.post('/auth/instagram/mobile', {
        'accessToken': instagramData['access_token'],
        'userId': instagramData['user']['id'],
        'username': instagramData['user']['username'],
        'fullName': instagramData['user']['full_name'],
        'profilePicture': instagramData['user']['profile_picture'],
      });

      // Sauvegarder le token
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
      }

      return response;
    } catch (error) {
      rethrow;
    }
  }

  // Email/Password Sign In
  Future<Map<String, dynamic>> signInWithEmail(
      String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  // Email/Password Sign Up
  Future<Map<String, dynamic>> signUpWithEmail(
      String username, String email, String password) async {
    try {
      final response = await _apiService.register(username, email, password);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Déconnexion Google
      await _googleSignIn.signOut();

      // Déconnexion Facebook
      await FacebookAuth.instance.logOut();

      // Note: Instagram logout is typically handled by clearing local tokens
      // as Instagram doesn't provide a direct logout method in their API

      // Déconnexion de l'API
      await _apiService.logout();
    } catch (error) {
      // Continuer même si la déconnexion échoue
      print('Erreur lors de la déconnexion: $error');
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      // Vérifier la validité du token avec le backend
      final response = await _apiService.getUserProfile();
      return response['success'] == true;
    } catch (error) {
      return false;
    }
  }

  // Obtenir l'utilisateur actuel
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.getUserProfile();
      return response['user'];
    } catch (error) {
      return null;
    }
  }
}
