/**
 * A system that processes entities at a interval in milliseconds.
 * A typical usage would be a collision system or physics system.
 *
 * @author Arni Arent
 *
 */
abstract class IntervalEntitySystem extends EntitySystem {
  int _acc;
  final int interval;

  IntervalEntitySystem(this.interval, [List<String> types]) : super(types);

  bool checkProcessing() {
    _acc += world.delta;
    if(_acc >= interval) {
      _acc -= interval;
      return true;
    }
    return false;
  }

}
