part of dartemis;

abstract class DelayedEntityProcessingSystem extends DelayedEntitySystem {

  /**
   * Create a new [DelayedEntityProcessingSystem]. It requires at least one component.
   */
  DelayedEntityProcessingSystem(Aspect aspect) : super(aspect);

  /**
   * Process an [entity] this system is interested in.
   */
  abstract void processEntity(Entity entity, int accumulatedDelta);

  void processEntitiesWithAccDelta(ImmutableBag<Entity> entities, int accumulatedDelta) {
    for (int i = 0, s = entities.size; s > i; i++) {
      processEntity(entities[i], accumulatedDelta);
    }
  }

}
