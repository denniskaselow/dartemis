part of '../../../dartemis.dart';

/// Collection type a bit like List but does not preserve the order of its
/// entities, speedwise it is very good, especially suited for games.
// ignore: prefer_mixin
class Bag<E> with IterableMixin<E> {
  List<E?> _data;
  int _size = 0;

  /// Create a [Bag] with an initial capacity of [capacity].
  Bag({int capacity = 32}) : _data = List<E?>.filled(capacity, null);

  /// Creates a new [Bag] with the elements of [iterable].
  Bag.from(Iterable<E> iterable)
      : _data = iterable.toList(growable: false),
        _size = iterable.length;

  /// Returns the element at the specified [index] in the bag.
  E? operator [](int index) => _data[index];

  /// Returns the number of elements in this bag.
  int get size => _size;

  /// Returns [:true:] if this bag contains no elements.
  @override
  bool get isEmpty => size == 0;

  /// Removes the element at the specified [index] in this bag. Does this by
  /// overwriting with the last element and then removing the last element.
  E? removeAt(int index) {
    // make copy of element to remove so it can be returned
    final o = _data[index];
    // overwrite item to remove with last element
    _data[index] = _data[--_size];
    // null last element, so gc can do its work
    _data[size] = null;

    return o;
  }

  /// Remove and return the last object in the bag.
  E? removeLast() {
    if (_size > 0) {
      final current = _data[--_size];
      _data[size] = null;
      return current;
    }
    return null;
  }

  /// Removes the first occurrence of the specified element from this bag, if
  /// it is present. If the Bag does not contain the element, it is unchanged.
  /// Does this by overwriting with the last element and then removing the last
  /// element.
  /// Returns [:true:] if this list contained the specified [element].
  bool remove(E element) {
    for (var i = 0; i < size; i++) {
      final current = _data[i];

      if (element == current) {
        // overwrite item to remove with last element
        _data[i] = _data[--_size];
        // null last element, so gc can do its work
        _data[size] = null;
        return true;
      }
    }

    return false;
  }

  /// Returns the number of elements the bag can hold without growing.
  int get capacity => _data.length;

  /// Adds the specified [element] to the end of this bag. If needed also
  /// increases the capacity of the bag.
  void add(E element) {
    // is size greater than capacity increase capacity
    if (_size == _data.length) {
      _grow();
    }
    _data[_size++] = element;
  }

  /// Sets [element] at specified [index] in the bag.
  void operator []=(int index, E element) {
    if (index >= _data.length) {
      _growTo(index * 2);
    }
    if (_size <= index) {
      _size = index + 1;
    }
    _data[index] = element;
  }

  void _grow() => _growTo(_calculateNewCapacity(_data.length));

  int _calculateNewCapacity(int requiredLength) =>
      (requiredLength * 3) ~/ 2 + 1;

  void _growTo(int newCapacity) {
    final oldData = _data;
    _data = List<E?>.filled(newCapacity, null)
      ..setRange(0, oldData.length, oldData);
  }

  void _ensureCapacity(int index) {
    if (index >= _data.length) {
      _growTo(index * 2);
    }
  }

  /// Removes all of the elements from this bag. The bag will be empty after
  /// this call returns.
  void clear() {
    // null all elements so gc can clean up
    for (var i = 0; i < _size; i++) {
      _data[i] = null;
    }
    _size = 0;
  }

  /// Add all [items] into this bag.
  void addAll(Bag<E> items) => items.forEach(add);

  /// Returns [:true:] iff the [index] is within the capacity of the underlying
  /// list.
  bool isIndexWithinBounds(int index) => index < capacity;

  @override
  Iterator<E> get iterator => _data.sublist(0, size).cast<E>().iterator;

  @override
  int get length => size;

  @override
  Bag<R> cast<R>() => Bag<R>(capacity: _data.length)
    .._size = _size
    .._data = _data.cast<R>();
}
