import 'package:adora/services/location_service.dart';
import 'package:adora/ui/enums/location_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final class LiveState{
  final Position? currentPosition;
  final bool isLoading, hasError;
  final LocationError? errorType;

  LiveState({
    required this.currentPosition,
    required this.isLoading,
    required this.hasError,
    required this.errorType,
  });

  LiveState copyWith({
    Position? currentPosition,
    bool? isLoading,
    bool? hasError,
    LocationError? errorType,
  }) {
    return LiveState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorType: errorType ?? this.errorType,
    );
  }
}

final liveProvider = NotifierProvider<LiveNotifier, LiveState>(LiveNotifier.new);

class LiveNotifier extends Notifier<LiveState>{
  late final LocationService locationService;

  @override
  LiveState build() {
    locationService = ref.read(locationProvider);
    return LiveState(
      currentPosition: null,
      isLoading: false,
      hasError: false,
      errorType: null,
    );
  }

  Future<void> openAppSettings() async {
    await locationService.openAppSettings;
  }

  Future<void> openLocationSettings() async {
    await locationService.openLocationSettings;
  }

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

}