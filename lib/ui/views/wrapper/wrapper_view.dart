import 'package:adora/services/background_location_service.dart';
import 'package:adora/ui/views/live/live_view.dart';
import 'package:adora/ui/views/logs/logs_view.dart';
import 'package:adora/ui/views/wrapper/wrapper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WrapperView extends ConsumerStatefulWidget {
  const WrapperView({super.key});

  @override
  ConsumerState<WrapperView> createState() => _WrapperViewState();
}

class _WrapperViewState extends ConsumerState<WrapperView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(bgLocationProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(wrapperProvider.notifier);
    final state = ref.watch(wrapperProvider);

    return Scaffold(
      body: PageView(
        controller: vm.controller,
        children: [
          LiveView(),
          LogsView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.currentIndex,
        onDestinationSelected: vm.setPageController,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.location_on_rounded),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: "Live",
          ),
          NavigationDestination(
            icon: Icon(Icons.notes_outlined),
            selectedIcon: Icon(Icons.notes_outlined),
            label: "Logs",
          ),
        ],
      ),
    );
  }
}
