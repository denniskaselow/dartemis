part of '../../../dartemis.dart';

/// A typical entity system. Use this when you need to process entities
/// possessing the provided component types.
abstract class EntityProcessingSystem extends EntitySystem {
  /// Create a new [EntityProcessingSystem]. It requires at least one component.
  EntityProcessingSystem(super.aspect);

  /// Process a [entity] this system is interested in.
  void processEntity(int entity);

  @override
  void processEntities(Iterable<int> entities) =>
      entities.forEach(processEntity);

  @override
  bool checkProcessing() => true;
}
