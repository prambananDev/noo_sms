import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:noo_sms/controllers/order_tracking/order_tracking_controller.dart';

class MapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? address;

  const MapWidget({
    Key? key,
    this.latitude,
    this.longitude,
    this.address,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final OrderTrackingController _controller =
      Get.find<OrderTrackingController>();

  GoogleMapController? _mapController;
  String _currentAddress = "";
  Timer? _locationUpdateTimer;
  bool _isLoading = true;
  String? _errorMessage;

  static const double _defaultLatitude = -6.2088;
  static const double _defaultLongitude = 106.8456;

  double get _currentLatitude {
    // Use provided latitude first
    if (widget.latitude != null) return widget.latitude!;

    // Get from controller using the new model structure
    final driverLocation = _controller.driverLocation;
    if (driverLocation != null && driverLocation['latitude'] != null) {
      return driverLocation['latitude']!;
    }

    return _defaultLatitude;
  }

  double get _currentLongitude {
    // Use provided longitude first
    if (widget.longitude != null) return widget.longitude!;

    // Get from controller using the new model structure
    final driverLocation = _controller.driverLocation;
    if (driverLocation != null && driverLocation['longitude'] != null) {
      return driverLocation['longitude']!;
    }

    return _defaultLongitude;
  }

  String get _driverName {
    final driverInfo = _controller.driverInfo;
    return driverInfo?.displayName ?? 'Driver';
  }

  String get _vehicleNumber {
    final driverInfo = _controller.driverInfo;
    return driverInfo?.displayPlatNumber ?? 'N/A';
  }

  String get _lastUpdated {
    final driverInfo = _controller.driverInfo;
    if (driverInfo?.lastPosition != null) {
      return driverInfo!.lastPosition!.formattedDateTime;
    }
    return 'Unknown';
  }

  bool get _hasValidLocation {
    return _currentLatitude != _defaultLatitude ||
        _currentLongitude != _defaultLongitude;
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _initializeMap() {
    _getLocationAddress(_currentLatitude, _currentLongitude);

    // Set up periodic updates only if we have valid tracking data
    if (_controller.hasTrackingDetail) {
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30), // Increased to 30 seconds
        (_) => _updateLocationAndAddress(),
      );
    }
  }

  Future<void> _updateLocationAndAddress() async {
    try {
      // Refresh tracking detail to get latest location
      if (_controller.hasTrackingDetail) {
        await _controller.refreshTrackingDetail();
      }

      await _getLocationAddress(_currentLatitude, _currentLongitude);
      await _animateToPosition(_currentLatitude, _currentLongitude);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update location: ${e.toString()}';
        });
      }
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> _getLocationAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final placemark = placemarks.first;
        final address = _buildAddressString(placemark);

        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      // Set a fallback address
      if (mounted) {
        setState(() {
          _currentAddress =
              'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
        });
      }
    }
  }

  String _buildAddressString(Placemark placemark) {
    final components = <String>[];

    if (placemark.thoroughfare?.isNotEmpty == true) {
      components.add(placemark.thoroughfare!);
    }
    if (placemark.subThoroughfare?.isNotEmpty == true) {
      components.add(placemark.subThoroughfare!);
    }
    if (placemark.street?.isNotEmpty == true &&
        !components.contains(placemark.street)) {
      components.add(placemark.street!);
    }

    if (placemark.subLocality?.isNotEmpty == true) {
      components.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      components.add(placemark.locality!);
    }
    if (placemark.subAdministrativeArea?.isNotEmpty == true) {
      components.add(placemark.subAdministrativeArea!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      components.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode?.isNotEmpty == true) {
      components.add(placemark.postalCode!);
    }
    if (placemark.country?.isNotEmpty == true) {
      components.add(placemark.country!);
    }

    return components.join(', ');
  }

  Future<void> _animateToPosition(double latitude, double longitude) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latitude, longitude),
          16.0,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint('Google Map created successfully');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('driver_location'),
        position: LatLng(_currentLatitude, _currentLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _hasValidLocation
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueAzure,
        ),
        anchor: const Offset(0.5, 1.0),
        infoWindow: InfoWindow(
          title: _hasValidLocation
              ? '$_driverName ($_vehicleNumber)'
              : 'Default Location',
          snippet: _displayAddress.isNotEmpty
              ? _displayAddress
              : 'Loading address...',
        ),
      ),
    };
  }

  String get _displayAddress {
    return widget.address ?? _currentAddress;
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Map...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? 'Unknown error occurred',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _updateLocationAndAddress();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    if (_displayAddress.isEmpty && !_hasValidLocation) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hasValidLocation
                          ? '$_driverName ($_vehicleNumber)'
                          : 'Default Location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_displayAddress.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _displayAddress,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (_hasValidLocation) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last updated: $_lastUpdated',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              if (!_hasValidLocation) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Showing default location - driver location not available',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          _updateLocationAndAddress();
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 2,
        child: _controller.isLoadingTrackingDetail.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Location Tracking',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Obx(() => Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: GoogleMap(
                  mapType: MapType.normal,
                  trafficEnabled: true,
                  compassEnabled: true,
                  buildingsEnabled: false,
                  rotateGesturesEnabled: true,
                  indoorViewEnabled: false,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  mapToolbarEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentLatitude, _currentLongitude),
                    zoom: 16.0,
                  ),
                  markers: _buildMarkers(),
                  liteModeEnabled: false,
                  gestureRecognizers: const <Factory<
                      OneSequenceGestureRecognizer>>{},
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
              if (_errorMessage != null && !_isLoading) _buildErrorOverlay(),
              if (!_isLoading && _errorMessage == null)
                _buildLocationInfoCard(),
              if (!_isLoading && _errorMessage == null) _buildRefreshButton(),
            ],
          )),
    );
  }
}
