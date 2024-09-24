part of '../../dartemis.dart';

/// Manages creation and deletion of every [int] and gives access to some
/// basic statistcs.
class EntityManager extends Manager {
  BitSet _entities;
  final Bag<Entity> _deletedEntities;

  int _active = 0;
  int _added = 0;
  int _created = 0;
  int _deleted = 0;

  final _EntityPool _identifierPool;

  EntityManager._internal()
      : _entities = BitSet(32),
        _deletedEntities = Bag<Entity>(),
        _identifierPool = _EntityPool();

  @override
  void initialize() {}

  Entity _createEntityInstance() {
    final entity = _deletedEntities.removeLast() ?? _identifierPool.checkOut();
    _created++;
    return entity;
  }

  void _add(Entity entity) {
    _active++;
    _added++;
    if (entity._id >= _entities.length) {
      _entities = BitSet.fromBitSet(_entities, length: entity._id + 1);
    }
    _entities[entity._id] = true;
  }

  void _delete(Entity entity) {
    if (_entities[entity._id]) {
      _entities[entity._id] = false;

      _deletedEntities.add(entity);

      _active--;
      _deleted++;
    }
  }

  /// Check if this entity is active.
  /// Active means the entity is being actively processed.
  bool isActive(Entity entity) => _entities[entity._id];

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
class _EntityPool {
  final List<Entity> _entities = [];
  int _nextAvailableId = 0;

  _EntityPool();

  Entity checkOut() {
    if (_entities.isNotEmpty) {
      return _entities.removeLast();
    }
    return Entity._(_nextAvailableId++);
  }

  void checkIn(Entity entity) => _entities.add(entity);
}
