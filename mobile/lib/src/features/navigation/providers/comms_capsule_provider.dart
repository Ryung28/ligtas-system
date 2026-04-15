import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comms_capsule_provider.g.dart';

@riverpod
class CommsCapsulePosition extends _$CommsCapsulePosition {
  @override
  double build() {
    // Initial Y position: approximately 60% down the screen
    return 0.6; 
  }

  void updatePosition(double dy, double screenHeight) {
    // Convert absolute dy to a percentage to stay responsive
    state = (dy / screenHeight).clamp(0.1, 0.8);
  }
}

@riverpod
class CommsDrawerState extends _$CommsDrawerState {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }

  void close() {
    state = false;
  }

  void open() {
    state = true;
  }
}
