import 'package:adora/services/database_service.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'enums/location_source.dart';
import 'models/location_record.dart';

/// Headless task that handles location events when the app is fully terminated.
@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  if(headlessEvent.name == bg.Event.LOCATION){
    final bg.Location location = headlessEvent.event;

    var record = LocationRecord(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      timestamp: DateTime.now(),
      source: LocationSource.terminated,
    );

    final storage = DatabaseService();
    await storage.save(record);
  }
}