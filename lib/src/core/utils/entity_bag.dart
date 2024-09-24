part of '../../../dartemis.dart';

/// A [Bag] that uses a [BitSet] to manage entities. Results in faster
/// removal of entities.
class EntityBag with Iterable<Entity> {
  BitSet _entities;

  /// Creates an [EntityBag].
  EntityBag() : _entities = BitSet(32);

  /// Add a new [entity]. If the entity already exists, nothing changes.
  void add(Entity entity) {
    if (entity._id >= _entities.length) {
      _entities = BitSet.fromBitSet(_entities, length: entity._id + 1);
    }
    _entities[entity._id] = true;
  }

  /// Removes [entity]. Returns `true` if there was an element and `false`
  /// otherwise.
  bool remove(Entity entity) {
    final result = _entities[entity._id];
    _entities[entity._id] = false;
    return result;
  }

  @override
  bool contains(covariant Entity element) => _entities[element._id];

  @override
  int get length => _entities.cardinality;

  /// Removes all entites.
  void clear() => _entities.clearAll();

  @override
  Iterator<Entity> get iterator =>
      _entities.toIntValues().map(Entity._).iterator;
}
