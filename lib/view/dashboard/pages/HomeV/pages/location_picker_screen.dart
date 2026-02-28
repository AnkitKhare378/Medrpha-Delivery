import 'dart:async';
import 'package:flutter/material.dart' hide Route;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerScreen extends StatefulWidget {
  final String latitude;
  final String longitude;
  const LocationPickerScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentMapCenter;
  String _currentAddress = "Loading address...";
  bool _isLoading = false;

  // Dynamic destination based on passed params
  late LatLng _destinationLocation;

  static const String GOOGLE_API_KEY = "AIzaSyCzSRqABK9Y9M6rEFntgRvx4v0B74IlCEs";

  Future<void> _navigateToGoogleMaps() async {
    if (_currentMapCenter == null) return;

    final double originLat = _currentMapCenter!.latitude;
    final double originLng = _currentMapCenter!.longitude;
    final double destLat = _destinationLocation.latitude;
    final double destLng = _destinationLocation.longitude;

    // Standard Google Maps Directions URL
    final String url = "https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving";

    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  int _routeCalculationId = 0;
  double _distanceInKm = 0.0;
  String _travelTime = "Calculating...";
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late PolylinePoints _polylinePoints;
  late Future<CameraPosition> _initialCameraPositionFuture;

  @override
  void initState() {
    super.initState();
    print(widget.latitude);
    print(widget.longitude);

    // Parse the coordinates passed from the previous screen
    // Default to Lucknow coordinates if parsing fails
    double lat = double.tryParse(widget.latitude) ?? 0.0;
    double lng = double.tryParse(widget.longitude) ?? 0.0;
    _destinationLocation = LatLng(lat, lng);

    _polylinePoints = PolylinePoints(apiKey: GOOGLE_API_KEY);
    _initialCameraPositionFuture = _getInitialCameraPosition();
  }

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
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  Future<void> _fetchRouteAndDistance(int calculationId) async {
    if (_currentMapCenter == null) return;

    if (calculationId != _routeCalculationId) return;

    setState(() {
      _distanceInKm = 0.0;
      _travelTime = "Calculating...";
      _markers.clear();
      _polylines.clear();
    });

    _markers.add(
      Marker(
        markerId: const MarkerId('destination_location'),
        position: _destinationLocation,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    RoutesApiRequest request = RoutesApiRequest(
      origin: PointLatLng(_currentMapCenter!.latitude, _currentMapCenter!.longitude),
      destination: PointLatLng(_destinationLocation.latitude, _destinationLocation.longitude),
      travelMode: TravelMode.driving,
      routingPreference: RoutingPreference.trafficAware,
    );

    try {
      RoutesApiResponse response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: request,
      );

      if (calculationId != _routeCalculationId) return;

      if (response.routes.isNotEmpty) {
        var route = response.routes.first;
        setState(() {
          _distanceInKm = route.distanceKm ?? 0.0;
          _travelTime = "${route.durationMinutes ?? 0} min";
        });

        List<PointLatLng> points = route.polylinePoints ?? [];
        List<LatLng> polylineCoordinates = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('road_route'),
            points: polylineCoordinates,
            color: Colors.blue.shade700,
            width: 6,
          ),
        );
      } else {
        _handleFallbackRoute(calculationId);
        return;
      }
    } catch (e) {
      if (calculationId == _routeCalculationId) _handleFallbackRoute(calculationId);
      return;
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('user_selection_endpoint'),
        position: _currentMapCenter!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    setState(() {});

    if (_mapController != null && _currentMapCenter != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([_destinationLocation, _currentMapCenter!]),
          100.0,
        ),
      );
    }
  }

  void _handleFallbackRoute(int calculationId) {
    if (calculationId != _routeCalculationId) return;

    final distanceMeters = Geolocator.distanceBetween(
      _destinationLocation.latitude,
      _destinationLocation.longitude,
      _currentMapCenter!.latitude,
      _currentMapCenter!.longitude,
    );

    setState(() {
      _distanceInKm = distanceMeters / 1000;
      _travelTime = "${(_distanceInKm / 20 * 60).round()} min (Est.)";
    });

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('straight_route'),
        points: [_currentMapCenter!, _destinationLocation],
        color: Colors.red,
        width: 5,
        geodesic: true,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchAndSetCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      _currentMapCenter = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentMapCenter!, 16));
      _onCameraIdle();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocodeLocation(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _currentAddress = "${place.name}, ${place.locality}";
      }
    } catch (e) {
      _currentAddress = "Error fetching address.";
    }
    setState(() => _isLoading = false);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentMapCenter != null) {
      _routeCalculationId++;
      _fetchRouteAndDistance(_routeCalculationId);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
  }

  void _onCameraIdle() {
    if (_currentMapCenter != null) {
      setState(() {
        _isLoading = true;
        _routeCalculationId++;
      });
      _reverseGeocodeLocation(_currentMapCenter!);
      _fetchRouteAndDistance(_routeCalculationId);
    }
  }

  Future<CameraPosition> _getInitialCameraPosition() async {
    try {
      final position = await _determinePosition();
      _currentMapCenter = LatLng(position.latitude, position.longitude);
      _routeCalculationId++;
      _fetchRouteAndDistance(_routeCalculationId);
      return CameraPosition(target: _currentMapCenter!, zoom: 16);
    } catch (e) {
      _currentMapCenter = _destinationLocation;
      return CameraPosition(target: _destinationLocation, zoom: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Location', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FutureBuilder<CameraPosition>(
            future: _initialCameraPositionFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return GoogleMap(
                initialCameraPosition: snapshot.data!,
                onMapCreated: _onMapCreated,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              );
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Icon(Icons.location_on, color: Colors.blue.shade600, size: 40),
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildConfirmationSheet()),
        ],
      ),
    );
  }

  Widget _buildConfirmationSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currentAddress, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Distance: ${_distanceInKm.toStringAsFixed(2)} km | Time: $_travelTime'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToGoogleMaps,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Open in Google Maps', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}