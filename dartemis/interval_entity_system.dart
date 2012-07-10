/**
 * A system that processes entities at a interval in milliseconds.
 * A typical usage would be a collision system or physics system.
 *
 * @author Arni Arent
 *
 */
abstract class IntervalEntitySystem extends EntitySystem {
  int _acc;
  int _interval;

  IntervalEntitySystem(this._interval, List<Type> types) : super(types);

  bool _checkProcessing() {
    _acc += _world.delta;
    if(_acc >= _interval) {
      _acc -= _interval;
      return true;
    }
    return false;
  }

  Type get type() => const Type('IntervalEntitySystem');
}
