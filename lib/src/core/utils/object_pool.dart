part of dartemis;

/// Inspired by <http://dartgamedevs.org/blog/2012/11/02/Free-Lists-For-Predictable-Game-Performance/>
/// this class stores objects that are no longer used in the game for later
/// reuse.
class ObjectPool {
  static final Map<Type, Bag<Pooled>> _objectPools = <Type, Bag<Pooled>>{};

  /// Returns a pooled object of [Type] [type]. If there is no object in the pool
  /// it will create a new one using [createPooled].
  static Pooled get(Type type, CreatePooled createPooled) {
    Bag<Pooled> pool = _getPool(type);
    var obj = pool.removeLast();
    return obj ??= createPooled();
  }

  static Bag<Pooled> _getPool(Type type) {
    var pooledObjects = _objectPools[type];
    if (null == pooledObjects) {
      pooledObjects = new Bag();
      _objectPools[type] = pooledObjects;
    }
    return pooledObjects;
  }

  /// Adds a [Pooled] object to the [ObjectPool].
  static void add(Pooled pooled) {
    _objectPools[pooled.runtimeType].add(pooled);
  }

  /// Add a specific [amount] of [Pooled]s for later reuse.
  static void addMany(Type type, CreatePooled createPooled, int amount) {
    Bag<Pooled> pool = _getPool(type);
    for (int i = 0; i < amount; i++) {
      pool.add(createPooled());
    }
  }
}

/// Create a [Pooled] object with a zero argument constructor.
typedef Pooled CreatePooled();

/// Objects of this class can be pooled in the [ObjectPool] for later reuse.
///
/// Should be added as a mixin.
abstract class Pooled {
  /// Creates a new [Pooled] of [Type] [type].
  ///
  /// The instance created with [createPooled] should be created with
  /// a zero-argument contructor because it will only be called once. All fields
  /// of the created object should be set in the calling factory constructor.
  factory Pooled.of(Type type, CreatePooled createPooled) =>
      ObjectPool.get(type, createPooled);

  /// If you need to do some cleanup before this object moves into the Pool of
  /// reusable objects.
  void cleanUp();

  /// Calls the cleanup function and moves this object to the [ObjectPool].
  void moveToPool() {
    cleanUp();
    ObjectPool.add(this);
  }
}
