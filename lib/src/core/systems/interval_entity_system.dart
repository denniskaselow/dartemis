part of '../../../dartemis.dart';

/// A system that processes entities at a interval in milliseconds.
/// A typical usage would be a collision system or physics system.
abstract class IntervalEntitySystem extends EntitySystem {
  double _acc = 0;
  double _intervalDelta = 0;

  /// The interval in which the system will be processed.
  final double interval;

  /// Create an [IntervalEntitySystem] with the specified [interval] and
  /// [aspect].
  IntervalEntitySystem(
    this.interval,
    super.aspect, {
    super.group,
    super.passive,
  });

  /// Returns the accumulated delta since the system was last invoked.
  @override
  double get delta => _intervalDelta;

  @override
  @visibleForOverriding
  bool checkProcessing() {
    _acc += world.delta;
    _intervalDelta += world.delta;
    if (_acc >= interval) {
      _acc -= interval;
      return true;
    }
    return false;
  }

  /// Resets the accumulated delta to 0.
  ///
  /// Call `super.end()` if you overwrite this function.
  @override
  @visibleForOverriding
  void end() {
    _intervalDelta = 0;
  }
}
