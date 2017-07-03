part of dartemis;

/// Manager.
abstract class Manager implements EntityObserver {
  World _world;

  World get world => _world;

  /// Override to implement code that gets executed when managers are
  /// initialized.
  void initialize() {}

  @override
  void added(Entity e) {}

  @override
  void changed(Entity e) {}

  @override
  void deleted(Entity e) {}

  @override
  void disabled(Entity e) {}

  @override
  void enabled(Entity e) {}

  void destroy() {}
}
