import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';

import 'logs_provider.dart';

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logsProvider.notifier).fetchRecords();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(logsProvider.notifier).fetchRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(logsProvider);
    final vm = ref.read(logsProvider.notifier);

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error fetching logs",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: vm.fetchRecords,
                    child: const Text("Try again"),
                  ),
                ],
              ),
            );
          } else if (state.records.isEmpty) {
            return const Center(
              child: Text("No location logs yet"),
            );
          } else {
            return ListView.builder(
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records.elementAt(index);
                return ListTile(
                  leading: const Icon(Icons.location_on_rounded),
                  title: Text("Lat: ${record.latitude}, Lng: ${record.longitude}"),
                  subtitle: Text(Jiffy.parseFromDateTime(record.timestamp).format(pattern: "do MMM yyyy h:mm a")),
                  trailing: Text(
                    record.source.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
