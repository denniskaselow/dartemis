# Changelog
##0.8.0 (Dart 2.0+ required)
### Breaking API Changes
* removed deprecated code
* `Aspect` no longer uses static methods, uses named constructors instead
(migration: replace `Aspect.getAspectF` with `Aspect.f`)
* methods in `Aspect` no longer return the aspect, use cascading operator to chain calls
* improved type safety for `world.getManager` and `world.getSystem`, no longer takes a `Type` as parameter and uses
generic methods instead (e.g. `world.getManager<TagManager>()` instead of `world.getManager(TagManager)`)
* removed `Type` parameter in constructor of `Mapper`, change code from `Mapper<Position>(Position, world)` to
`Mapper<Position>(world)`
### Enhancements
* `world.destroy()` for cleaning up `EntitySystem`s and `Manager`s

##0.7.3
### Bugfixes
* adding an entity to a dirty EntityBag could lead to an inconsistency between the bitset and the list of entities 

##0.7.2
### Bugfixes
* removing an entity multiple times caused it to be added to the entity pool multiple times

##0.7.1
### Internal
* upgraded dependencies

##0.7.0
### Breaking API Changes
* renamed `Poolable` to `Pooled`
* renamed `ComponentPoolable` to `PooledComponent`
* removed `FastMath` and `Utils`, unrelated to ECS
* removed `removeAll` from `Bag`
* `time` and `frame` getters have been moved from `World` to `EntitySystem`, `World` has methods instead
### API Changes
* deprecated `ComponentMapper` use `Mapper` instead
* deprecated `ComponentMapper#get(Entity)`, use `Mapper[Entity]` instead
* properties have been added to the `World`, can be accessed using the `[]` operator
* `System`s can be assigned to a group when adding them to the `World`, `Word.process()` can be called for a specific group
### Enhancements
* performance improvement when removing entities
### Bugfixes
* DelayedEntityProcessingSystem keeps running until all current entities have expired
### Internal
* upgraded dependencies

##0.6.0
### API Changes
* `Bag` is `Iterable` 
* removed `ReadOnlyBag`, when upgrading to 0.6.0 replace every occurence of `ReadOnlyBag` with `Iterable`
 
##0.5.2
### Enhancements
* injection works for `Manager`s
* `initialize()` in the `Manager` is no longer abstract (same as in `EntitySystem`)
* `World.createEntity` got an optional paramter to create an `Entity` with components
* new function `World.createAndAddEntity` which adds the `Entity` to the world after creation

### Bugfixes
* added getter for the `World` in `Manager` 
* the uniqueId of an `Entity` was always 0, not very unique

##0.5.1
### Internal
* added version constraint for release of Dart

##0.5.0
### Enhancements
* more injection, less boilerplate (when using dartemis_mirrors)
  * Instances of `ComponentMapper` no longer need to be created in the `initialize`-method of a system, they will be injected
  * `Manager`s and `EntitySystem`s no longer need to be requested from the `World` in the `initialize`-method of a system, they will be injected

##0.4.2
### Bugfixes
* `EntityManager.isEnabled()` no longer fails if the bag of disabled entities is smaller than the id of the checked entity

### Enhancements
* added getters for current `time` and `frame` to `World`

##0.4.1
### Bugfixes
* `World.deleteAllEntites()` did not work if there was already a deleted entity
* writing to the `Bag` by index doesn't make it smaller anymore

##0.4.0
### API Changes
* swapped parameters of `Tagmanager.register`
* replaced `ImmutableBag` with `ReadOnlyBag`, added getter for `ReadOnlyBag` to `Bag`
* changed `FreeComponents` to `ObjectPool`
* old `Component` has changed, there are two different kinds of components now:
  * instances of classes extending `ComponentPoolable` will be added to the `ObjectPool` when they are removed from an `Entity` (preventing garbage collection and allowing reuse)
  * instances of classes extending `Component` will not be added to the `ObjectPool` when they are removed from an `Entity` (allowing garbage collection)

### Enhancements
* added function `deleteAllEntities` to `World`
* `IntervalEntitySystem` has a getter for the `delta` since the systm was processed last
* updated to work with Dart M4

### Bugfixes
* `GroupManager.isInGroup` works if entity is in no group
