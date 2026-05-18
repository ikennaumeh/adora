import 'package:adora/enums/location_source.dart';

/// Represents a single location entry captured by the app.
///
/// Each record stores the coordinates, timestamp, and the source that
/// produced it — making it possible to distinguish between entries
/// captured in the foreground, background, or terminated state.
class LocationRecord {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  /// Indicates which app lifecycle state produced this record.
  /// See [LocationSource] for possible values.
  final LocationSource source;

  LocationRecord({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.source,
  });

  /// Serializes this record to a JSON map for storage in [SharedPreferences].
  ///
  /// [timestamp] is stored as an ISO 8601 string for reliable parsing.
  /// [source] is stored as its enum name string via [LocationSource.name].
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'source': source.name,
    };
  }

  /// Deserializes a [LocationRecord] from a JSON map retrieved from storage.
  ///
  /// [LocationSource.values.byName] maps the stored string back to its
  /// corresponding enum value.
  factory LocationRecord.fromJson(Map<String, dynamic> json) {
    return LocationRecord(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
      source: LocationSource.values.byName(json['source']),
    );
  }
}