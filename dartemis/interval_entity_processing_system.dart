/**
 * If you need to process entities at a certain interval then use this.
 * A typical usage would be to regenerate ammo or health at certain intervals, no need
 * to do that every game loop, but perhaps every 100 ms. or every second.
 *
 * @author Arni Arent
 *
 */
abstract class IntervalEntityProcessingSystem extends IntervalEntitySystem {

  /**
   * Create a new [IntervalEntityProcessingSystem]. It requires at least one component.
   */
  IntervalEntityProcessingSystem(int interval, Type requiredType, [List<Type> otherTypes]) : super(interval, EntitySystem.getMergedTypes(requiredType, otherTypes));

  /**
   * Process an [entity] this system is interested in.
   */
  abstract void processEntity(Entity entity);

  void processEntities(ImmutableBag<Entity> entities) {
    for (int i = 0, s = entities.size; s > i; i++) {
      processEntity(entities[i]);
    }
  }

  Type get type() => const Type('IntervalEntityProcessingSystem');
}
