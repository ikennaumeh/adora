import 'package:adora/models/location_record.dart';

final class LogsState {
  final List<LocationRecord> records;
  final bool isLoading, hasError;

  LogsState({
    required this.records,
    required this.isLoading,
    required this.hasError,
  });

  LogsState copyWith({
    List<LocationRecord>? records,
    bool? isLoading,
    bool? hasError,
  }) {
    return LogsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}