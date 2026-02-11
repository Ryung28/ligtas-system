import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationEnabled = false;
  LocationPermission? _permission;

  // Enhanced geocoding with Nominatim API
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static final Map<String, String> _addressCache = {};

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLocationEnabled => _isLocationEnabled;

  /// Initialize location service and check permissions
  Future<bool> initialize() async {
    try {
      // Skip location services on web platform
      if (kIsWeb) {
        debugPrint('Location service skipped on web platform');
        return false;
      }

      // Check if location services are enabled
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isLocationEnabled) {
        return false;
      }

      // Check location permission
      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) {
          return false;
        }
      }

      if (_permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('LocationService initialization error: $e');
      return false;
    }
  }

  /// Get current location with progressive fallback strategy
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Skip location services on web platform
      if (kIsWeb) {
        debugPrint('Location service not available on web platform');
        return LocationResult.error('Location services not available on web');
      }

      // Re-check location service status (in case it changed)
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isLocationEnabled) {
        debugPrint('Location services are disabled');
        return LocationResult.error('Location services are disabled. Please enable location in settings.');
      }

      // Re-check permission status (in case it changed)
      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        // Try requesting permission again
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return LocationResult.error('Location permission denied. Please grant location permission.');
        }
      }

      if (_permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return LocationResult.error('Location permission is permanently denied. Please enable it in app settings.');
      }

      // Verify permission is actually granted
      if (_permission != LocationPermission.whileInUse && 
          _permission != LocationPermission.always) {
        debugPrint('Location permission not granted: $_permission');
        return LocationResult.error('Location permission not granted');
      }

      debugPrint('Getting current position...');
      
      // Try high accuracy first
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        );
      } catch (e) {
        debugPrint('High accuracy timeout, trying low accuracy...');
        // Fallback to low accuracy (uses network when GPS unavailable)
        try {
          _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e2) {
          debugPrint('Low accuracy also failed, trying last known position...');
          // Final fallback: use last known position
          _currentPosition = await Geolocator.getLastKnownPosition();
          if (_currentPosition == null) {
            throw Exception('All location methods failed');
          }
        }
      }

      if (_currentPosition == null) {
        return LocationResult.error('Failed to get location: No position data received');
      }

      debugPrint('Position obtained: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

      // Convert coordinates to address
      await _getAddressFromCoordinates();

      if (_currentAddress == null || _currentAddress!.isEmpty) {
        _currentAddress = _formatCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      debugPrint('Location success: $_currentAddress');
      return LocationResult.success(
        position: _currentPosition!,
        address: _currentAddress ?? 'Unknown location',
      );
    } catch (e) {
      debugPrint('❌ LocationService getCurrentLocation error: $e');
      // Provide more specific error messages
      if (e.toString().contains('timeout') || e.toString().contains('time limit')) {
        return LocationResult.error(
          'Location request timed out. Please try again or check your GPS signal.',
        );
      } else if (e.toString().contains('permission')) {
        return LocationResult.error(
          'Location permission is required. Please grant location permission.',
        );
      } else {
        return LocationResult.error('Failed to get location: ${e.toString()}');
      }
    }
  }

  /// Get address from coordinates using enhanced geocoding
  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      // First try enhanced Nominatim API for better Philippines coverage
      _currentAddress = await _getAddressFromNominatim(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // If Nominatim fails, fallback to basic geocoding
      if (_currentAddress == null || _currentAddress!.contains('°')) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          _currentAddress = _formatAddress(placemark);
        }
      }

      // Final fallback to coordinates if all else fails
      if (_currentAddress == null || _currentAddress!.isEmpty) {
        _currentAddress = _formatCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      debugPrint('Address lookup error: $e');
      _currentAddress = _formatCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
  }

  /// Enhanced geocoding using Nominatim API for better Philippines coverage
  Future<String?> _getAddressFromNominatim(
      double latitude, double longitude) async {
    try {
      // Validate coordinates first
      if (!_isValidCoordinate(latitude, longitude)) {
        debugPrint('Invalid coordinates detected: $latitude, $longitude');
        return null;
      }

      // Create cache key
      final cacheKey =
          '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';

      // Check cache first
      if (_addressCache.containsKey(cacheKey)) {
        return _addressCache[cacheKey]!;
      }

      final url = Uri.parse(
          '$_nominatimBaseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=19&addressdetails=1&accept-language=en&extratags=1&namedetails=1&polygon_geojson=1');

      final response = await http.get(url, headers: {
        'User-Agent': 'MarineGuard/1.0 (User Location Service)',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Nominatim API response: $data');

        final address = _formatNominatimAddress(data);
        debugPrint('Formatted address: $address');

        // Cache the result
        _addressCache[cacheKey] = address;

        return address;
      } else {
        debugPrint(
            'Nominatim reverse geocoding failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting address from Nominatim: $e');
      return null;
    }
  }

  /// Validate GPS coordinates
  bool _isValidCoordinate(double latitude, double longitude) {
    // Check if coordinates are within reasonable bounds
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return false;
    }

    // Check for obviously wrong coordinates (like 0,0 or very small values)
    if (latitude == 0.0 && longitude == 0.0) {
      return false;
    }

    // Check for coordinates that are too close to 0 (likely invalid)
    if ((latitude.abs() < 0.001 && longitude.abs() < 0.001)) {
      return false;
    }

    // Accept coordinates from Philippines region
    if (latitude < 0.0 ||
        latitude > 30.0 ||
        longitude < 110.0 ||
        longitude > 130.0) {
      return false;
    }

    return true;
  }

  /// Format the address from Nominatim response with Philippines-specific logic
  String _formatNominatimAddress(Map<String, dynamic> data) {
    try {
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        return _formatCoordinates(
          data['lat'] as double? ?? 0.0,
          data['lon'] as double? ?? 0.0,
        );
      }

      // Try to get the most specific location name
      String locationName = '';

      // Build address from most specific to least specific
      List<String> addressParts = [];

      // Add house number first if available
      final houseNumber = address['house_number'] as String?;
      if (houseNumber != null && houseNumber.isNotEmpty) {
        addressParts.add(houseNumber);
      }

      // Add road/street if available (but filter out major highways)
      final road = address['road'] as String?;
      if (road != null && road.isNotEmpty && !_isMajorHighway(road)) {
        addressParts.add(road);
      }

      // Add neighbourhood/suburb if available
      final neighbourhood = address['neighbourhood'] as String?;
      if (neighbourhood != null && neighbourhood.isNotEmpty) {
        addressParts.add(neighbourhood);
      }

      // Add hamlet/smaller area if available (often contains Purok info)
      final hamlet = address['hamlet'] as String?;
      if (hamlet != null && hamlet.isNotEmpty) {
        addressParts.add(hamlet);
      }

      // Add suburb for additional locality info
      final suburb = address['suburb'] as String?;
      if (suburb != null && suburb.isNotEmpty && suburb != neighbourhood) {
        addressParts.add(suburb);
      }

      // Add city/town/village if available
      final city = address['city'] as String?;
      final town = address['town'] as String?;
      final village = address['village'] as String?;
      final municipality = address['municipality'] as String?;

      if (city != null && city.isNotEmpty) {
        addressParts.add(city);
      } else if (town != null && town.isNotEmpty) {
        addressParts.add(town);
      } else if (village != null && village.isNotEmpty) {
        addressParts.add(village);
      } else if (municipality != null && municipality.isNotEmpty) {
        addressParts.add(municipality);
      }

      // Add province/state if available
      final province = address['province'] as String?;
      final state = address['state'] as String?;
      if (province != null && province.isNotEmpty) {
        addressParts.add(province);
      } else if (state != null && state.isNotEmpty) {
        addressParts.add(state);
      }

      // Add country if available
      final country = address['country'] as String?;
      if (country != null && country.isNotEmpty) {
        addressParts.add(country);
      }

      // If no specific parts found, parse display name intelligently
      if (addressParts.isEmpty) {
        final displayName = data['display_name'] as String? ?? '';
        if (displayName.isNotEmpty) {
          addressParts = _parseDisplayNameIntelligently(displayName);
        }
      }

      locationName = addressParts.join(', ');

      // Return the formatted location name (no hardcoded fallbacks)
      return locationName.isNotEmpty
          ? locationName
          : _formatCoordinates(
              data['lat'] as double? ?? 0.0,
              data['lon'] as double? ?? 0.0,
            );
    } catch (e) {
      debugPrint('Error formatting Nominatim address: $e');
      return _formatCoordinates(
        data['lat'] as double? ?? 0.0,
        data['lon'] as double? ?? 0.0,
      );
    }
  }

  /// Parse display name intelligently to extract meaningful address parts
  List<String> _parseDisplayNameIntelligently(String displayName) {
    final parts = displayName.split(',').map((part) => part.trim()).toList();
    final filteredParts = <String>[];

    for (final part in parts) {
      // Skip major highways
      if (_isMajorHighway(part)) {
        debugPrint('Filtering out major highway: $part');
        continue;
      }

      // Skip generic terms and major roads
      if (part.toLowerCase().contains('philippines') ||
          part.toLowerCase().contains('mindanao') ||
          part.toLowerCase().contains('region') ||
          part.toLowerCase().contains('dipolog road') ||
          part.toLowerCase().contains('oroquieta road') ||
          part.toLowerCase().contains('national road') ||
          part.toLowerCase().contains('highway') ||
          part.toLowerCase().contains('provincial road')) {
        debugPrint('Filtering out generic/major road: $part');
        continue;
      }

      // Include meaningful parts
      if (part.isNotEmpty && part.length > 2) {
        debugPrint('Including address part: $part');
        filteredParts.add(part);
      }

      // Limit to 4 parts to avoid too much detail
      if (filteredParts.length >= 4) {
        break;
      }
    }

    return filteredParts;
  }

  /// Check if a road name is a major highway that should be filtered out
  bool _isMajorHighway(String roadName) {
    final majorHighways = [
      'Oroquieta Dipolog Road',
      'Dipolog Oroquieta Road',
      'Dipolog Road',
      'Oroquieta Road',
      'National Road',
      'Highway',
      'National Highway',
      'Provincial Road',
      'Maharlika Highway',
      'Pan-Philippine Highway',
      'AH26',
      'N1',
      'N2',
      'N3',
      'R1',
      'R2',
      'R3',
    ];

    final roadLower = roadName.toLowerCase();
    return majorHighways.any((highway) =>
        roadLower.contains(highway.toLowerCase()) ||
        roadLower.contains('national road') ||
        roadLower.contains('provincial road') ||
        roadLower.contains('highway') ||
        roadLower.contains('dipolog road') ||
        roadLower.contains('oroquieta road'));
  }

  /// Format coordinates in a user-friendly way
  String _formatCoordinates(double latitude, double longitude) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lngDirection = longitude >= 0 ? 'E' : 'W';

    return '${latitude.abs().toStringAsFixed(4)}° $latDirection, '
        '${longitude.abs().toStringAsFixed(4)}° $lngDirection';
  }

  /// Format address from placemark (fallback method)
  String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street?.isNotEmpty == true) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Unknown location';
  }

  /// Get location with fallback options
  Future<LocationResult> getLocationWithFallback() async {
    // Try high accuracy first
    var result = await getCurrentLocation();
    if (result.isSuccess) return result;

    // Fallback to medium accuracy
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
      await _getAddressFromCoordinates();

      return LocationResult.success(
        position: _currentPosition!,
        address: _currentAddress ?? 'Unknown location',
      );
    } catch (e) {
      return LocationResult.error('Unable to determine location');
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    _permission = await Geolocator.checkPermission();
    return _permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    _permission = await Geolocator.requestPermission();
    return _permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always;
  }

  /// Clear current location data
  void clearLocation() {
    _currentPosition = null;
    _currentAddress = null;
  }

  /// Clear the address cache
  static void clearAddressCache() {
    _addressCache.clear();
    debugPrint('📍 Address cache cleared');
  }
}

/// Result class for location operations
class LocationResult {
  final bool isSuccess;
  final String? error;
  final Position? position;
  final String? address;

  LocationResult.success({required this.position, required this.address})
      : isSuccess = true,
        error = null;

  LocationResult.error(this.error)
      : isSuccess = false,
        position = null,
        address = null;
}
