part of dartemis;

/**
 * A system that processes entities at a interval in milliseconds.
 * A typical usage would be a collision system or physics system.
 */
abstract class IntervalEntitySystem extends EntitySystem {
  num _acc = 0;
  final num interval;

  IntervalEntitySystem(this.interval, Aspect aspect) : super(aspect);

  bool checkProcessing() {
    _acc += world.delta;
    if(_acc >= interval) {
      _acc -= interval;
      return true;
    }
    return false;
  }

}
