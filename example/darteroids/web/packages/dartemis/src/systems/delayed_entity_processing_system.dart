part of dartemis;

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
 * Implementation notes:
 * In order to start the system you need to override the inserted(Entity e) method,
 * look up the delay time from that entity and offer it to the system by using the
 * offerDelay(num delay) method.
 * Also, when processing the entities you must also call offerDelay(num delay)
 * for all valid entities.
 */
abstract class DelayedEntityProcessingSystem extends EntitySystem {
  num delay;
  bool running;
  num acc;

  DelayedEntityProcessingSystem(Aspect aspect) : super(aspect);

  /**
   * Return the delay until this entity should be processed.
   */
  num getRemainingDelay(Entity e);

  /**
   * Process a entity this system is interested in. Substract the accumulatedDelta
   * from the entities defined delay.
   */
  void processDelta(Entity e, num accumulatedDelta);

  void processExpired(Entity e);

  void processEntities(ImmutableBag<Entity> entities) {
    entities.forEach((entity) {
      processDelta(entity, acc);
      num remaining = getRemainingDelay(entity);
      if(remaining <= 0) {
        processExpired(entity);
      } else {
        offerDelay(remaining);
      }
    });
    stop();
  }

  void inserted(Entity e) {
    num delay = getRemainingDelay(e);
    if(delay > 0) {
      offerDelay(delay);
    }
  }

  bool checkProcessing() {
    if(running) {
      acc += world.delta;

      if(acc >= delay) {
        return true;
      }
    }
    return false;
  }

  /**
   * Start processing of entities after a certain amount of delta time.
   *
   * Cancels current delayed run and starts a new one.
   */
  void restart(num delay) {
    this.delay = delay;
    this.acc = 0;
    running = true;
  }

  /**
   * Restarts the system only if the delay offered is shorter than the
   * time that the system is currently scheduled to execute at.
   *
   * If the system is already stopped (not running) then the offered
   * delay will be used to restart the system with no matter its value.
   *
   * If the system is already counting down, and the offered delay is
   * larger than the time remaining, the system will ignore it. If the
   * offered delay is shorter than the time remaining, the system will
   * restart itself to run at the offered delay.
   */
  void offerDelay(num delay) {
    if(!running || delay < getRemainingTimeUntilProcessing()) {
      restart(delay);
    }
  }

  /**
   * Get the initial delay that the system was ordered to process entities after.
   */
  num getInitialTimeDelay() {
    return delay;
  }

  /**
   * Get the time until the system is scheduled to run at.
   * Returns zero (0) if the system is not running.
   * Use isRunning() before checking this value.
   */
  num getRemainingTimeUntilProcessing() {
    if(running) {
      return delay-acc;
    }
    return 0;
  }

  /**
   * Check if the system is counting down towards processing.
   */
  bool isRunning() {
    return running;
  }

  /**
   * Stops the system from running, aborts current countdown.
   * Call offerDelay or restart to run it again.
   */
  void stop() {
    this.running = false;
    this.acc = 0;
  }

}
