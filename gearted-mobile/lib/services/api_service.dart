import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:3000/api',
        connectTimeout: const Duration(milliseconds: 10000),
        receiveTimeout: const Duration(milliseconds: 10000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token aux requêtes si disponible
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Gérer les erreurs globalement
          return handler.next(error);
        },
      ),
    );
  }

  // Méthodes d'authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Sauvegarder le token
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      return response.data;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // Sauvegarder le token
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      return response.data;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Méthode générique pour les requêtes POST
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Méthodes pour les listings
  Future<Map<String, dynamic>> createListing({
    required String title,
    required String description,
    required double price,
    required List<String> imageUrls,
    required String condition,
    required String category,
    required String subcategory,
    List<String> tags = const [],
    bool isExchangeable = false,
  }) async {
    try {
      final response = await _dio.post(
        '/listings',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'imageUrls': imageUrls,
          'condition': condition,
          'category': category,
          'subcategory': subcategory,
          'tags': tags,
          'isExchangeable': isExchangeable,
        },
      );
      return response.data;
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getListings({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? subcategory,
    String? condition,
    double? minPrice,
    double? maxPrice,
    bool? isExchangeable,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (subcategory != null) queryParams['subcategory'] = subcategory;
      if (condition != null) queryParams['condition'] = condition;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (isExchangeable != null)
        queryParams['isExchangeable'] = isExchangeable;

      final response = await _dio.get(
        '/listings',
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response.data['listings'] ?? []);
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getListingById(String id) async {
    try {
      final response = await _dio.get('/listings/$id');
      return response.data['listing'];
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  // Gestion des erreurs
  void _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['message'] ?? error.message;

      if (statusCode == 401) {
        // Gérer les erreurs d'authentification
        // TODO: Rediriger vers l'écran de connexion
      }

      throw Exception(message);
    } else {
      throw Exception('Une erreur est survenue');
    }
  }
}
