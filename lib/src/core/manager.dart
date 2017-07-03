part of dartemis;

/// Manager.
abstract class Manager implements EntityObserver {
  World _world;

  World get world => _world;

  /// Override to implement code that gets executed when managers are
  /// initialized.
  void initialize() {}

  @override
  void added(Entity entity) {}

  @override
  void changed(Entity entity) {}

  @override
  void deleted(Entity entity) {}

  @override
  void disabled(Entity entity) {}

  @override
  void enabled(Entity entity) {}

  void destroy() {}
}
