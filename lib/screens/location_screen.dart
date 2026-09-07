import 'dart:async';

import 'package:clothing_shop/models/location_model.dart';
import 'package:clothing_shop/providers/location_provider.dart';
import 'package:clothing_shop/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────
//  PINNED MAP SCREEN — opened when user taps a saved location card
// ─────────────────────────────────────────────────────────────────
class PinnedMapScreen extends StatefulWidget {
  final LocationModel location;
  const PinnedMapScreen({super.key, required this.location});

  @override
  State<PinnedMapScreen> createState() => _PinnedMapScreenState();
}

class _PinnedMapScreenState extends State<PinnedMapScreen> {
  final Completer<GoogleMapController> _ctrl = Completer();
  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    final loc = widget.location;
    _markers = {
      Marker(
        markerId: MarkerId(loc.id.isNotEmpty ? loc.id : 'pin'),
        position: LatLng(loc.latitude, loc.longitude),
        infoWindow: InfoWindow(
          title: loc.label,
          snippet: loc.address,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.location;
    final timeStr = loc.timestamp != null
        ? DateFormat('MMM d, yyyy · h:mm a').format(loc.timestamp!)
        : '';

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          loc.label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.forest),
            tooltip: 'Copy coordinates',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text:
                    '${loc.latitude}, ${loc.longitude}\n${loc.address}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coordinates copied!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(loc.latitude, loc.longitude),
              zoom: 16,
            ),
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (c) {
              if (!_ctrl.isCompleted) _ctrl.complete(c);
              // Show the info window automatically
              Future.delayed(const Duration(milliseconds: 600), () {
                c.showMarkerInfoWindow(
                  MarkerId(loc.id.isNotEmpty ? loc.id : 'pin'),
                );
              });
            },
          ),

          // Bottom address card
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.forest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          loc.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forest,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeStr,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.sub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place,
                          color: AppColors.forest, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          loc.address,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (loc.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${loc.note}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.sub,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.sub),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  MAIN LOCATION SCREEN
// ─────────────────────────────────────────────────────────────────
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _labelController =
      TextEditingController(text: 'Delivery Address');
  final TextEditingController _noteController = TextEditingController();

  static const _presetLabels = [
    'Delivery Address',
    'Home',
    'Work',
    'Current Spot',
  ];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LocationProvider>();
      if (provider.currentLocation == null) {
        _fetchAndAnimate();
      } else {
        _updateMarker(provider.currentLocation!);
      }
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndAnimate() async {
    final provider = context.read<LocationProvider>();
    final loc = await provider.fetchCurrentLocation();
    if (loc != null && mounted) {
      _updateMarker(loc);
      await _animateTo(loc.latitude, loc.longitude);
    }
  }

  void _updateMarker(LocationModel loc) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: InfoWindow(
            title:
                loc.city.isNotEmpty ? loc.city : 'Current Location',
            snippet: loc.address,
          ),
        ),
      };
    });
  }

  Future<void> _animateTo(double lat, double lng) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15.5),
      ),
    );
  }

  void _openPinnedMap(LocationModel loc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinnedMapScreen(location: loc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();
    final loc = provider.currentLocation;
    final isLoading = provider.isLoading;
    final isSending = provider.isSending;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text(
          'Current Location',
          style:
              TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh GPS',
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.forest),
                  )
                : const Icon(Icons.my_location,
                    color: AppColors.forest),
            onPressed: isLoading ? null : _fetchAndAnimate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────────────────
            // LIVE GOOGLE MAP WITH ANIMATED PIN
            // ─────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: loc != null
                            ? LatLng(loc.latitude, loc.longitude)
                            : const LatLng(27.7172, 85.3240),
                        zoom: loc != null ? 15.5 : 12,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (controller) {
                        if (!_mapController.isCompleted) {
                          _mapController.complete(controller);
                        }
                        if (loc != null) {
                          Future.delayed(
                            const Duration(milliseconds: 800),
                            () => controller.showMarkerInfoWindow(
                                const MarkerId('current')),
                          );
                        }
                      },
                    ),

                    // Google Maps badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.forestDark
                              .withValues(alpha: 0.87),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 13, color: AppColors.gold),
                            SizedBox(width: 4),
                            Text(
                              'Live Google Maps',
                              style: TextStyle(
                                color: AppColors.paper,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Loading overlay
                    if (isLoading)
                      Container(
                        color: Colors.white.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.forest),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─────────────────────────────────────────
            // ADDRESS CARD
            // ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: loc != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.forest
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.place,
                                  color: AppColors.forest, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.city.isNotEmpty
                                        ? loc.city
                                        : 'Current Location',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc.address,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.sub,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _pill(
                                'Lat: ${loc.latitude.toStringAsFixed(5)}',
                                Icons.explore_outlined),
                            _pill(
                                'Lng: ${loc.longitude.toStringAsFixed(5)}',
                                Icons.explore_outlined),
                            if (loc.country.isNotEmpty)
                              _pill(loc.country, Icons.public),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.location_off_outlined,
                            color: AppColors.clay, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.errorMessage ??
                                'Tap the refresh button above to detect your location.',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.sub),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 22),

            // ─────────────────────────────────────────
            // LABEL CHIPS
            // ─────────────────────────────────────────
            const Text(
              'Tag / Label',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetLabels.map((lbl) {
                final isSelected = _labelController.text
                        .trim()
                        .toLowerCase() ==
                    lbl.toLowerCase();
                return GestureDetector(
                  onTap: () =>
                      setState(() => _labelController.text = lbl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.forest
                          : AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.forest
                            : AppColors.line,
                      ),
                    ),
                    child: Text(
                      lbl,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.paper
                            : AppColors.ink,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // ─────────────────────────────────────────
            // NOTE FIELD
            // ─────────────────────────────────────────
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Delivery Note / Landmark (Optional)',
                labelStyle: const TextStyle(
                    fontSize: 13, color: AppColors.sub),
                hintText: 'e.g. Gate 2, near coffee shop...',
                hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.sub.withValues(alpha: 0.6)),
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.forest, width: 2)),
              ),
            ),

            const SizedBox(height: 18),

            // ─────────────────────────────────────────
            // SEND BUTTON
            // ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (isSending || isLoading)
                    ? null
                    : () async {
                        final success = await context
                            .read<LocationProvider>()
                            .sendCurrentLocation(
                              label: _labelController.text,
                              note: _noteController.text,
                            );
                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Location pinned & saved to Firestore!'),
                                ],
                              ),
                              backgroundColor: AppColors.forestDark,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _noteController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errorMessage ??
                                    'Failed to send. Try again.',
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.push_pin_rounded, size: 18),
                label: Text(
                  isSending
                      ? 'Pinning to Firestore...'
                      : 'Pin & Send Location to Firestore',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.paper,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ─────────────────────────────────────────
            // FIRESTORE SAVED LOCATIONS STREAM
            // ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved Pins',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tap a card to open its pin on map',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            StreamBuilder<List<LocationModel>>(
              stream: provider.savedLocationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                          color: AppColors.forest),
                    ),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.push_pin_outlined,
                            size: 36, color: AppColors.sub),
                        SizedBox(height: 10),
                        Text(
                          'No pinned locations yet',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap "Pin & Send Location" to save your first pin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.sub),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _locationCard(list[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────

  Widget _pill(String text, IconData icon) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.sub),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  /// Tappable card → opens PinnedMapScreen for that location
  Widget _locationCard(LocationModel item) {
    final timeStr = item.timestamp != null
        ? DateFormat('MMM d · h:mm a').format(item.timestamp!)
        : 'Just now';

    return GestureDetector(
      onTap: () => _openPinnedMap(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini Google Map thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: AbsorbPointer(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(item.latitude, item.longitude),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(
                            item.id.isNotEmpty ? item.id : 'pin_$timeStr'),
                        position: LatLng(item.latitude, item.longitude),
                      ),
                    },
                    liteModeEnabled: true,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.forest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forest,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                            fontSize: 9.5, color: AppColors.sub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.3),
                  ),
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Note: ${item.note}',
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.sub,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                            fontSize: 10.5, color: AppColors.sub),
                      ),
                      const Spacer(),
                      // Tap hint
                      const Row(
                        children: [
                          Icon(Icons.map,
                              size: 13, color: AppColors.forest),
                          SizedBox(width: 3),
                          Text(
                            'View pin',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.forest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
