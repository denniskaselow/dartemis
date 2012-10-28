part of dartemis;

/**
 * Manager.
 *
 * @author Arni Arent
 *
 */
abstract class Manager implements EntityObserver {
  World _world;

  void initialize();

  void added(Entity e) {}

  void changed(Entity e) {}

  void deleted(Entity e) {}

  void disabled(Entity e) {}

  void enabled(Entity e) {}
}
