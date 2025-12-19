import 'dart:async';
import 'package:flutter/material.dart' hide Route;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentMapCenter;
  String _currentAddress = "Loading address...";
  bool _isLoading = false;

  Future<void> _navigateToGoogleMaps() async {
    if (_currentMapCenter == null) return;

    // 1. Get coordinates
    final double originLat = _currentMapCenter!.latitude;
    final double originLng = _currentMapCenter!.longitude;
    final double destLat = _labLocation.latitude;
    final double destLng = _labLocation.longitude;

    // 2. Construct the official Directions URL
    // api=1: ensures we use the modern Google Maps platform
    // origin: the point the user selected on your map
    // destination: the fixed lab location
    // travelmode: set to driving for the clearest single route
    final String url =
        "https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving";

    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Forces the native app to open
        );
      } else {
        throw 'Could not launch Google Maps';
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
      // Fallback: Try opening in a browser if the app isn't installed
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  // Future<void> _navigateToGoogleMaps() async {
  //   if (_currentMapCenter == null) return;
  //
  //   // Use the 'google.navigation' query for turn-by-turn navigation
  //   // destination: your _labLocation
  //   // origin: your current map selection (_currentMapCenter)
  //   final String googleMapsUrl =
  //       "https://www.google.com/maps/dir/?api=1&origin=${_currentMapCenter!.latitude},${_currentMapCenter!.longitude}&destination=${_labLocation.latitude},${_labLocation.longitude}&travelmode=driving";
  //
  //   final Uri uri = Uri.parse(googleMapsUrl);
  //
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch $googleMapsUrl';
  //   }
  // }


  int _routeCalculationId = 0;

  static const String GOOGLE_API_KEY = "AIzaSyCzSRqABK9Y9M6rEFntgRvx4v0B74IlCEs";
  static const LatLng _labLocation = LatLng(26.826260, 80.914818); // Default destination (Lucknow)

  // State for route data and map overlays
  double _distanceInKm = 0.0;
  String _travelTime = "Calculating...";
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Initialize PolylinePoints helper
  late PolylinePoints _polylinePoints;

  late Future<CameraPosition> _initialCameraPositionFuture;

  @override
  void initState() {
    super.initState();
    // Initialize PolylinePoints with your API Key
    _polylinePoints = PolylinePoints(apiKey: GOOGLE_API_KEY);
    _initialCameraPositionFuture = _getInitialCameraPosition();
  }

  // Helper function to calculate bounds for fitting markers on screen
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    if (x0 == null) {
      return LatLngBounds(northeast: _labLocation, southwest: _labLocation);
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  // --- 2. FUNCTION: Fetches and Draws Route using Routes API V2 ---
  // Added required `calculationId` parameter
  Future<void> _fetchRouteAndDistance(int calculationId) async {
    if (_currentMapCenter == null) return;

    // CRITICAL CHECK 1: Check if the map has moved since this task was started
    if (calculationId != _routeCalculationId) {
      return; // Abort this outdated update.
    }

    // Clear state only for this successful path, will be drawn later.
    setState(() {
      _distanceInKm = 0.0;
      _travelTime = "Calculating...";
      _markers.clear();
      _polylines.clear();
    });

    // Add ONLY the Destination marker (Lab Location)
    _markers.add(
      Marker(
        markerId: const MarkerId('lab_location'),
        position: _labLocation,
        infoWindow: const InfoWindow(title: 'Lab Location (Destination)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Create Routes API V2 request
    RoutesApiRequest request = RoutesApiRequest(
      origin: PointLatLng(_currentMapCenter!.latitude, _currentMapCenter!.longitude),
      destination: PointLatLng(_labLocation.latitude, _labLocation.longitude),
      // Use DRIVING, which typically covers two-wheelers in areas like India.
      travelMode: TravelMode.driving,
      routingPreference: RoutingPreference.trafficAware,
    );

    try {
      RoutesApiResponse response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: request,
      );

      // CRITICAL CHECK 2: Check again after the async `await`
      if (calculationId != _routeCalculationId) {
        return;
      }

      if (response.routes.isNotEmpty) {
        Route route = response.routes.first;

        // 3. Update distance and time from Routes API response
        setState(() {
          _distanceInKm = route.distanceKm ?? 0.0;
          _travelTime = "${route.durationMinutes ?? 0} min";
        });

        // Get polyline points
        List<PointLatLng> points = route.polylinePoints ?? [];
        List<LatLng> polylineCoordinates = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Draw the road-based polyline
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('road_route'),
            points: polylineCoordinates,
            color: Colors.blue.shade700,
            width: 6, // Increased width for better visibility, like in screenshot
          ),
        );
      } else {
        // Fallback if no route found (e.g., API error, unreachable location)
        _handleFallbackRoute(calculationId);
        return; // Exit after handling fallback
      }
    } catch (e) {
      print("Error fetching route from Routes API V2: $e");

      // CRITICAL CHECK 3: Check again before calling fallback
      if (calculationId != _routeCalculationId) {
        return;
      }

      _handleFallbackRoute(calculationId);
      return; // Exit after handling fallback
    }

    // Add the Origin marker (Blue dot) only after a successful calculation
    _markers.add(
      Marker(
        markerId: const MarkerId('user_selection_endpoint'),
        position: _currentMapCenter!,
        infoWindow: const InfoWindow(title: 'Pickup Location (Origin)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    setState(() {}); // Update the map with new markers/polylines

    // Animate camera to show both points
    if (_mapController != null && _currentMapCenter != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([_labLocation, _currentMapCenter!]),
          100.0, // padding
        ),
      );
    }
  }

  void _handleFallbackRoute(int calculationId) {
    // CRITICAL CHECK: Check before updating state
    if (calculationId != _routeCalculationId) {
      return;
    }

    // Fallback: Use Geolocator for straight line distance and time estimate
    final distanceMeters = Geolocator.distanceBetween(
      _labLocation.latitude,
      _labLocation.longitude,
      _currentMapCenter!.latitude,
      _currentMapCenter!.longitude,
    );

    setState(() {
      _distanceInKm = distanceMeters / 1000;
      // Simple estimate based on straight line distance
      _travelTime = "${(_distanceInKm / 20 * 60).round()} min (Est.)";
    });

    // Draw fallback straight line
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('straight_route'),
        points: [_currentMapCenter!, _labLocation],
        color: Colors.red,
        width: 5,
        geodesic: true,
      ),
    );

    // Add the Origin marker even for fallback
    _markers.add(
      Marker(
        markerId: const MarkerId('user_selection_endpoint'),
        position: _currentMapCenter!,
        infoWindow: const InfoWindow(title: 'Pickup Location (Origin)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  // Gets current location and handles permissions (no change)
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
  }

  Future<void> _fetchAndSetCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      _currentMapCenter = LatLng(position.latitude, position.longitude);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentMapCenter!, 16),
      );

      // Trigger map idle logic immediately after moving to current location
      _onCameraIdle();

    } catch (e) {
      _currentAddress = "Error: ${e.toString()}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_currentAddress)),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocodeLocation(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _currentAddress = "${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
      } else {
        _currentAddress = "Address not found for this location.";
      }
    } catch (e) {
      _currentAddress = "Error fetching address.";
    }
    setState(() {
      _isLoading = false;
    });
  }

  // --- Map Callbacks ---

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentMapCenter != null) {
      _routeCalculationId++; // Increment ID on create
      // Fetch route if location was already initialized
      _fetchRouteAndDistance(_routeCalculationId);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
    _currentAddress = "Searching for address...";
    // Clear route info, markers, and polylines immediately when map starts moving.
    setState(() {
      _distanceInKm = 0.0;
      _travelTime = "Calculating...";
      _markers.clear();
      _polylines.clear();
    });
    // NOTE: We do NOT increment the ID here. The ID is incremented on IDLE
    // to distinguish new calculation requests. Clearing the state is enough
    // to visually stop the "decreasing" route.
  }

  void _onCameraIdle() {
    if (_currentMapCenter != null) {
      setState(() {
        _isLoading = true;
        _routeCalculationId++; // CRITICAL: Increment ID for the new calculation
      });
      // 1. Get address
      _reverseGeocodeLocation(_currentMapCenter!);
      // 2. Calculate and draw route
      _fetchRouteAndDistance(_routeCalculationId); // Pass the new ID
    }
  }

  Future<CameraPosition> _getInitialCameraPosition() async {
    try {
      final position = await _determinePosition();
      _currentMapCenter = LatLng(position.latitude, position.longitude);

      await _reverseGeocodeLocation(_currentMapCenter!);

      // Calculate and draw route immediately on initial load
      _routeCalculationId++;
      _fetchRouteAndDistance(_routeCalculationId);

      return CameraPosition(
        target: _currentMapCenter!,
        zoom: 16,
      );
    } catch (e) {
      print("Error fetching initial location: $e");

      setState(() {
        _currentAddress = "Location access denied. Showing default area.";
      });

      _currentMapCenter = _labLocation;
      // Show route starting from lab location if current location fails
      _routeCalculationId++;
      _fetchRouteAndDistance(_routeCalculationId);

      return CameraPosition(
        target: _labLocation,
        zoom: 14,
      );
    }
  }

  // Helper to shorten location for the AppBar
  String _getShortLocation(String fullAddress) {
    if (fullAddress.contains(',')) {
      final parts = fullAddress.split(',');
      if (parts.length >= 2) {
        final specificPart = parts.first.trim();
        final cityPart = parts[1].trim();
        return '$specificPart, $cityPart';
      }
      return parts.first.trim();
    }
    if (fullAddress.length > 25) {
      return fullAddress.substring(0, 25) + '...';
    }
    return fullAddress;
  }

  Widget _buildConfirmationSheet() {
    final iconColor = Colors.blue.shade600;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order will be delivered here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.location_on, color: iconColor, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Distance and Time display
          Text(
            // The time estimation is now much more accurate from the Routes API
            'Distance to Lab: ${_distanceInKm.toStringAsFixed(1)} km (Est. ${_travelTime})',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Show address update loading in the button area
          _isLoading
              ? const Center(child: LinearProgressIndicator(minHeight: 5))
              : SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: ()async  {
                await _navigateToGoogleMaps();
                final shortAddress = _getShortLocation(_currentAddress);
                Navigator.pop(context, shortAddress);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirm & proceed',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pickup Location',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Use FutureBuilder to wait for the initial CameraPosition
          FutureBuilder<CameraPosition>(
            future: _initialCameraPositionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while fetching location
                return const Center(child: CircularProgressIndicator());
              }

              // Use the fetched position or the default fallback position
              final initialPosition = snapshot.data ?? const CameraPosition(target: LatLng(0, 0), zoom: 13);

              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: initialPosition,
                onMapCreated: _onMapCreated,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle, // Update address when map stops moving
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                // Pass the markers and polylines to the map
                markers: _markers,
                polylines: _polylines,
              );
            },
          ),

          // Center Marker (The pin at the center of the map) - Indicates user's selection point
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Icon(
                Icons.location_on,
                color: Colors.blue.shade600,
                size: 40,
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            right: 15,
            bottom: 250,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
              onPressed: _fetchAndSetCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildConfirmationSheet(),
          ),
        ],
      ),
    );
  }
}