part of dartemis;

/// This system has an empty aspect so it processes no entities, but it still
/// gets invoked.
/// You can use this system if you need to execute some game logic and not have
/// to concern yourself about aspects or entities.
abstract class VoidEntitySystem extends EntitySystem {

  VoidEntitySystem(): super(new Aspect.empty());

  void processEntities(Iterable<Entity> entities) => processSystem();

  void processSystem();

  bool checkProcessing() => true;
}
