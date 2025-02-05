import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LocationController extends GetxController {
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _geocodingRetryTimer;
  int _retryAttempts = 0;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  var longitudeData = ''.obs;
  var latitudeData = ''.obs;
  var streetName = ''.obs;
  var city = ''.obs;
  var state = ''.obs;
  var countrys = ''.obs;
  var zipCode = ''.obs;
  var addressDetail = ''.obs;
  var ward = ''.obs;
  var districts = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    _geocodingRetryTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await getCurrentLocation();
    } catch (e) {
      errorMessage.value = 'Failed to initialize location: $e';
      debugPrint('Location initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Location permissions are denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permissions are permanently denied';
        return;
      }

      // Cancel existing subscription if any
      await _positionStreamSubscription?.cancel();

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (Position position) async {
          await _getAddressFromPosition(position);
        },
        onError: (error) {
          errorMessage.value = 'Location stream error: $error';
          debugPrint('Location stream error: $error');
        },
      );
    } catch (e) {
      errorMessage.value = 'Error getting location: $e';
      debugPrint('Location error: $e');
    }
  }

  Future<void> _getAddressFromPosition(Position position) async {
    try {
      _retryAttempts = 0;
      await _tryGeocoding(position);
    } catch (e) {
      _handleGeocodingError(position, e);
    }
  }

  Future<void> _tryGeocoding(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Geocoding timeout'),
      );

      if (placemarks.isNotEmpty) {
        await _updateLocationData(position, placemarks[0]);
      }
    } catch (e) {
      if (_retryAttempts < maxRetryAttempts) {
        _retryAttempts++;
        _scheduleRetry(position);
      } else {
        // If all retries failed, save at least the coordinates
        await _saveBasicLocationData(position);
        throw Exception(
            'Failed to get address after $maxRetryAttempts attempts');
      }
    }
  }

  void _scheduleRetry(Position position) {
    _geocodingRetryTimer?.cancel();
    _geocodingRetryTimer = Timer(
      retryDelay * _retryAttempts,
      () => _tryGeocoding(position),
    );
  }

  Future<void> _saveBasicLocationData(Position position) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      longitudeData.value = "${position.longitude}";
      latitudeData.value = "${position.latitude}";

      await prefs.setString("getLongitude", "${position.longitude}");
      await prefs.setString("getLatitude", "${position.latitude}");
    } catch (e) {
      debugPrint('Error saving basic location data: $e');
    }
  }

  Future<void> _updateLocationData(
      Position position, Placemark placeMark) async {
    try {
      String street =
          "${placeMark.thoroughfare ?? ''} ${placeMark.subThoroughfare ?? ''}"
              .trim();
      String subLocality = placeMark.subLocality ?? '';
      String locality = placeMark.locality ?? '';
      String administrativeArea = placeMark.administrativeArea ?? '';
      String subAdministrativeArea = placeMark.subAdministrativeArea ?? '';
      String postalCode = placeMark.postalCode ?? '';
      String country = placeMark.country ?? '';

      List<String> addressParts = [
        street,
        subLocality,
        locality,
        subAdministrativeArea,
        administrativeArea,
        postalCode,
        country,
      ].where((part) => part.isNotEmpty).toList();

      String fullAddress = addressParts.join(", ");

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Update observable values
      longitudeData.value = "${position.longitude}";
      latitudeData.value = "${position.latitude}";
      streetName.value = street;
      city.value = subAdministrativeArea;
      state.value = administrativeArea;
      countrys.value = country;
      zipCode.value = postalCode;
      addressDetail.value = fullAddress;
      ward.value = subLocality;
      districts.value = locality;

      // Save to SharedPreferences
      await prefs.setString("getStreetName", street);
      await prefs.setString("getCity", subAdministrativeArea);
      await prefs.setString("getCountry", country);
      await prefs.setString("getState", administrativeArea);
      await prefs.setString("getZipCode", postalCode);
      await prefs.setString("getSubLocality", subLocality);
      await prefs.setString("getLocality", locality);
      await prefs.setString("getAddressDetail", fullAddress);
      await prefs.setString("getLongitude", "${position.longitude}");
      await prefs.setString("getLatitude", "${position.latitude}");
    } catch (e) {
      debugPrint('Error updating location data: $e');
      await _saveBasicLocationData(position);
    }
  }

  void _handleGeocodingError(Position position, dynamic error) {
    debugPrint('Geocoding error: $error');
    errorMessage.value = 'Failed to get address details';
    _saveBasicLocationData(position);
  }

  // Method to manually retry getting location
  Future<void> retryLocationUpdate() async {
    errorMessage.value = '';
    _retryAttempts = 0;
    await getCurrentLocation();
  }
}
