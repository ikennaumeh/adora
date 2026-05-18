import 'package:adora/enums/location_source.dart';
import 'package:adora/models/location_record.dart';
import 'package:adora/services/database_service.dart';
import 'package:adora/ui/views/logs/logs_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bgLocationProvider = Provider((ref) => BackgroundLocationService(ref: ref));

/// Service responsible for background and terminated-state location tracking.
final class BackgroundLocationService {
  bool _isInitialized = false;
  final Ref ref;
  late DatabaseService dbService;

  BackgroundLocationService({required this.ref}){
    dbService = ref.read(dbServiceProvider);
  }

  /// Configures the background geolocation plugin and registers the
  /// location event listener.
  ///
  /// Safe to call multiple times — subsequent calls return immediately
  /// due to the [_isInitialized] guard.
  ///
  /// Must be called before [startTracking] or [stopTracking]. Called once
  /// at app startup in [WrapperView] so the plugin is ready before the
  /// user interacts with the tracking toggle.
  ///
  /// Note: [onLocation] must be registered BEFORE calling [ready] —
  /// this is a requirement of the plugin.
  Future<void> initialize() async {
    if (_isInitialized) return;

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      debugPrint("Background long: ${location.coords.longitude}");
      debugPrint("Background lat: ${location.coords.latitude}");
      debugPrint("Source: background");

      var record = LocationRecord(
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          timestamp: DateTime.now(),
          source: LocationSource.background,
      );

      // Persist the location record to local storage
      dbService.save(record);

      // Invalidate the logs provider so the logs screen reflects
      // the new entry if it is currently visible
      ref.invalidate(logsProvider);
    });

    await bg.BackgroundGeolocation.ready(bg.Config(
      geolocation: bg.GeoConfig(
        desiredAccuracy: bg.DesiredAccuracy.high,
        distanceFilter: 0, //For testing sake, this is set to 0 so it's been fired more often than not.
        locationUpdateInterval: 10000,
      ),
      app: bg.AppConfig(
        stopOnTerminate: false,
        startOnBoot: false,
        enableHeadless: true,
      ),
      notification: bg.Notification(
        title: "Location Tracking Active",
        text: "Tracking your location",
      ),
      backgroundPermissionRationale: bg.PermissionRationale(
        title: "Allow location access in the background?",
        message: "This app needs access to your location even when the app is closed so it can log your position at regular intervals.",
        positiveAction: "Allow all the time",
        negativeAction: "Cancel",
      ),
      logger: bg.LoggerConfig(
        debug: true,
        logLevel: bg.LogLevel.verbose,
      )
    ));

    _isInitialized = true;
  }

  /// Starts background location tracking.
  ///
  /// The plugin will begin firing location events and showing the
  /// persistent notification. Tracking continues in the background
  /// and after the app is terminated (via the headless task).
  Future<void> startTracking() async {
    await bg.BackgroundGeolocation.start();
  }

  /// Stops background location tracking.
  ///
  /// The persistent notification is dismissed and no further location
  /// events will fire until [startTracking] is called again.
  Future<void> stopTracking() async {
    await bg.BackgroundGeolocation.stop();
  }
}