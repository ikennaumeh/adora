/// Represents the app lifecycle state that produced a location record.
///
/// This is stored alongside every [LocationRecord] so entries in the
/// logs screen can be traced back to the exact state the app was in
/// when the location was captured:
///
/// - [foreground] — app was open and active, captured via [geolocator]
/// - [background] — app was minimised, captured via the [BackgroundLocationService] callback
/// - [terminated] — app was fully killed, captured via the headless task in [background_task.dart]
enum LocationSource {
  foreground,
  background,
  terminated,
}