class WrapperState{
  final int currentIndex;

  WrapperState({required this.currentIndex});

  WrapperState copyWith({int? currentIndex}){
    return WrapperState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}