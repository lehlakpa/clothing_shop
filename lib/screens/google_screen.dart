import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleScreen extends StatefulWidget {
  const GoogleScreen({super.key});

  @override
  State<GoogleScreen> createState() => _GoogleScreenState();
}

class _GoogleScreenState extends State<GoogleScreen> {
  GoogleMapController? _mapController;

  StreamSubscription<Position>? _positionSubscription;

  Position? _currentPosition;

  bool _loading = true;
  String? _errorMessage;

  // Default location if GPS has not loaded yet.
  static const LatLng _defaultLocation = LatLng(
    27.7172,
    85.3240,
  );

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  // ------------------------------------------------------------
  // INITIALIZE LOCATION
  // ------------------------------------------------------------

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      // Check if GPS/location service is enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _loading = false;
          _errorMessage = 'Location service is disabled.';
        });

        await Geolocator.openLocationSettings();
        return;
      }

      // Check permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      // Request permission if not granted.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // User denied permission.
      if (permission == LocationPermission.denied) {
        setState(() {
          _loading = false;
          _errorMessage = 'Location permission denied.';
        });
        return;
      }

      // User permanently denied permission.
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _errorMessage =
              'Location permission permanently denied.';
        });
        return;
      }

      // Get current location.
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _loading = false;
      });

      // Move camera to current location.
      _moveCamera(position);

      // Start live location tracking.
      _startLocationTracking();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Could not get location: $e';
      });
    }
  }

  // ------------------------------------------------------------
  // LIVE LOCATION
  // ------------------------------------------------------------

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (!mounted) return;

        setState(() {
          _currentPosition = position;
        });

        // Keep camera following the user.
        _moveCamera(position);
      },
    );
  }

  // ------------------------------------------------------------
  // MOVE CAMERA
  // ------------------------------------------------------------

  Future<void> _moveCamera(Position position) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 17,
          tilt: 0,
          bearing: 0,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MOVE TO CURRENT LOCATION BUTTON
  // ------------------------------------------------------------

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition == null) {
      await _initializeLocation();
      return;
    }

    await _moveCamera(_currentPosition!);
  }

  // ------------------------------------------------------------
  // MAP CREATED
  // ------------------------------------------------------------

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (_currentPosition != null) {
      _moveCamera(_currentPosition!);
    }
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final LatLng initialTarget = _currentPosition != null
        ? LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          )
        : _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Current Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // ------------------------------------------------------
          // GOOGLE MAP
          // ------------------------------------------------------

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 15,
            ),

            onMapCreated: _onMapCreated,

            // Shows Google's blue current-location dot.
            myLocationEnabled: true,

            // We create our own button.
            myLocationButtonEnabled: false,

            zoomControlsEnabled: false,

            compassEnabled: true,

            mapToolbarEnabled: false,

            // You can change this to satellite.
            mapType: MapType.normal,

            // Allow normal Google Maps gestures.
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
          ),

          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (_loading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Getting your location...',
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (_errorMessage != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: _initializeLocation,
                        child: const Text('Try Again'),
                      ),

                      if (_errorMessage!
                          .contains('permanently'))
                        TextButton(
                          onPressed: () {
                            Geolocator.openAppSettings();
                          },
                          child: const Text(
                            'Open App Settings',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // ------------------------------------------------------
          // LOCATION INFORMATION
          // ------------------------------------------------------

          if (_currentPosition != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: _locationCard(),
            ),

          // ------------------------------------------------------
          // CURRENT LOCATION BUTTON
          // ------------------------------------------------------

          Positioned(
            right: 18,
            bottom: 180,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              child: const Icon(
                Icons.my_location,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LOCATION CARD
  // ------------------------------------------------------------

  Widget _locationCard() {
    final position = _currentPosition!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.green,
                size: 28,
              ),

              SizedBox(width: 8),

              Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Latitude: ${position.latitude.toStringAsFixed(6)}',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Longitude: ${position.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Accuracy: ${position.accuracy.toStringAsFixed(1)} m',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}