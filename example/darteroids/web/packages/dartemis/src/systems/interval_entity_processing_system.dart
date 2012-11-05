part of dartemis;

/**
 * If you need to process entities at a certain interval then use this.
 * A typical usage would be to regenerate ammo or health at certain intervals, no need
 * to do that every game loop, but perhaps every 100 ms. or every second.
 */
abstract class IntervalEntityProcessingSystem extends IntervalEntitySystem {

  /**
   * Create a new [IntervalEntityProcessingSystem]. It requires at least one component.
   */
  IntervalEntityProcessingSystem(int interval, Aspect aspect) : super(interval, aspect);

  /**
   * Process an [entity] this system is interested in.
   */
  void processEntity(Entity entity);

  void processEntities(ImmutableBag<Entity> entities) {
    entities.forEach((entity) => processEntity(entity));
  }

}
