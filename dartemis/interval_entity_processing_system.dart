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
   * Create a new IntervalEntityProcessingSystem. It requires at least one component.
   * @param requiredType the required component type.
   * @param otherTypes other component types.
   */
  IntervalEntityProcessingSystem(int interval, Type requiredType, [List<Type> otherTypes]) : super(interval, getMergedTypes(requiredType, otherTypes));

  /**
   * Process a entity this system is interested in.
   * @param e the entity to process.
   */
  abstract void _process(Entity e);

  void _processEntities(ImmutableBag<Entity> entities) {
    for (int i = 0, s = entities.size; s > i; i++) {
      _process(entities[i]);
    }
  }

  Type get type() => const Type('IntervalEntityProcessingSystem');
}
