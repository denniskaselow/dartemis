part of '../../../dartemis.dart';

/// A system that processes entities at a interval in milliseconds.
/// A typical usage would be a collision system or physics system.
abstract class IntervalEntitySystem extends EntitySystem {
  double _acc = 0;
  double _intervalDelta = 0;
  final double _interval;

  /// Create an [IntervalEntitySystem] with the specified interval and [aspect].
  IntervalEntitySystem(this._interval, Aspect aspect) : super(aspect);

  /// Returns the accumulated delta since the system was last invoked.
  @override
  double get delta => _intervalDelta;

  @override
  bool checkProcessing() {
    _acc += world.delta;
    _intervalDelta += world.delta;
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
    _intervalDelta = 0;
  }
}
