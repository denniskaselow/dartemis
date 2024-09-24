part of '../../../dartemis.dart';

/// This system has an empty aspect so it processes no entities, but it still
/// gets invoked.
/// You can use this system if you need to execute some game logic and not have
/// to concern yourself about aspects or entities.
abstract class VoidEntitySystem extends EntitySystem {
  /// Create the [VoidEntitySystem].
  VoidEntitySystem() : super(Aspect.empty());

  @override
  void processEntities(Iterable<Entity> entities) => processSystem();

  /// Execute the logic for this system.
  void processSystem();
}
