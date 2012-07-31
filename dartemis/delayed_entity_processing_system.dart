abstract class DelayedEntityProcessingSystem extends DelayedEntitySystem {

  /**
   * Create a new [DelayedEntityProcessingSystem]. It requires at least one component.
   */
  DelayedEntityProcessingSystem(Type requiredType, [List<Type> otherTypes]) : super(EntitySystem.getMergedTypes(requiredType, otherTypes));

  /**
   * Process an [entity] this system is interested in.
   */
  abstract void processEntity(Entity entity, int accumulatedDelta);

  void processEntitiesWithAccDelta(ImmutableBag<Entity> entities, int accumulatedDelta) {
    for (int i = 0, s = entities.size; s > i; i++) {
      processEntity(entities[i], accumulatedDelta);
    }
  }

  Type get type() => const Type('DelayedEntityProcessingSystem');
}
