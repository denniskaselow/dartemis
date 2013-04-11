part of dartemis;

/**
 * A [ReadOnlyBag] offers a read-only view for an underlying [Bag].
 */
class ReadOnlyBag<E> {
  Bag<E> _bag;

  ReadOnlyBag._of(this._bag);

  /**
   * Returns the element at [index].
   */
  E operator [](int index) => _bag[index];

  /**
   * Returns the size of the underlying [Bag].
   */
  int get size => _bag.size;

  /**
   * Returns [:true:] if the underlying [Bag] is empty.
   */
  bool get isEmpty => _bag.isEmpty;

  /**
   * Returns [:true:] if the underlying [Bag] contains the [element].
   */
  bool contains(E element) => _bag.contains(element);

  /**
   * Applies the function [f] to each element the underlying [Bag].
   */
  void forEach(void f(E element)) => _bag.forEach(f);
}


