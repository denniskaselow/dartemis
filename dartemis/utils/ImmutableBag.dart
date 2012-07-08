#library('dartemis');

interface ImmutableBag<E> {
  
    E operator [](int index);

    int get size();

    bool isEmpty();
  
}
