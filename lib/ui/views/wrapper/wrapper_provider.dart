import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WrapperState{
  final int currentIndex;

  WrapperState({required this.currentIndex});

  WrapperState copyWith({int? currentIndex}){
    return WrapperState(
        currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

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
      state = state.copyWith(currentIndex: controller.page!.toInt());
    });
  }

  void setPageController(int value) {
    controller.jumpToPage(value);
    state = state.copyWith(currentIndex: value);
  }
}