part of dartemis;

abstract class EntityObserver {

  void added(Entity e);

  void changed(Entity e);

  void deleted(Entity e);

  void enabled(Entity e);

  void disabled(Entity e);

}
