import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationProvider = Provider<LocationService>((_) => LocationService());

/// Service responsible for handling foreground location access.
final class LocationService {

  /// Determine the current position of the device.
  Future<Position> getCurrentLocation() async {
    try {
      ///Requests for the location permission
      final result = await _requestLocationPermission;

      if (result) {
        // If its true then get the current location and move to the choose
        // location screen
        return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 20),
          ),
        );
      } else {
        throw const PermissionDeniedException("Permission denied");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Getter for open location setting
  Future<bool> get openLocationSettings async =>
      Geolocator.openLocationSettings();

  // Getter for open app settings
  Future<bool> get openAppSettings async => Geolocator.openAppSettings();

  // Getter for request location permission
  Future<bool> get requestLocationPermission async =>
      await _requestLocationPermission;

  // Request location permission
  Future<bool> get _requestLocationPermission async {
    late bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceDisabledException();
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException("Permission permanently denied");
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException("Permission permanently denied");
      }
    }

    return true;
  }


}