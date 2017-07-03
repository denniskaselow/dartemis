part of dartemis;

/// A typical entity system. Use this when you need to process entities
/// possessing the provided component types.
abstract class EntityProcessingSystem extends EntitySystem {
  /// Create a new [EntityProcessingSystem]. It requires at least one component.
  EntityProcessingSystem(Aspect aspect) : super(aspect);

  /// Process a [entity] this system is interested in.
  void processEntity(Entity entity);

  @override
  void processEntities(Iterable<Entity> entities) =>
      entities.forEach(processEntity);

  @override
  bool checkProcessing() => true;
}
