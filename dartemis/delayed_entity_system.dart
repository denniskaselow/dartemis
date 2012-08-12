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

  void processEntities(ImmutableBag<Entity> entities) {
    processEntitiesWithAccDelta(entities, _acc);
    stop();
  }

  bool checkProcessing() {
    if(_running) {
      _acc += world.delta;

      if(_acc >= _delay) {
        return true;
      }
    }
    return false;
  }

  /**
   * The readonly bag of [entities] to process with [accumulatedDelta].
   */
  abstract void processEntitiesWithAccDelta(ImmutableBag<Entity> entities, int accumulatedDelta);

  /**
   * Start processing of entities after a certain [delay] in milliseconds.
   *
   * Cancels current delayed run and starts a new one.
   */
  void startDelayedRun(int delay) {
    _delay = delay;
    _acc = 0;
    _running = true;
  }

  /**
   * Get the initial [:delay:] as set by [startDelayedRun].
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
   * Return [:true:] if it's counting down, [:false:] if it's not running.
   */
  bool get running() => _running;

  /**
   * Aborts running the system in the future and stops it. Call [delayedRun] to start it again.
   */
  void stop() {
    _running = false;
    _acc = 0;
  }

  /**
   * Run a stopped system again.
   */
  void delayedRun() {
    _running = true;
  }

  Type get type() => const Type('DelayedEntitySystem');

}