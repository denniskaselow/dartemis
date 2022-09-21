part of '../../../dartemis.dart';

/// A system that processes entities at a interval in milliseconds.
/// A typical usage would be a collision system or physics system.
abstract class IntervalEntitySystem extends EntitySystem {
  num _acc = 0;
  num _delta = 0;
  final num _interval;

  /// Create an [IntervalEntitySystem] with the specified interval and [aspect].
  IntervalEntitySystem(this._interval, Aspect aspect) : super(aspect);

  /// Returns the accumulated delta since the system was last invoked.
  num get delta => _delta;

  @override
  bool checkProcessing() {
    _acc += world.delta;
    _delta += world.delta;
    if (_acc >= _interval) {
      _acc -= _interval;
      return true;
    }
    return false;
  }

  /// Resets the accumulated delta to 0.
  ///
  /// Call `super.end()` if you overwrite this function.
  @override
  void end() {
    _delta = 0;
  }
}
