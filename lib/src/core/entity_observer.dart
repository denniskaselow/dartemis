part of dartemis;

/// Interface for [EntitySystem]s and [Manager]s to get informed about changes
/// to the state of an [int].
abstract class EntityObserver {
  /// Called when an [entity] is added to the world.
  void added(int entity);

  /// Called when an [entity] is being deleted from the world.
  void deleted(int entity);
}
