part of dartemis;

/**
 * Inspired by <http://dartgamedevs.org/blog/2012/11/02/Free-Lists-For-Predictable-Game-Performance/>
 * this class stores objects that are no longer used in the game for later
 * reuse.
 */
class ObjectPool {

  static Map<Type, Bag<Poolable>> _objectPools = new Map<Type, Bag<Poolable>>();

  /**
   * Returns a pooled object of [Type] [type]. If there is no object in the pool
   * it will create a new one using [createPoolable].
   */
  static Poolable get(Type type, CreatePoolable createPoolable) {
    Bag<Poolable> pool = _getPool(type);
    var obj = pool.removeLast();
    if (null == obj) {
      obj = createPoolable();
    }
    return obj;
  }

  static Bag<Poolable> _getPool(Type type) {
    var pooledObjects = _objectPools[type];
    if (null == pooledObjects) {
      pooledObjects = new Bag();
      _objectPools[type] = pooledObjects;
    }
    return pooledObjects;
  }

  /**
   * Adds a [poolable] to the [ObjectPool].
   */
  static void add(Poolable poolable) {
    _objectPools[poolable.runtimeType].add(poolable);
  }

  /**
   * Add a specific [amount] of [Poolable]s for later reuse.
   */
  static void addMany(Type type, CreatePoolable createPoolable, int amount) {
    Bag<Poolable> pool = _getPool(type);
    for (int i = 0; i < amount; i++) {
      pool.add(createPoolable());
    }
  }
}

/// Create a [Poolable] object with a zero argument constructor.
typedef Poolable CreatePoolable();

/**
 * Objects of this class can be pooled in the [ObjectPool] for later reuse.
 *
 * Should be added as a mixin.
 */
abstract class Poolable {

  /**
   * Creates a new [Poolable] of [Type] [type].
   *
   * The instance created with [createPoolable] should be created with
   * a zero-argument contructor because it will only be called once. All fields
   * of the created object should be set in the calling factory constructor.
   */
  factory Poolable.of(Type type, CreatePoolable createPoolable) {
    return ObjectPool.get(type, createPoolable);
  }
  /**
   * If you need to do some cleanup before this object moves into the Pool of
   * reusable objects.
   */
  void cleanUp();

  /**
   * Calls the cleanup function and moves this object to the [ObjectPool].
   */
  void moveToPool() {
    cleanUp();
    ObjectPool.add(this);
  }
}
