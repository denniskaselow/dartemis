part of dartemis;

/// Inspired by <https://web.archive.org/web/20121106084117/http://www.dartgamedevs.org/2012/11/free-lists-for-predictable-game.html>
/// this class stores objects that are no longer used in the game for later
/// reuse.
class ObjectPool {
  static final Map<Type, Bag<Pooled>> _objectPools = <Type, Bag<Pooled>>{};

  /// Returns a pooled object of type [T]. If there is no object in the pool
  /// it will create a new one using [createPooled].
  static T get<T extends Pooled>(CreatePooled<T> createPooled) {
    final pool = _getPool<T>();
    var obj = pool.removeLast();
    return obj ??= createPooled();
  }

  static Bag<T> _getPool<T extends Pooled>() {
    var pooledObjects = _objectPools[T] as Bag<T>;
    if (null == pooledObjects) {
      pooledObjects = Bag<T>();
      _objectPools[T] = pooledObjects;
    }
    return pooledObjects;
  }

  /// Adds a [Pooled] object to the [ObjectPool].
  static void add(Pooled pooled) {
    _objectPools[pooled.runtimeType].add(pooled);
  }

  /// Add a specific [amount] of [Pooled]s for later reuse.
  static void addMany<T extends Pooled>(
      CreatePooled<T> createPooled, int amount) {
    final pool = _getPool<T>();
    for (var i = 0; i < amount; i++) {
      pool.add(createPooled());
    }
  }
}

/// Create a [Pooled] object.
typedef CreatePooled<T extends Pooled> = T Function();

/// Objects of this class can be pooled in the [ObjectPool] for later reuse.
///
/// Should be added as a mixin.
mixin Pooled {
  /// Creates a new [Pooled] of type [T].
  ///
  /// The instance created with [createPooled] should be created with
  /// a zero-argument contructor because it will only be called once. All fields
  /// of the created object should be set in the calling factory constructor.
  static T of<T extends Pooled>(CreatePooled<T> createPooled) =>
      ObjectPool.get<T>(createPooled);

  /// If you need to do some cleanup before this object moves into the Pool of
  /// reusable objects.
  void cleanUp();

  /// Calls the cleanup function and moves this object to the [ObjectPool].
  void moveToPool() {
    cleanUp();
    ObjectPool.add(this);
  }
}
