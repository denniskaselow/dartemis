/**
 * The purpose of this class is to allow systems to execute at varying intervals.
 *
 * An example system would be an ExpirationSystem, that deletes entities after a certain
 * lifetime. Instead of running a system that decrements a timeLeft value for each
 * entity, you can simply use this system to execute in a future at a time of the shortest
 * lived entity, and then reset the system to run at a time in a future at a time of the
 * shortest lived entity, etc.
 *
 * Another example system would be an AnimationSystem. You know when you have to animate
 * a certain entity, e.g. in 300 milliseconds. So you can set the system to run in 300 ms.
 * to perform the animation.
 *
 * This will save CPU cycles in some scenarios.
 *
 * Make sure you detect all circumstances that change. E.g. if you create a new entity you
 * should find out if you need to run the system sooner than scheduled, or when deleting
 * a entity, maybe something changed and you need to recalculate when to run. Usually this
 * applies to when entities are created, deleted, changed.
 *
 * This class offers public methods allowing external systems to use it.
 *
 * @author Arni Arent
 *
 */
abstract class DelayedEntitySystem extends EntitySystem {
  int _delay;
  bool _running;
  int _acc;

  DelayedEntitySystem([List<Type> types]) : super(types);

  void _processEntities(ImmutableBag<Entity> entities) {
    _processEntitiesWithAccDelta(entities, _acc);
    stop();
  }

  bool _checkProcessing() {
    if(_running) {
      _acc += _world.delta;

      if(_acc >= _delay) {
        return true;
      }
    }
    return false;
  }

  /**
   * The entities to process with _accumulated delta.
   * @param entities read-only bag of entities.
   */
  abstract void _processEntitiesWithAccDelta(ImmutableBag<Entity> entities, int _accumulatedDelta);

  /**
   * Start processing of entities after a certain amount of milliseconds.
   *
   * Cancels current _delayed run and starts a new one.
   *
   * @param _delay time _delay in milliseconds until processing starts.
   */
  void startDelayedRun(int delay) {
    _delay = delay;
    _acc = 0;
    _running = true;
  }

  /**
   * Get the initial _delay that the system was ordered to process entities after.
   *
   * @return the originally set _delay.
   */
  int get initialTimeDelay() => _delay;

  int get remainingTimeUntilProcessing() {
    if(_running) {
      return _delay - _acc;
    }
    return 0;
  }

  /**
   * Check if the system is counting down towards processing.
   *
   * @return true if it's counting down, false if it's not _running.
   */
  bool get running() => _running;

  /**
   * Aborts _running the system in the future and stops it. Call delayedRun() to start it again.
   */
  void stop() {
    _running = false;
    _acc = 0;
  }

}