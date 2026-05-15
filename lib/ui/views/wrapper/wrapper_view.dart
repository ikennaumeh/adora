import 'package:adora/ui/views/live/live_view.dart';
import 'package:adora/ui/views/logs/logs_view.dart';
import 'package:adora/ui/views/wrapper/wrapper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WrapperView extends ConsumerWidget {
  const WrapperView({super.key});

  @override
  Widget build(BuildContext context, ref) {
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
