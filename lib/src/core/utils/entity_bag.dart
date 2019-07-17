part of dartemis;

/// A [Bag] that uses a [BitSet] to manage entities. Results in faster
/// removement of entities.
class EntityBag extends Bag<Entity> {
  BitSet _entities;
  bool _dirty = false;

  /// Creates an [EntityBag] with an initial capacity of [capacity].
  EntityBag({int capacity = 32})
      : _entities = BitSet(capacity),
        super(capacity: capacity);

  @override
  void add(Entity element) {
    if (_dirty) {
      _refresh();
    }
    if (element.id >= _entities.length) {
      _entities = BitSet.fromBitSet(_entities,
          length: _calculateNewCapacity(element.id));
    }
    if (!_entities[element.id]) {
      _entities[element.id] = true;
      super.add(element);
    }
  }

  @override
  bool remove(Entity element) {
    final result = _entities[element.id];
    _removeFromBitSet(element);
    return result;
  }

  @override
  Entity removeAt(int index) {
    final element = super.removeAt(index);
    _removeFromBitSet(element);
    return element;
  }

  @override
  Entity removeLast() {
    final element = super.removeLast();
    _removeFromBitSet(element);
    return element;
  }

  void _removeFromBitSet(Entity entity) {
    _entities[entity.id] = false;
    _dirty = true;
  }

  @override
  bool contains(Object element) => element is Entity && _entities[element.id];

  @override
  int get size {
    if (_dirty) {
      _refresh();
    }
    return _size;
  }

  @override
  void clear() {
    _entities.clearAll();
    _dirty = true;
  }

  @override
  Iterator<Entity> get iterator {
    if (_dirty) {
      _refresh();
    }
    return _data.take(size).iterator;
  }

  void _refresh() {
    _size = _entities.cardinality;
    final tmp = List<Entity>(_size);
    if (_size > 0) {
      var index = 0;
      for (final entity in _data
          .takeWhile((_) => index < _size)
          .where((entity) => _entities[entity.id])) {
        tmp[index++] = entity;
      }
    }
    _data = tmp;
    _dirty = false;
  }
}
