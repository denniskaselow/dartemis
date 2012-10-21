part of dartemis;

abstract class EntityObserver {

  abstract void added(Entity e);

  abstract void changed(Entity e);

  abstract void deleted(Entity e);

  abstract void enabled(Entity e);

  abstract void disabled(Entity e);

}
