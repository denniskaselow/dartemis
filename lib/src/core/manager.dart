part of dartemis;

/**
 * Manager.
 */
abstract class Manager implements EntityObserver {
  World _world;

  World get world => _world;

  /**
   * Override to implement code that gets executed when managers are
   * initialized.
   */
  void initialize() {}

  void added(Entity e) {}

  void changed(Entity e) {}

  void deleted(Entity e) {}

  void disabled(Entity e) {}

  void enabled(Entity e) {}
}
