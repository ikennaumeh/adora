import 'package:adora/ui/views/logs/logs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wrapper_state.dart';

final wrapperProvider = NotifierProvider<WrapperNotifier, WrapperState>(WrapperNotifier.new);

class WrapperNotifier extends Notifier<WrapperState>{

  late PageController controller;

  @override
  WrapperState build() {
    controller = PageController(
      initialPage: 0,
    );
    initialize();
    return WrapperState(currentIndex: 0);
  }

  void initialize() {
    controller.addListener(() {
      final page = controller.page!.toInt();

      state = state.copyWith(currentIndex: page);
      if (page == 1) {
        ref.read(logsProvider.notifier).fetchRecords();
      }
    });
  }

  void setPageController(int value) {
    controller.jumpToPage(value);
    state = state.copyWith(currentIndex: value);

    if (value == 1) {
      ref.read(logsProvider.notifier).fetchRecords();
    }
  }
}