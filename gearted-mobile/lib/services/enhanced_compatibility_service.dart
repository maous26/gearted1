import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:archive/archive.dart';
import './compatibility_service.dart';

/// Enhanced CompatibilityService with hybrid storage approach:
/// - Hot data (frequently accessed) in PostgreSQL
/// - Cold data (infrequently accessed) in S3
/// - Caching layer with Redis for performance
/// - Local cache in SharedPreferences for offline usage
class EnhancedCompatibilityService {
  static EnhancedCompatibilityService? _instance;
  static EnhancedCompatibilityService get instance =>
      _instance ??= EnhancedCompatibilityService._();

  // Original service for fallback
  final CompatibilityService _originalService = CompatibilityService.instance;

  // API endpoints
  // In dev mode, use localhost, in prod use the actual API domain
  final String _baseUrl = const String.fromEnvironment('API_URL',
      defaultValue:
          'http://10.0.2.2:3000'); // 10.0.2.2 is localhost from Android emulator

  // Alternative base URL for the main backend (after integration)
  final bool _useIntegratedBackend =
      const bool.fromEnvironment('USE_INTEGRATED_BACKEND', defaultValue: true);

  final String _manufacturersEndpoint = '/v1/compatibility/manufacturers';
  final String _equipmentTypesEndpoint = '/v1/compatibility/equipment-types';
  final String _equipmentCategoriesEndpoint =
      '/v1/compatibility/equipment-categories';
  final String _equipmentEndpoint = '/v1/compatibility/equipment';
  final String _compatibilityRulesEndpoint = '/v1/compatibility/rules';
  final String _compatibilityEndpoint = '/v1/compatibility';
  final String _coldDataEndpoint = '/v1/compatibility/cold-data';

  // Cache TTL (Time To Live) in milliseconds
  final int _cacheTTL = 1000 * 60 * 60 * 24; // 24 hours
  final int _coldDataCacheTTL = 1000 * 60 * 60 * 24 * 7; // 7 days

  // Local cache instance
  SharedPreferences? _prefs;

  // Constructor
  EnhancedCompatibilityService._() {
    _initLocalCache();
  }

  // Initialize local cache
  Future<void> _initLocalCache() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if the device has internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Compress data to save space
  Uint8List _compressData(String jsonData) {
    final List<int> encoded = utf8.encode(jsonData);
    final List<int> compressed = GZipEncoder().encode(encoded)!;
    return Uint8List.fromList(compressed);
  }

  // Decompress data
  String _decompressData(Uint8List compressedData) {
    final List<int> decompressed = GZipDecoder().decodeBytes(compressedData);
    return utf8.decode(decompressed);
  }

  // Generic method to fetch data with caching
  Future<List<Map<String, dynamic>>> _getDataWithCache(
      String endpoint,
      String cacheKey,
      Future<List<Map<String, dynamic>>> Function() fallbackProvider,
      {bool isColdData = false}) async {
    try {
      // Check local cache first
      if (_prefs != null) {
        final cachedData = _prefs!.getString(cacheKey);
        final cacheTimestamp = _prefs!.getInt('${cacheKey}_timestamp') ?? 0;
        final ttl = isColdData ? _coldDataCacheTTL : _cacheTTL;

        // If cache is valid and not expired
        if (cachedData != null &&
            DateTime.now().millisecondsSinceEpoch - cacheTimestamp < ttl) {
          return List<Map<String, dynamic>>.from(
              jsonDecode(cachedData).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      // If we have internet, try to fetch from API
      if (await _hasInternetConnection()) {
        try {
          final response = await http.get(Uri.parse('$_baseUrl$endpoint'));

          if (response.statusCode == 200) {
            final data = List<Map<String, dynamic>>.from(
                jsonDecode(response.body)
                    .map((x) => Map<String, dynamic>.from(x)));

            // Update cache
            if (_prefs != null) {
              await _prefs!.setString(cacheKey, response.body);
              await _prefs!.setInt('${cacheKey}_timestamp',
                  DateTime.now().millisecondsSinceEpoch);
            }

            return data;
          }
        } catch (e) {
          // API request failed, fall back to local data
          print('API request failed: $e');
        }
      }

      // If we reach here, either no internet or API failed
      // Check if we have cached data, even if expired
      if (_prefs != null && _prefs!.containsKey(cacheKey)) {
        final cachedData = _prefs!.getString(cacheKey);
        if (cachedData != null) {
          return List<Map<String, dynamic>>.from(
              jsonDecode(cachedData).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      // As last resort, use fallback provider
      final fallbackData = await fallbackProvider();

      // Cache fallback data if nothing in cache yet
      if (_prefs != null && !_prefs!.containsKey(cacheKey)) {
        await _prefs!.setString(cacheKey, jsonEncode(fallbackData));
        await _prefs!.setInt(
            '${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      }

      return fallbackData;
    } catch (e) {
      print('Error fetching data: $e');
      // Absolute last resort - use fallback provider with no caching
      return await fallbackProvider();
    }
  }

  // Get cold data from S3 via API with special caching
  Future<List<Map<String, dynamic>>> _getColdData(String dataType) async {
    final cacheKey = 'cold_data_$dataType';

    try {
      // Check if we have this cold data in cache
      if (_prefs != null) {
        final compressedDataStr = _prefs!.getString(cacheKey);
        final cacheTimestamp = _prefs!.getInt('${cacheKey}_timestamp') ?? 0;

        if (compressedDataStr != null &&
            DateTime.now().millisecondsSinceEpoch - cacheTimestamp <
                _coldDataCacheTTL) {
          // Decode base64 string to Uint8List
          final compressedData = base64Decode(compressedDataStr);
          final jsonStr = _decompressData(compressedData);

          return List<Map<String, dynamic>>.from(
              jsonDecode(jsonStr).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      // Try to fetch from S3 via API
      if (await _hasInternetConnection()) {
        try {
          final response = await http
              .get(Uri.parse('$_baseUrl$_coldDataEndpoint/archives/$dataType'));

          if (response.statusCode == 200) {
            // Compress the data before storing
            final compressedData = _compressData(response.body);
            final base64Str = base64Encode(compressedData);

            // Store compressed data in cache
            if (_prefs != null) {
              await _prefs!.setString(cacheKey, base64Str);
              await _prefs!.setInt('${cacheKey}_timestamp',
                  DateTime.now().millisecondsSinceEpoch);
            }

            return List<Map<String, dynamic>>.from(jsonDecode(response.body)
                .map((x) => Map<String, dynamic>.from(x)));
          }
        } catch (e) {
          print('Error fetching cold data: $e');
        }
      }

      // If we reach here, either check if we have any cached data regardless of age
      if (_prefs != null && _prefs!.containsKey(cacheKey)) {
        try {
          final compressedDataStr = _prefs!.getString(cacheKey);
          if (compressedDataStr != null) {
            final compressedData = base64Decode(compressedDataStr);
            final jsonStr = _decompressData(compressedData);

            return List<Map<String, dynamic>>.from(
                jsonDecode(jsonStr).map((x) => Map<String, dynamic>.from(x)));
          }
        } catch (e) {
          print('Error reading cached cold data: $e');
        }
      }

      // Fallback to empty list for cold data
      return [];
    } catch (e) {
      print('Error in cold data retrieval: $e');
      return [];
    }
  }

  // Get top 10 equipment manufacturers
  Future<List<Map<String, dynamic>>> getManufacturers() async {
    return _getDataWithCache(_manufacturersEndpoint, 'manufacturers_cache',
        () => _originalService.getManufacturers());
  }

  // Get list of equipment types
  Future<List<Map<String, dynamic>>> getEquipmentTypes() async {
    return _getDataWithCache(_equipmentTypesEndpoint, 'equipment_types_cache',
        () => _originalService.getEquipmentTypes());
  }

  // Get list of equipment categories
  Future<List<Map<String, dynamic>>> getEquipmentCategories() async {
    return _getDataWithCache(
        _equipmentCategoriesEndpoint,
        'equipment_categories_cache',
        () => _originalService.getEquipmentCategories());
  }

  // Get list of equipment
  Future<List<Map<String, dynamic>>> getEquipment() async {
    return _getDataWithCache(_equipmentEndpoint, 'equipment_cache',
        () => _originalService.getEquipment());
  }

  // Get compatibility rules between equipment
  Future<List<Map<String, dynamic>>> getCompatibilityRules() async {
    return _getDataWithCache(
        _compatibilityRulesEndpoint,
        'compatibility_rules_cache',
        () => _originalService.getCompatibilityRules());
  }

  // Get historical compatibility data (cold data from S3)
  Future<List<Map<String, dynamic>>> getHistoricalCompatibilityData() async {
    return _getColdData('historical_compatibility');
  }

  // Check compatibility between two specific equipment
  Future<Map<String, dynamic>?> checkCompatibility(
      String sourceId, String targetId) async {
    try {
      // Check analytics for this pair (helps prioritize hot data)
      _trackCompatibilityCheck(sourceId, targetId);

      // Check local cache first
      final cacheKey = 'compatibility_${sourceId}_${targetId}';

      if (_prefs != null) {
        final cachedData = _prefs!.getString(cacheKey);
        final cacheTimestamp = _prefs!.getInt('${cacheKey}_timestamp') ?? 0;

        if (cachedData != null &&
            DateTime.now().millisecondsSinceEpoch - cacheTimestamp <
                _cacheTTL) {
          return Map<String, dynamic>.from(jsonDecode(cachedData));
        }
      }

      // Try API if we have internet
      if (await _hasInternetConnection()) {
        try {
          // Use the new compatibility endpoint format
          final response = await http.get(Uri.parse(
              '$_baseUrl$_compatibilityEndpoint/$sourceId/$targetId'));

          if (response.statusCode == 200) {
            final data = Map<String, dynamic>.from(jsonDecode(response.body));

            // Update cache
            if (_prefs != null) {
              await _prefs!.setString(cacheKey, response.body);
              await _prefs!.setInt('${cacheKey}_timestamp',
                  DateTime.now().millisecondsSinceEpoch);
            }

            return data;
          }
        } catch (e) {
          print('API compatibility check failed: $e');
        }
      }

      // Fallback to original service implementation
      return await _originalService.checkCompatibility(sourceId, targetId);
    } catch (e) {
      print('Error checking compatibility: $e');
      return _originalService.checkCompatibility(sourceId, targetId);
    }
  }

  // Find all compatible equipment for a specific equipment ID
  Future<List<Map<String, dynamic>>> findCompatibleEquipment(
      String equipmentId) async {
    try {
      final cacheKey = 'compatible_equipment_$equipmentId';

      // Check local cache
      if (_prefs != null) {
        final cachedData = _prefs!.getString(cacheKey);
        final cacheTimestamp = _prefs!.getInt('${cacheKey}_timestamp') ?? 0;

        if (cachedData != null &&
            DateTime.now().millisecondsSinceEpoch - cacheTimestamp <
                _cacheTTL) {
          return List<Map<String, dynamic>>.from(
              jsonDecode(cachedData).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      // Try API if we have internet
      if (await _hasInternetConnection()) {
        try {
          // Use the new compatibility equipment endpoint format
          final response = await http.get(Uri.parse(
              '$_baseUrl$_compatibilityEndpoint/equipment/$equipmentId'));

          if (response.statusCode == 200) {
            // The API now returns a paginated result with items inside compatibleItems
            final responseData = jsonDecode(response.body);
            final data = List<Map<String, dynamic>>.from(
                responseData['compatibleItems']
                    .map((x) => Map<String, dynamic>.from(x)));

            // Update cache
            if (_prefs != null) {
              await _prefs!.setString(cacheKey, jsonEncode(data));
              await _prefs!.setInt('${cacheKey}_timestamp',
                  DateTime.now().millisecondsSinceEpoch);
            }

            return data;
          }
        } catch (e) {
          print('API request failed: $e');
        }
      }

      // Fallback to original service
      return _originalService.findCompatibleEquipment(equipmentId);
    } catch (e) {
      print('Error finding compatible equipment: $e');
      return _originalService.findCompatibleEquipment(equipmentId);
    }
  }

  // Search equipment by name, manufacturer, or category
  Future<List<Map<String, dynamic>>> searchEquipment(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // Don't cache search results, always try API first if available
      if (await _hasInternetConnection()) {
        try {
          final response = await http.get(Uri.parse(
              '$_baseUrl$_equipmentEndpoint/search?q=${Uri.encodeComponent(query)}'));

          if (response.statusCode == 200) {
            return List<Map<String, dynamic>>.from(jsonDecode(response.body)
                .map((x) => Map<String, dynamic>.from(x)));
          }
        } catch (e) {
          print('API search request failed: $e');
        }
      }

      // Fallback to original service
      return _originalService.searchEquipment(query);
    } catch (e) {
      print('Error searching equipment: $e');
      return _originalService.searchEquipment(query);
    }
  }

  // Get suggested compatible equipment based on history and trending matches
  Future<List<Map<String, dynamic>>> getSuggestedCompatibleEquipment() async {
    try {
      final cacheKey = 'suggested_compatibility';

      // Check local cache
      if (_prefs != null) {
        final cachedData = _prefs!.getString(cacheKey);
        final cacheTimestamp = _prefs!.getInt('${cacheKey}_timestamp') ?? 0;

        if (cachedData != null &&
            DateTime.now().millisecondsSinceEpoch - cacheTimestamp <
                _cacheTTL) {
          return List<Map<String, dynamic>>.from(
              jsonDecode(cachedData).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      // Try API if we have internet
      if (await _hasInternetConnection()) {
        try {
          final response =
              await http.get(Uri.parse('$_baseUrl/compatibility/suggested'));

          if (response.statusCode == 200) {
            final data = List<Map<String, dynamic>>.from(
                jsonDecode(response.body)
                    .map((x) => Map<String, dynamic>.from(x)));

            // Update cache
            if (_prefs != null) {
              await _prefs!.setString(cacheKey, jsonEncode(data));
              await _prefs!.setInt('${cacheKey}_timestamp',
                  DateTime.now().millisecondsSinceEpoch);
            }

            return data;
          }
        } catch (e) {
          print('API request failed: $e');
        }
      }

      // Fallback to original service
      return _originalService.getSuggestedCompatibleEquipment();
    } catch (e) {
      print('Error getting suggested compatible equipment: $e');
      return _originalService.getSuggestedCompatibleEquipment();
    }
  }

  // Track compatibility checks for analytics
  Future<void> _trackCompatibilityCheck(
      String sourceId, String targetId) async {
    try {
      // Update local analytics first
      final analyticsKey = 'compatibility_analytics';
      Map<String, dynamic> analytics = {};

      if (_prefs != null && _prefs!.containsKey(analyticsKey)) {
        final analyticsJson = _prefs!.getString(analyticsKey);
        if (analyticsJson != null) {
          analytics = Map<String, dynamic>.from(jsonDecode(analyticsJson));
        }
      }

      final pairKey = '$sourceId-$targetId';
      final count = analytics[pairKey] ?? 0;
      analytics[pairKey] = count + 1;

      // Save back to local storage
      if (_prefs != null) {
        await _prefs!.setString(analyticsKey, jsonEncode(analytics));
      }

      // If we have internet, send to server
      if (await _hasInternetConnection()) {
        try {
          await http.post(Uri.parse('$_baseUrl/analytics/compatibility-check'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'sourceId': sourceId,
                'targetId': targetId,
                'timestamp': DateTime.now().millisecondsSinceEpoch
              }));
        } catch (e) {
          // Silent fail for analytics
          print('Failed to send analytics: $e');
        }
      }
    } catch (e) {
      // Don't let analytics errors affect main functionality
      print('Error tracking analytics: $e');
    }
  }

  // Add compatibility rule (with server sync when online)
  Future<bool> addCompatibilityRule(Map<String, dynamic> rule) async {
    try {
      // If online, send to server first
      if (await _hasInternetConnection()) {
        try {
          final response = await http.post(
              Uri.parse('$_baseUrl$_compatibilityEndpoint/rules'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(rule));

          if (response.statusCode == 201 || response.statusCode == 200) {
            // Clear cache to ensure fresh data on next fetch
            if (_prefs != null) {
              await _prefs!.remove('compatibility_rules_cache');
            }
            return true;
          }
        } catch (e) {
          print('Failed to add rule to server: $e');
          // Fall through to local cache update
        }
      }

      // Update local cache with new rule
      final rules = await getCompatibilityRules();
      rules.add(rule);

      if (_prefs != null) {
        await _prefs!.setString('compatibility_rules_cache', jsonEncode(rules));
        await _prefs!.setInt('compatibility_rules_cache_timestamp',
            DateTime.now().millisecondsSinceEpoch);

        // Also queue this change for later sync
        await _queueOfflineChange('add_rule', rule);
      }

      return true;
    } catch (e) {
      print('Error adding compatibility rule: $e');
      return false;
    }
  }

  // Update compatibility rule
  Future<bool> updateCompatibilityRule(
      String ruleId, Map<String, dynamic> updatedRule) async {
    try {
      // If online, send to server first
      if (await _hasInternetConnection()) {
        try {
          final response = await http.put(
              Uri.parse('$_baseUrl$_compatibilityEndpoint/rules/$ruleId'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updatedRule));

          if (response.statusCode == 200) {
            // Clear cache to ensure fresh data on next fetch
            if (_prefs != null) {
              await _prefs!.remove('compatibility_rules_cache');
            }
            return true;
          }
        } catch (e) {
          print('Failed to update rule on server: $e');
          // Fall through to local cache update
        }
      }

      // Update local cache
      final rules = await getCompatibilityRules();
      final index = rules.indexWhere((r) => r['id'] == ruleId);

      if (index >= 0) {
        rules[index] = updatedRule;

        if (_prefs != null) {
          await _prefs!
              .setString('compatibility_rules_cache', jsonEncode(rules));
          await _prefs!.setInt('compatibility_rules_cache_timestamp',
              DateTime.now().millisecondsSinceEpoch);

          // Queue for later sync
          await _queueOfflineChange(
              'update_rule', {'id': ruleId, 'data': updatedRule});
        }

        return true;
      }

      return false;
    } catch (e) {
      print('Error updating compatibility rule: $e');
      return false;
    }
  }

  // Delete compatibility rule
  Future<bool> deleteCompatibilityRule(String ruleId) async {
    try {
      // If online, send to server first
      if (await _hasInternetConnection()) {
        try {
          final response = await http.delete(
              Uri.parse('$_baseUrl$_compatibilityEndpoint/rules/$ruleId'));

          if (response.statusCode == 200 || response.statusCode == 204) {
            // Clear cache to ensure fresh data on next fetch
            if (_prefs != null) {
              await _prefs!.remove('compatibility_rules_cache');
            }
            return true;
          }
        } catch (e) {
          print('Failed to delete rule from server: $e');
          // Fall through to local cache update
        }
      }

      // Update local cache
      final rules = await getCompatibilityRules();
      final filteredRules = rules.where((r) => r['id'] != ruleId).toList();

      if (_prefs != null) {
        await _prefs!
            .setString('compatibility_rules_cache', jsonEncode(filteredRules));
        await _prefs!.setInt('compatibility_rules_cache_timestamp',
            DateTime.now().millisecondsSinceEpoch);

        // Queue for later sync
        await _queueOfflineChange('delete_rule', {'id': ruleId});
      }

      return true;
    } catch (e) {
      print('Error deleting compatibility rule: $e');
      return false;
    }
  }

  // Queue offline changes for later sync
  Future<void> _queueOfflineChange(
      String action, Map<String, dynamic> data) async {
    try {
      final queueKey = 'offline_changes_queue';
      List<Map<String, dynamic>> queue = [];

      if (_prefs != null && _prefs!.containsKey(queueKey)) {
        final queueJson = _prefs!.getString(queueKey);
        if (queueJson != null) {
          queue = List<Map<String, dynamic>>.from(
              jsonDecode(queueJson).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      queue.add({
        'action': action,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });

      if (_prefs != null) {
        await _prefs!.setString(queueKey, jsonEncode(queue));
      }
    } catch (e) {
      print('Error queueing offline change: $e');
    }
  }

  // Sync offline changes when back online
  Future<bool> syncOfflineChanges() async {
    if (!(await _hasInternetConnection())) {
      return false;
    }

    try {
      final queueKey = 'offline_changes_queue';
      List<Map<String, dynamic>> queue = [];

      if (_prefs != null && _prefs!.containsKey(queueKey)) {
        final queueJson = _prefs!.getString(queueKey);
        if (queueJson != null) {
          queue = List<Map<String, dynamic>>.from(
              jsonDecode(queueJson).map((x) => Map<String, dynamic>.from(x)));
        }
      }

      if (queue.isEmpty) {
        return true;
      }

      List<Map<String, dynamic>> failedChanges = [];

      for (var change in queue) {
        final action = change['action'];
        final data = change['data'];
        bool success = false;

        switch (action) {
          case 'add_rule':
            try {
              final response = await http.post(
                  Uri.parse('$_baseUrl$_compatibilityRulesEndpoint'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(data));
              success =
                  response.statusCode == 201 || response.statusCode == 200;
            } catch (e) {
              print('Failed to sync add_rule: $e');
            }
            break;

          case 'update_rule':
            try {
              final response = await http.put(
                  Uri.parse(
                      '$_baseUrl$_compatibilityEndpoint/rules/${data['id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(data['data']));
              success = response.statusCode == 200;
            } catch (e) {
              print('Failed to sync update_rule: $e');
            }
            break;

          case 'delete_rule':
            try {
              final response = await http.delete(Uri.parse(
                  '$_baseUrl$_compatibilityEndpoint/rules/${data['id']}'));
              success =
                  response.statusCode == 200 || response.statusCode == 204;
            } catch (e) {
              print('Failed to sync delete_rule: $e');
            }
            break;
        }

        if (!success) {
          failedChanges.add(change);
        }
      }

      // Update the queue with only failed changes
      if (_prefs != null) {
        if (failedChanges.isEmpty) {
          await _prefs!.remove(queueKey);

          // Clear all cache to ensure fresh data after sync
          await clearCache();
        } else {
          await _prefs!.setString(queueKey, jsonEncode(failedChanges));
        }
      }

      return failedChanges.isEmpty;
    } catch (e) {
      print('Error syncing offline changes: $e');
      return false;
    }
  }

  // Clear cached data
  Future<void> clearCache() async {
    if (_prefs != null) {
      // Keep offline changes queue
      final queueKey = 'offline_changes_queue';
      final offlineChanges = _prefs!.getString(queueKey);

      // Keep analytics data
      final analyticsKey = 'compatibility_analytics';
      final analyticsData = _prefs!.getString(analyticsKey);

      // Clear everything else
      await _prefs!.clear();

      // Restore offline changes and analytics
      if (offlineChanges != null) {
        await _prefs!.setString(queueKey, offlineChanges);
      }

      if (analyticsData != null) {
        await _prefs!.setString(analyticsKey, analyticsData);
      }
    }
  }

  // Export compatibility analytics
  Future<Map<String, dynamic>> exportAnalytics() async {
    try {
      final analyticsKey = 'compatibility_analytics';
      Map<String, dynamic> analytics = {};

      if (_prefs != null && _prefs!.containsKey(analyticsKey)) {
        final analyticsJson = _prefs!.getString(analyticsKey);
        if (analyticsJson != null) {
          analytics = Map<String, dynamic>.from(jsonDecode(analyticsJson));
        }
      }

      final topPairs = _getTopCompatibilityPairs(analytics);
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'totalChecks':
            analytics.values.fold(0, (sum, count) => sum + (count as int)),
        'topPairs': topPairs
      };
    } catch (e) {
      print('Error exporting analytics: $e');
      return {};
    }
  }

  // Get top compatibility pairs from analytics
  List<Map<String, dynamic>> _getTopCompatibilityPairs(
      Map<String, dynamic> analytics) {
    final sortedEntries = analytics.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    final topEntries = sortedEntries.take(10).toList();

    return topEntries.map((entry) {
      final ids = entry.key.split('-');
      return {'sourceId': ids[0], 'targetId': ids[1], 'count': entry.value};
    }).toList();
  }

  // Delegate to original service's static methods for UI helpers
  static Color getCompatibilityColor(String compatibilityType) {
    return CompatibilityService.getCompatibilityColor(compatibilityType);
  }

  static IconData getCompatibilityIcon(String compatibilityType) {
    return CompatibilityService.getCompatibilityIcon(compatibilityType);
  }

  static String getCompatibilityText(String compatibilityType) {
    return CompatibilityService.getCompatibilityText(compatibilityType);
  }
}
