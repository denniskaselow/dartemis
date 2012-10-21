part of dartemis;

class EntityManager extends Manager {

  Bag<Entity> _entities;
  Bag<bool> _disabled;

  int _active = 0;
  int _added = 0;
  int _created = 0;
  int _deleted = 0;

  _IdentifierPool _identifierPool;

  EntityManager() : _entities = new Bag<Entity>(),
                    _disabled = new Bag<bool>(),
                    _identifierPool = new _IdentifierPool();

  void initialize() {}

  Entity _createEntityInstance() {
    Entity e = new Entity(_world, _identifierPool.checkOut());
    _created++;
    return e;
  }

  void added(Entity e) {
    _active++;
    _added++;
    _entities[e.id] = e;
  }

  void enabled(Entity e) {
    _disabled[e.id] = false;
  }

  void disabled(Entity e) {
    _disabled[e.id] = true;
  }

  void deleted(Entity e) {
    _entities[e.id] = null;

    _disabled[e.id] = false;

    _identifierPool.checkIn(e.id);

    _active--;
    _deleted++;
  }


  /**
   * Check if this entity is active.
   * Active means the entity is being actively processed.
   */
  bool isActive(int entityId) {
    return _entities[entityId] != null;
  }

  /**
   * Check if the specified entityId is enabled.
   */
  bool isEnabled(int entityId) {
    return !_disabled[entityId];
  }

  /**
   * Get a entity with this id.
   */
  Entity _getEntity(int entityId) {
    return _entities[entityId];
  }

  /**
   * Get how many entities are active in this world.
   */
  int get activeEntityCount => _active;

  /**
   * Get how many entities have been created in the world since start.
   * Note: A created entity may not have been added to the world, thus
   * created count is always equal or larger than added count.
   */
  int get totalCreated => _created;

  /**
   * Get how many entities have been added to the world since start.
   */
  int get totalAdded => _added;

  /**
   * Get how many entities have been deleted from the world since start.
   */
  int get totalDeleted => _deleted;
}

/**
 * Used only internally to generate distinct ids for entities and reuse them.
 */
class _IdentifierPool {

  Bag<int> _ids;
  int _nextAvailableId = 0;

  _IdentifierPool() : _ids = new Bag<int>();

  int checkOut() {
    if(_ids.size > 0) {
      return _ids.removeLast();
    }
    return _nextAvailableId++;
  }

  void checkIn(int id) {
    _ids.add(id);
  }
}
