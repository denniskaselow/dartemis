part of dartemis;

/// Manages creation and deletion of every [int] and gives access to some
/// basic statistcs.
class EntityManager extends Manager {
  BitSet _entities;
  final Bag<int> _deletedEntities;

  int _active = 0;
  int _added = 0;
  int _created = 0;
  int _deleted = 0;

  final _IdentifierPool _identifierPool;

  EntityManager._internal()
      : _entities = BitSet(32),
        _deletedEntities = Bag<int>(),
        _identifierPool = _IdentifierPool();

  @override
  void initialize() {}

  int _createEntityInstance() {
    final entity = _deletedEntities.removeLast() ?? _identifierPool.checkOut();
    _created++;
    return entity;
  }

  void _add(int entity) {
    _active++;
    _added++;
    if (entity >= _entities.length) {
      _entities = BitSet.fromBitSet(_entities, length: entity + 1);
    }
    _entities[entity] = true;
  }

  void _delete(int entity) {
    if (_entities[entity]) {
      _entities[entity] = false;

      _deletedEntities.add(entity);

      _active--;
      _deleted++;
    }
  }

  /// Check if this entity is active.
  /// Active means the entity is being actively processed.
  bool isActive(int entityId) => _entities[entityId];

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
  final List<int> _ids = [];
  int _nextAvailableId = 0;

  _IdentifierPool();

  int checkOut() {
    if (_ids.isNotEmpty) {
      return _ids.removeLast();
    }
    return _nextAvailableId++;
  }

  void checkIn(int id) => _ids.add(id);
}
