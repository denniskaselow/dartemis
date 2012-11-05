part of dartemis;

abstract class ImmutableBag<E> {

    E operator [](int index);

    int get size;

    bool isEmpty();

    /**
     * Applies the function [f] to each element of this collection.
     */
    void forEach(void f(E element));
}
