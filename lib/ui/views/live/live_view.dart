import 'package:adora/enums/location_error.dart';
import 'package:adora/ui/views/live/live_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveView extends ConsumerStatefulWidget {
  const LiveView({super.key});

  @override
  ConsumerState<LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends ConsumerState<LiveView> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin  {
  bool _openedSettings = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.read(liveProvider.notifier).getLiveLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedSettings) {
      _openedSettings = false;
      ref.read(liveProvider.notifier).getLiveLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(liveProvider);
    final vm = ref.read(liveProvider.notifier);

    return Scaffold(
      body: Builder(
        builder: (context){
          if(state.isLoading){
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if(state.hasError){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    switch (state.errorType) {
                      LocationError.permissionDenied => "Location permission was denied.",
                      LocationError.permissionPermanentlyDenied => "Location access is disabled. Please enable location permission in settings.",
                      LocationError.serviceDisabled => "Location services are turned off.",
                      _ => "Error fetching location",
                    },
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: (){
                      if (state.errorType == LocationError.permissionPermanentlyDenied) {
                        _openedSettings = true;
                        vm.openAppSettings();
                      } else if (state.errorType == LocationError.serviceDisabled) {
                        _openedSettings = true;
                        vm.openLocationSettings();
                      } else {
                        vm.getLiveLocation();
                      }
                    },
                    child: Text(
                      state.errorType == LocationError.permissionPermanentlyDenied
                          ? "Open Settings"
                          : state.errorType == LocationError.serviceDisabled
                          ? "Enable Location"
                          : "Try Again",
                    ),
                  ),

                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Current Location",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Longitude: ${state.currentPosition?.longitude}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "Latitude: ${state.currentPosition?.latitude}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: vm.getLiveLocation,
                    child: Text(
                        "Reload"
                    ),
                  ),

                  SizedBox(height: 10,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Background Tracking",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              state.isBackgroundTracking ? "Active 🟢" : "Inactive 🔴",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        state.isTrackingLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                        )
                        : ElevatedButton(
                            onPressed: vm.toggleBackgroundTracking,
                            child: Text(
                                state.isBackgroundTracking ? "Stop" : "Start"
                            ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }
      ),
    );
  }
}
