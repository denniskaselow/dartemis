# Changelog
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
