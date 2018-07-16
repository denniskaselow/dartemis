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
      : _entities = Bag<Entity>(),
        _deletedEntities = Bag<Entity>(),
        _disabled = Bag<bool>(),
        _identifierPool = _IdentifierPool();

  @override
  void initialize() {}

  Entity _createEntityInstance() {
    Entity entity = _deletedEntities.removeLast();
    entity ??= Entity._(_world, _identifierPool.checkOut());
    _created++;
    entity._uniqueId = _nextUniqueId++;
    return entity;
  }

  @override
  void added(Entity entity) {
    _active++;
    _added++;
    _entities[entity.id] = entity;
  }

  @override
  void enabled(Entity entity) {
    _disabled[entity.id] = false;
  }

  @override
  void disabled(Entity entity) {
    _disabled[entity.id] = true;
  }

  @override
  void deleted(Entity entity) {
    _entities[entity.id] = null;

    _disabled[entity.id] = false;

    _deletedEntities.add(entity);

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

  _IdentifierPool() : _ids = Bag<int>();

  int checkOut() {
    if (_ids.size > 0) {
      return _ids.removeLast();
    }
    return _nextAvailableId++;
  }

  void checkIn(int id) => _ids.add(id);
}
