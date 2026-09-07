import 'package:clothing_shop/models/location_model.dart';
import 'package:clothing_shop/services/location_service.dart';
import 'package:flutter/foundation.dart';

class LocationProvider extends ChangeNotifier {
  LocationModel? _currentLocation;
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _lastSentDocId;

  LocationModel? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get lastSentDocId => _lastSentDocId;

  /// Fetches the user's current GPS/Google location and reverse-geocodes it.
  Future<LocationModel?> fetchCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
      } else {
        _errorMessage = 'Could not fetch current location. Please ensure location services/permissions are enabled.';
      }
      return _currentLocation;
    } catch (e) {
      _errorMessage = 'Location error: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends the current location to Firestore database.
  Future<bool> sendCurrentLocation({
    String label = 'Current Location',
    String note = '',
  }) async {
    if (_currentLocation == null) {
      final loc = await fetchCurrentLocation();
      if (loc == null) return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedLocation = _currentLocation!.copyWith(
        label: label.trim().isNotEmpty ? label.trim() : 'Current Location',
        note: note.trim(),
        timestamp: DateTime.now(),
      );

      final docId = await LocationService.sendLocationToFirestore(updatedLocation);
      if (docId != null) {
        _lastSentDocId = docId;
        _currentLocation = updatedLocation.copyWith(id: docId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send location to Firestore.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error sending location: $e';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Real-time stream of all saved locations in Firestore.
  Stream<List<LocationModel>> get savedLocationsStream =>
      LocationService.streamSavedLocations();
}
