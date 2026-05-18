import 'package:adora/services/background_location_service.dart';
import 'package:adora/services/database_service.dart';
import 'package:adora/services/location_service.dart';
import 'package:adora/enums/location_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'live_state.dart';


final liveProvider = NotifierProvider<LiveNotifier, LiveState>(LiveNotifier.new);

class LiveNotifier extends Notifier<LiveState>{
  late final LocationService locationService;
  late final BackgroundLocationService backgroundService;
  late final DatabaseService databaseService;

  @override
  LiveState build() {
    locationService = ref.read(locationProvider);
    backgroundService = ref.read(bgLocationProvider);
    databaseService = ref.read(dbServiceProvider);

    // Restore background tracking toggle state from previous session
    _loadTrackingState();

    return LiveState(
      currentPosition: null,
      isLoading: false,
      hasError: false,
      errorType: null,
      isBackgroundTracking: false,
      isTrackingLoading: false,
    );
  }

  /// Opens the device app settings page.
  /// Used when location permission is permanently denied so the user
  /// can manually enable it from settings.
  Future<void> openAppSettings() async {
    await locationService.openAppSettings;
  }

  /// Opens the device location settings page.
  /// Used when location services are completely disabled on the device.
  Future<void> openLocationSettings() async {
    await locationService.openLocationSettings;
  }

  /// Fetches the current device location and updates state accordingly.
  ///
  /// Handles all permission and service failure scenarios individually
  /// so the UI can display a contextual error message and action button
  /// for each case rather than a generic error.
  Future<void> getLiveLocation() async {
    state = state.copyWith(isLoading: true,hasError: false, errorType: null);

    try{
      final position = await locationService.getCurrentLocation();
      state = state.copyWith(currentPosition: position, isLoading: false);

    } on PermissionDeniedException catch (e){
      final isPermanent = e.message == "Permission permanently denied";
      state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorType: isPermanent
              ? LocationError.permissionPermanentlyDenied
              : LocationError.permissionDenied,
      );
    } on LocationServiceDisabledException catch (_){
      state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorType: LocationError.serviceDisabled,
      );
    } catch (e){
      state = state.copyWith(isLoading: false, hasError: true, errorType: LocationError.unknown);
    }
  }

  /// Restores the background tracking toggle from local storage on app launch.
  ///
  /// If tracking was active in the previous session, it is automatically
  /// resumed so the user doesn't need to re-enable it every time they open
  /// the app.
  Future<void> _loadTrackingState() async {
    final isTracking = await databaseService.getTrackingState();
    state = state.copyWith(isBackgroundTracking: isTracking);

    if (isTracking) {
      await backgroundService.startTracking();
    }
  }

  /// Toggles background location tracking on or off.
  ///
  /// Persists the new toggle state to local storage so it survives
  /// app restarts. Shows a loading indicator on the toggle while the
  /// native start/stop operation completes.
  Future<void> toggleBackgroundTracking() async {
    state = state.copyWith(isTrackingLoading: true);

    try {
      if (state.isBackgroundTracking) {
        await backgroundService.stopTracking();
      } else {
        await backgroundService.startTracking();
      }

      final newValue = !state.isBackgroundTracking;

      // Persist the new tracking state so it can be restored on next launch
      databaseService.setTrackingState(newValue);

      state = state.copyWith(
        isBackgroundTracking: newValue,
        isTrackingLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isTrackingLoading: false);
      debugPrint('======Toggle error: $e======');
    }
  }

}