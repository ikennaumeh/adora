import 'package:adora/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logs_state.dart';


final logsProvider = NotifierProvider<LogsNotifier, LogsState>(LogsNotifier.new);

class LogsNotifier extends Notifier<LogsState> {

  @override
  LogsState build() {
    return LogsState(
      records: [],
      isLoading: false,
      hasError: false,
    );
  }

  /// Fetches all saved location records from local storage and updates state.
  Future<void> fetchRecords() async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final records = await ref.read(dbServiceProvider).fetchRecords();

      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }
}
