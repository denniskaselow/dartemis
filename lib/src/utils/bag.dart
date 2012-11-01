part of dartemis;

/**
 * Collection type a bit like List but does not preserve the order of its
 * entities, speedwise it is very good, especially suited for games.
 */
class Bag<E> implements ImmutableBag<E> {
  List _data;
  int _size = 0;

  Bag({int capacity: 16}) {
    _data = new List(capacity);
  }

  /**
   * Returns the element at the specified [index] in the bag.
   */
  E operator [](int index) {
    return _data[index];
  }

  /**
   * Returns the number of elements in this bag.
   */
  int get size {
    return _size;
  }

  /**
   * Returns [:true:] if this list contains no elements.
   */
  bool isEmpty() {
    return _size == 0;
  }

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
    var o = _data[index]; // make copy of element to remove so it can be
    // returned
    _data[index] = _data[--_size]; // overwrite item to remove with last
    // element
    _data[_size] = null; // null last element, so gc can do its work

    return o;
  }

  /**
   * Remove and return the last object in the bag.
   */
  E removeLast() {
    if(size > 0) {
      Object o = _data[--_size];
      _data[_size] = null;
      return o;
    }
    return null;
  }

  /**
   * Removes the first occurrence of the specified element from this bag, if
   * it is present. If the Bag does not contain the element, it is unchanged.
   * Does this by overwriting with the last element and then removing the last
   * element.
   * Returns [:true:] if this list contained the specified element.
   */
  bool remove(E o) {
    for (int i = 0; i < _size; i++) {
      Object o1 = _data[i];

      if (o == o1) {
        _data[i] = _data[--_size]; // overwrite item to remove with last
        // element
        _data[_size] = null; // null last element, so gc can do its work
        return true;
      }
    }

    return false;
  }


  /**
   * Check if this bag contains this element.
   *
   * @param o
   * @return
   */
  bool contains(E o) {
    for(int i = 0; _size > i; i++) {
      if(o == _data[i]) {
        return true;
      }
    }
    return false;
  }



  /**
   * Removes from this Bag all of its elements that are contained in the
   * specified [bag].
   *
   * Retur s [:true:] if this Bag changed as a result of the call
   */
  bool removeAll(Bag<E> bag) {
    bool modified = false;

    for (int i = 0; i < bag.size; i++) {
      Object o1 = bag[i];

      for (int j = 0; j < size; j++) {
        var o2 = _data[j];

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
  int get capacity {
    return _data.length;
  }

  /**
   * Adds the specified element [o] to the end of this bag. if needed also
   * increases the capacity of the bag.
   */
  void add(E o) {
    // is size greater than capacity increase capacity
    if (_size == _data.length) {
      _grow();
    }

    _data[_size++] = o;
  }

  /**
   * Set element [o] at specified [index] in the bag.
   */
  void operator []=(int index, E o) {
    if(index >= _data.length) {
      _growTo(index*2);
      _size = index+1;
    } else if(index >= _size) {
      _size = index+1;
    }
    _data[index] = o;
  }

  void _grow() {
    int newCapacity = ((_data.length * 3) / 2 + 1).toInt();
    _growTo(newCapacity);
  }

  void _growTo(int newCapacity) {
    List oldData = _data;
    _data = new List(newCapacity);
    Arrays.copy(oldData, 0, _data, 0, oldData.length);
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

  String toString() {
    return Collections.collectionToString(_data);
  }

  bool isIndexWithinBounds(int index) {
    return index < capacity;
  }
}
