import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling location-related operations
/// Provides location permissions, current position, and address lookup
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location position
  /// Returns null if permission denied or location unavailable
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw Exception('Location permission denied');
        }
      }

      // Get position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates using reverse geocoding
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // Format address: "Street, City, Country"
        final parts = <String>[];
        if (placemark.street?.isNotEmpty == true) parts.add(placemark.street!);
        if (placemark.locality?.isNotEmpty == true)
          parts.add(placemark.locality!);
        if (placemark.country?.isNotEmpty == true)
          parts.add(placemark.country!);

        return parts.join(', ');
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
    }
    return null;
  }

  /// Calculate distance between two positions in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// Format distance for display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Get formatted current location
  /// Returns a map with coordinates and address
  Future<Map<String, dynamic>?> getCurrentLocationData() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    final address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': address ?? 'Position inconnue',
      'timestamp': DateTime.now().toIso8601String(),
      'accuracy': position.accuracy,
    };
  }

  /// Open device settings for location permissions
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }

  /// Check if coordinates are valid
  bool isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;

    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Get location permission status as a readable string
  Future<String> getLocationPermissionStatus() async {
    final permission = await Permission.location.status;
    switch (permission) {
      case PermissionStatus.granted:
        return 'Autorisé';
      case PermissionStatus.denied:
        return 'Refusé';
      case PermissionStatus.permanentlyDenied:
        return 'Refusé définitivement';
      case PermissionStatus.restricted:
        return 'Restreint';
      case PermissionStatus.limited:
        return 'Limité';
      default:
        return 'Inconnu';
    }
  }

  /// Open location in device's map application
  Future<void> openLocationInMaps(double latitude, double longitude) async {
    try {
      // Use url_launcher to open in maps application
      final url =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      await _launchUrl(url);
    } catch (e) {
      throw Exception('Unable to open location in maps: $e');
    }
  }

  /// Open directions to location in device's map application
  Future<void> openDirections(double latitude, double longitude) async {
    try {
      // Use url_launcher to open directions in maps application
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
      await _launchUrl(url);
    } catch (e) {
      throw Exception('Unable to open directions: $e');
    }
  }

  /// Launch URL helper method
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      throw Exception('Failed to launch URL: $e');
    }
  }
}
