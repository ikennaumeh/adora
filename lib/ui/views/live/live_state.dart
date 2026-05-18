import 'package:adora/enums/location_error.dart';
import 'package:geolocator/geolocator.dart';

final class LiveState{
  final Position? currentPosition;
  final bool isLoading, hasError;
  final LocationError? errorType;
  final bool isBackgroundTracking;
  final bool isTrackingLoading;

  LiveState({
    required this.currentPosition,
    required this.isLoading,
    required this.hasError,
    required this.errorType,
    required this.isBackgroundTracking,
    required this.isTrackingLoading,
  });

  LiveState copyWith({
    Position? currentPosition,
    bool? isLoading,
    bool? hasError,
    LocationError? errorType,
    bool? isBackgroundTracking,
    bool? isTrackingLoading,
  }) {
    return LiveState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorType: errorType ?? this.errorType,
      isBackgroundTracking: isBackgroundTracking ?? this.isBackgroundTracking,
      isTrackingLoading: isTrackingLoading ?? this.isTrackingLoading,
    );
  }
}