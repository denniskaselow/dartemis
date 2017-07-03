part of dartemis;

class EntityManager extends Manager {

  static int _nextUniqueId = 0;

  Bag<Entity> _entities;
  Bag<Entity> _deletedEntities;
  Bag<bool> _disabled;

  int _active = 0;
  int _added = 0;
  int _created = 0;
  int _deleted = 0;

  _IdentifierPool _identifierPool;

  EntityManager()
      : _entities = new Bag<Entity>(),
        _deletedEntities = new Bag<Entity>(),
        _disabled = new Bag<bool>(),
        _identifierPool = new _IdentifierPool();

  @override
  void initialize() {}

  Entity _createEntityInstance() {
    Entity e = _deletedEntities.removeLast();
    e ??= new Entity._(_world, _identifierPool.checkOut());
    _created++;
    e._uniqueId = _nextUniqueId++;
    return e;
  }

  @override
  void added(Entity e) {
    _active++;
    _added++;
    _entities[e.id] = e;
  }

  @override
  void enabled(Entity e) {
    _disabled[e.id] = false;
  }

  @override
  void disabled(Entity e) {
    _disabled[e.id] = true;
  }

  @override
  void deleted(Entity e) {
    _entities[e.id] = null;

    _disabled[e.id] = false;

    _deletedEntities.add(e);

    _active--;
    _deleted++;
  }


  /// Check if this entity is active.
  /// Active means the entity is being actively processed.
  bool isActive(int entityId) => _entities[entityId] != null;

  /// Check if the specified entityId is enabled.
  bool isEnabled(int entityId) {
    if (_disabled.size > entityId) {
      return _disabled[entityId] != true;
    }
    return true;
  }

  /// Get a entity with this id.
  Entity _getEntity(int entityId) => _entities[entityId];

  /// Get how many entities are active in this world.
  int get activeEntityCount => _active;

  /// Get how many entities have been created in the world since start.
  /// Note: A created entity may not have been added to the world, thus
  /// created count is always equal or larger than added count.
  int get totalCreated => _created;

  /// Get how many entities have been added to the world since start.
  int get totalAdded => _added;

  /// Get how many entities have been deleted from the world since start.
  int get totalDeleted => _deleted;
}

/// Used only internally to generate distinct ids for entities and reuse them.
class _IdentifierPool {

  Bag<int> _ids;
  int _nextAvailableId = 0;

  _IdentifierPool(): _ids = new Bag<int>();

  int checkOut() {
    if (_ids.size > 0) {
      return _ids.removeLast();
    }
    return _nextAvailableId++;
  }

  void checkIn(int id) => _ids.add(id);
}
