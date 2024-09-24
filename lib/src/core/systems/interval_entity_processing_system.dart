part of '../../../dartemis.dart';

/// If you need to process entities at a certain interval then use this.
/// A typical usage would be to regenerate ammo or health at certain intervals,
/// no need to do that every game loop, but perhaps every 100 ms. or every
/// second.
abstract class IntervalEntityProcessingSystem extends IntervalEntitySystem {
  /// Create a new [IntervalEntityProcessingSystem]. It requires at least one
  /// component.
  IntervalEntityProcessingSystem(super.interval, super.aspect);

  /// Process an [entity] this system is interested in.
  void processEntity(Entity entity);

  @override
  void processEntities(Iterable<Entity> entities) =>
      entities.forEach(processEntity);
}
