abstract class DelayedEntityProcessingSystem extends DelayedEntitySystem {

  /**
   * Create a new DelayedEntityProcessingSystem. It requires at least one component.
   * @param requiredType the required component type.
   * @param otherTypes other component types.
   */
  DelayedEntityProcessingSystem(Type requiredType, [List<Type> otherTypes]) : super(EntitySystem.getMergedTypes(requiredType, otherTypes));

  /**
   * Process a entity this system is interested in.
   * @param e the entity to process.
   */
  abstract void processEntity(Entity e, int accumulatedDelta);

  void processEntitiesWithAccDelta(ImmutableBag<Entity> entities, int accumulatedDelta) {
    for (int i = 0, s = entities.size; s > i; i++) {
      processEntity(entities[i], accumulatedDelta);
    }
  }

  Type get type() => const Type('DelayedEntityProcessingSystem');
}
