part of dartemis;

/**
 * Collection type a bit like List but does not preserve the order of its
 * entities, speedwise it is very good, especially suited for games.
 */
class Bag<E> {
  List _data;
  int _size = 0;
  ReadOnlyBag<E> _readOnly;

  Bag({int capacity: 16}) : _data = new List(capacity) {
    _readOnly = new ReadOnlyBag._of(this);
  }

  /**
   * Creates a new [Bag] with the elements of [iterable].
   */
  Bag.from(Iterable<E> iterable) : _data = iterable.toList(growable: false),
                                   _size = iterable.length {
    _readOnly = new ReadOnlyBag._of(this);
  }

  /**
   * Returns the element at the specified [index] in the bag.
   */
  E operator [](int index) => _data[index];

  /**
   * Returns the number of elements in this bag.
   */
  int get size => _size;

  /**
   * Returns a read only view for this bag.
   */
  ReadOnlyBag get readOnly => _readOnly;

  /**
   * Returns [:true:] if this list contains no elements.
   */
  bool get isEmpty => _size == 0;

  /**
   * Applies the function [f] to each element of this collection.
   *
   * Do not pass functions that add or remove elements because the order of
   * elements is not preserved and such a function could lead to unexpected
   * results.
   */
  void forEach(void f(E element)) {
    for (int i = 0; i < _size; i++) {
      f(_data[i]);
    }
  }

  /**
   * Removes the element at the specified [index] in this bag. Does this by
   * overwriting with the last element and then removing the last element.
   */
  E removeAt(int index) {
    // make copy of element to remove so it can be returned
    var o = _data[index];
    // overwrite item to remove with last element
    _data[index] = _data[--_size];
    // null last element, so gc can do its work
    _data[_size] = null;

    return o;
  }

  /**
   * Remove and return the last object in the bag.
   */
  E removeLast() {
    if (_size > 0) {
      E current = _data[--_size];
      _data[_size] = null;
      return current;
    }
    return null;
  }

  /**
   * Removes the first occurrence of the specified element from this bag, if
   * it is present. If the Bag does not contain the element, it is unchanged.
   * Does this by overwriting with the last element and then removing the last
   * element.
   * Returns [:true:] if this list contained the specified [element].
   */
  bool remove(E element) {
    for (int i = 0; i < _size; i++) {
      E current = _data[i];

      if (element == current) {
        // overwrite item to remove with last element
        _data[i] = _data[--_size];
        // null last element, so gc can do its work
        _data[_size] = null;
        return true;
      }
    }

    return false;
  }

  /**
   * Returns [:true:] if this bag contains the [element].
   */
  bool contains(E element) {
    for(int i = 0; _size > i; i++) {
      if(element == _data[i]) {
        return true;
      }
    }
    return false;
  }

  /**
   * Removes from this Bag all of its elements that are contained in the
   * specified [bag].
   *
   * Returns [:true:] if this Bag changed as a result of the call
   */
  bool removeAll(Bag<E> bag) {
    bool modified = false;

    for (int i = 0; i < bag.size; i++) {
      E o1 = bag[i];

      for (int j = 0; j < size; j++) {
        E o2 = _data[j];

        if (o1 == o2) {
          removeAt(j);
          j--;
          modified = true;
          break;
        }
      }
    }
    return modified;
  }

  /**
   * Returns the number of elements the bag can hold without growing.
   */
  int get capacity => _data.length;

  /**
   * Adds the specified [element] to the end of this bag. If needed also
   * increases the capacity of the bag.
   */
  void add(E element) {
    // is size greater than capacity increase capacity
    if (_size == _data.length) {
      _grow();
    }
    _data[_size++] = element;
  }

  /**
   * Sets [element] at specified [index] in the bag.
   */
  void operator []=(int index, E element) {
    if(index >= _data.length) {
      _growTo(index*2);
    }
    _size = index+1;
    _data[index] = element;
  }

  void _grow() {
    int newCapacity = ((_data.length * 3) / 2 + 1).toInt();
    _growTo(newCapacity);
  }

  void _growTo(int newCapacity) {
    List<E> oldData = _data;
    _data = new List<E>(newCapacity);
    _data.setRange(0, oldData.length, oldData);
  }

  void _ensureCapacity(int index) {
    if (index >= _data.length) {
      _growTo(index*2);
    }
  }

  /**
   * Removes all of the elements from this bag. The bag will be empty after
   * this call returns.
   */
  void clear() {
    // null all elements so gc can clean up
    for (int i = 0; i < _size; i++) {
      _data[i] = null;
    }
    _size = 0;
  }

  /**
   * Add all [items] into this bag.
   */
  void addAll(Bag<E> items) {
    for(int i = 0; items.size > i; i++) {
      add(items[i]);
    }
  }

  bool isIndexWithinBounds(int index) => index < capacity;
  String toString() => "[${_data.join(',')}]";
}
