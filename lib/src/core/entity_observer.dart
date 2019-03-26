part of dartemis;

/// Interface for [EntitySystem]s and [Manager]s to get informed about changes
/// to the state of an [Entity].
abstract class EntityObserver {
  /// Called when an [entity] is added to the world.
  void added(Entity entity);

  /// Called when the components of an [entity] change.
  void changed(Entity entity);

  /// Called when an [entity] is being deleted from the world.
  void deleted(Entity entity);

  /// Called when an [entity] is enabled.
  void enabled(Entity entity);

  /// Called when an [entity] is disabled.
  void disabled(Entity entity);
}
