import 'dart:convert';
import 'package:adora/models/location_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dbServiceProvider = Provider((_) => DatabaseService());

/// Service responsible for all local data persistence.
final class DatabaseService {
  static const _key = 'locations';
  static const _bgTrackingState = 'background_tracking';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Saves a [LocationRecord] to local storage.
  ///
  /// Records are stored as a JSON-encoded string list, with each entry
  /// being one serialized [LocationRecord]. New records are appended
  /// to the existing list.
  Future<void> save(LocationRecord record) async {
    SharedPreferences prefs = await _instance;

    final existing = prefs.getStringList(_key) ?? [];

    existing.add(jsonEncode(record.toJson()));

    await prefs.setStringList(_key, existing);
  }

  /// Fetches all saved location records from local storage.
  ///
  /// Returns an empty list if no records have been saved yet.
  /// Records are returned in insertion order (oldest first).
  Future<List<LocationRecord>> fetchRecords() async {
    SharedPreferences prefs = await _instance;

    final data = prefs.getStringList(_key) ?? [];

    return data
        .map((e) => LocationRecord.fromJson(jsonDecode(e)))
        .toList();
  }

  /// Deletes all saved location records from local storage.
  /// Useful for resetting state during testing.
  Future<void> clear() async {
    SharedPreferences prefs = await _instance;
    await prefs.remove(_key);
  }

  /// Persists the background tracking toggle state.
  ///
  /// Called whenever the user enables or disables background tracking
  /// so the toggle state can be restored on the next app launch.
  void setTrackingState(bool value) async {
    SharedPreferences prefs = await _instance;
    await prefs.setBool(_bgTrackingState, value);
  }

  /// Returns the persisted background tracking toggle state.
  ///
  /// Defaults to false if no value has been saved yet — i.e. on first
  /// app launch, background tracking is off by default.
  Future<bool> getTrackingState() async {
    SharedPreferences prefs = await _instance;
    return prefs.getBool(_bgTrackingState) ?? false;
  }
}