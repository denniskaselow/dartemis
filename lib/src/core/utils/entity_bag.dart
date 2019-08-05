part of dartemis;

/// A [Bag] that uses a [BitSet] to manage entities. Results in faster
/// removement of entities.
// ignore: prefer_mixin
class EntityBag with IterableMixin<int> {
  BitSet _entities;

  /// Creates an [EntityBag].
  EntityBag() : _entities = BitSet(32);

  /// Add a new [element]. If the element already exists, nothing changes.
  void add(int element) {
    if (element >= _entities.length) {
      _entities = BitSet.fromBitSet(_entities, length: element);
    }
    _entities[element] = true;
  }

  /// Removes [element]. Returns `true` if there was an element and `false`
  /// otherwise.
  bool remove(int element) {
    final result = _entities[element];
    _entities[element] = false;
    return result;
  }

  @override
  bool contains(covariant int element) => _entities[element];

  @override
  int get length => _entities.cardinality;

  /// Removes all entites.
  void clear() => _entities.clearAll();

  @override
  Iterator<int> get iterator => _entities.toIntValues().iterator;
}
