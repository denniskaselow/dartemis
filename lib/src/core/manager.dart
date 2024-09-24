part of '../../dartemis.dart';

/// Manager.
abstract class Manager implements EntityObserver {
  late final World _world;

  /// The [World] where this manager resides.
  World get world => _world;

  /// Override to implement code that gets executed when managers are
  /// initialized.
  void initialize() {}

  @override
  void added(Entity entity) {}

  @override
  void deleted(Entity entity) {}

  /// Called when the world gets destroyed. Override if you need to clean up
  /// your manager.
  void destroy() {}
}

/// For Testing.
@visibleForTesting
mixin MockManagerMixin implements Manager {
  @override
  late World _world;
}
