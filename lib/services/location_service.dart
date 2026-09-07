import 'dart:convert';

import 'package:clothing_shop/constants/constants.dart';
import 'package:clothing_shop/models/location_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static String get apiKey => Constants.googleApiKey;

  // ───────────────────────────────────────────────
  // 1. Get current GPS position using Geolocator
  // ───────────────────────────────────────────────
  static Future<Position?> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied.');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied.');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('Geolocator error: $e');
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // 2. Reverse geocode via Google Geocoding API
  // ───────────────────────────────────────────────
  static Future<Map<String, String>> reverseGeocode(
    double lat,
    double lng,
  ) async {
    final result = <String, String>{
      'address': '$lat, $lng',
      'city': '',
      'state': '',
      'country': '',
      'postalCode': '',
    };

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng&key=$apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          result['address'] =
              results[0]['formatted_address']?.toString() ?? result['address']!;
          for (final comp
              in (results[0]['address_components'] as List? ?? [])) {
            final types = comp['types'] as List;
            if (types.contains('locality')) {
              result['city'] = comp['long_name']?.toString() ?? '';
            } else if (types.contains('administrative_area_level_1')) {
              result['state'] = comp['long_name']?.toString() ?? '';
            } else if (types.contains('country')) {
              result['country'] = comp['long_name']?.toString() ?? '';
            } else if (types.contains('postal_code')) {
              result['postalCode'] = comp['long_name']?.toString() ?? '';
            }
          }
        }
      } else {
        debugPrint(
            'Geocoding API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('reverseGeocode error: $e');
    }
    return result;
  }

  // ───────────────────────────────────────────────
  // 3. Full "get location + geocode" flow
  // ───────────────────────────────────────────────
  static Future<LocationModel?> getCurrentLocation() async {
    final position = await determinePosition();
    if (position == null) return null;

    final lat = position.latitude;
    final lng = position.longitude;
    final addr = await reverseGeocode(lat, lng);

    return LocationModel(
      latitude: lat,
      longitude: lng,
      address: addr['address']!,
      city: addr['city']!,
      state: addr['state']!,
      country: addr['country']!,
      postalCode: addr['postalCode']!,
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      timestamp: DateTime.now(),
    );
  }

  // ───────────────────────────────────────────────
  // 4. Save location to Firestore
  // ───────────────────────────────────────────────
  static Future<String?> sendLocationToFirestore(
    LocationModel location, {
    String collection = 'locations',
  }) async {
    try {
      final docRef =
          await _firestore.collection(collection).add(location.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Firestore write error: $e');
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // 5. Real-time stream of saved locations
  // ───────────────────────────────────────────────
  static Stream<List<LocationModel>> streamSavedLocations({
    String collection = 'locations',
  }) {
    return _firestore
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => LocationModel.fromMap(d.data(), d.id))
            .toList());
  }
}
