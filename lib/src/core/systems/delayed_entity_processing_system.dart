part of dartemis;

/// The purpose of this class is to allow systems to execute at varying
/// intervals.
///
/// An example system would be an ExpirationSystem, that deletes entities after a
/// certain lifetime. Instead of running a system that decrements a timeLeft
/// value for each entity, you can simply use this system to execute in a future
/// at a time of the shortest lived entity, and then reset the system to run at a
/// time in a future at a time of the shortest lived entity, etc.
///
/// Another example system would be an AnimationSystem. You know when you have to
/// animate a certain entity, e.g. in 300 milliseconds. So you can set the system
/// to run in 300 ms to perform the animation.
///
/// This will save CPU cycles in some scenarios.
abstract class DelayedEntityProcessingSystem extends EntitySystem {
  bool _running = false;
  double _delay;
  double _acc = 0.0;

  DelayedEntityProcessingSystem(Aspect aspect) : super(aspect);

  /// Check if the system is counting down towards processing.
  bool get running => _running;

  /// Return the delay until this entity should be processed.
  double getRemainingDelay(Entity enitity);

  /// Process a entity this system is interested in. Substract the
  /// accumulatedDelta from the entities defined delay.
  void processDelta(Entity enitity, double accumulatedDelta);

  void processExpired(Entity enitity);

  @override
  void processEntities(Iterable<Entity> entities) {
    entities.forEach((entity) {
      processDelta(entity, _acc);
      double remaining = getRemainingDelay(entity);
      if (remaining <= 0.0) {
        processExpired(entity);
      } else {
        offerDelay(remaining);
      }
    });
    if (_actives.isEmpty) {
      stop();
    }
    _acc = 0.0;
  }

  @override
  void inserted(Entity enitity) {
    double delay = getRemainingDelay(enitity);
    processDelta(enitity, 0.0 - _acc);
    if (delay > 0.0) {
      offerDelay(delay);
    }
  }

  @override
  bool checkProcessing() {
    if (_running) {
      _acc += world.delta;

      if (_acc >= _delay) {
        return true;
      }
    }
    return false;
  }

  /// Start processing of entities after a certain amount of delta time.
  ///
  /// Cancels current delayed run and starts a new one.
  void restart(double delay) {
    _delay = delay;
    _acc = 0.0;
    _running = true;
  }

  /// Restarts the system only if the delay offered is shorter than the
  /// time that the system is currently scheduled to execute at.
  ///
  /// If the system is already stopped (not running) then the offered
  /// delay will be used to restart the system with no matter its value.
  ///
  /// If the system is already counting down, and the offered delay is
  /// larger than the time remaining, the system will ignore it. If the
  /// offered delay is shorter than the time remaining, the system will
  /// restart itself to run at the offered delay.
  void offerDelay(num delay) {
    var remaining = getRemainingTimeUntilProcessing();
    if (!_running || delay < remaining || remaining == 0) {
      restart(delay);
    }
  }

  /// Get the initial delay that the system was ordered to process entities
  /// after.
  double getInitialTimeDelay() => _delay;

  /// Get the time until the system is scheduled to run at.
  /// Returns zero (0) if the system is not running.
  /// Use isRunning() before checking this value.
  double getRemainingTimeUntilProcessing() {
    if (_running) {
      return _delay - _acc;
    }
    return 0.0;
  }

  /// Stops the system from running, aborts current countdown.
  /// Call offerDelay or restart to run it again.
  void stop() {
    _running = false;
    _acc = 0.0;
  }
}
