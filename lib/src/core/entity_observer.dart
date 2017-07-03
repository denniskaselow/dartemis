part of dartemis;

abstract class EntityObserver {

  void added(Entity entity);

  void changed(Entity entity);

  void deleted(Entity entity);

  void enabled(Entity entity);

  void disabled(Entity entity);

}
