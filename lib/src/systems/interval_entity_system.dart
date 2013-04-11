part of dartemis;

/**
 * A system that processes entities at a interval in milliseconds.
 * A typical usage would be a collision system or physics system.
 */
abstract class IntervalEntitySystem extends EntitySystem {
  num _acc = 0;
  final num _interval;

  IntervalEntitySystem(this._interval, Aspect aspect) : super(aspect);

  bool checkProcessing() {
    _acc += world.delta;
    if(_acc >= _interval) {
      _acc -= _interval;
      return true;
    }
    return false;
  }

}
