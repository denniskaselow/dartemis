part of '../../../dartemis.dart';

/// A typical entity system. Use this when you need to process entities
/// possessing the provided component types.
abstract class EntityProcessingSystem extends EntitySystem {
  /// Create a new [EntityProcessingSystem]. It requires at least one component.
  EntityProcessingSystem(super.aspect, {super.group, super.passive});

  /// Process an [entity] this system is interested in.
  @visibleForOverriding
  void processEntity(Entity entity);

  @override
  @visibleForOverriding
  void processEntities(Iterable<Entity> entities) =>
      entities.forEach(processEntity);
}
