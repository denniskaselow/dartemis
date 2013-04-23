dartemis
========

[![](https://drone.io/denniskaselow/dartemis/status.png)](https://drone.io/denniskaselow/dartemis/latest)

A Dart port of the Entity System Framework **Artemis**.

The original has been written in Java by Arni Arent and Tiago Costa and can be found here: http://gamadu.com/artemis with the source available here: https://code.google.com/p/artemis-framework/

Ports for other languages are also available:

* C#: https://github.com/thelinuxlich/artemis_CSharp 
* Python: https://github.com/kernhanda/PyArtemis

Some useful links about what an Entity System/Entity Component System is:

* http://piemaster.net/2011/07/entity-component-artemis/
* http://t-machine.org/index.php/2007/09/03/entity-systems-are-the-future-of-mmog-development-part-1/ 
* http://www.richardlord.net/blog/what-is-an-entity-framework

Getting started
===============

1\. Add dartemis to your project by adding it to your **pubspec.yaml**  
2\. Import it in your project:

```dart
import 'package:dartemis/dartemis.dart';
```
3\. Create a world:

```dart
World world = new World();
```
4\. Create entities, add components to them and finally add those entities to the world. Entities with different components will be processed by different systems:

```dart
Entity entity  = world.createEntity();
entity.addComponent(new Position(world, 0, 0));
entity.addComponent(new Velocity(world, 1, 1));
entity.addToWorld();
```
A `Component` is a pretty simple structure and should not contain any logic:

```dart
class Position extends Component {
    num x, y;
    Position(this.x, this.y);
}
```
Or if you want to use a `ComponentPoolable`:

```dart
class Position extends ComponentPoolable {
    num x, y;

    Position._();
    factory Position(num x, num y) {
        Position position = new Poolable.of(Position, _constructor);
        position.x = x;
        position.y = y;
        return position;
    }
    static Position _constructor() => new Position._();
}
```
By using a factory constructor and calling the factory constructor in `Poolable`, dartemis is able to reuse destroyed components and they will not be garbage collected. For more information about why this is done you might want to read this article: [Free Lists For Predictable Game Performance](http://dartgamedevs.org/blog/2012/11/02/Free-Lists-For-Predictable-Game-Performance/) 

5\. Define a systems that should process your entities. The `Aspect` defines which components an entity needs to have in order to be processed by the system:

```dart
class MovementSystem extends EntityProcessingSystem {
    ComponentMapper<Position> positionMapper;
    ComponentMapper<Velocity> velocityMapper;
  
    MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));
  
    void initialize() {
      positionMapper = new ComponentMapper<Position>(Position, world);
      velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
    }
  
    void processEntity(Entity entity) {
      Position position = positionMapper.get(entity);
      Velocity vel = velocityMapper.get(entity);  
      position.x += vel.x;
      position.y += vel.y;
    }
}
```  
6\. Add your system to the world:

```dart  
world.addSystem(new MovementSystem());
```
7\. Initialize the world:

```dart
world.initialize();
```
8\. In your game loop you then process your systems:

```dart
world.process();
```
If your game logic requires a delta you can set it by calling:
```dart
world.delta = delta;
```

Documentation
=============
API
---
[Reference Manual](http://denniskaselow.github.com/dartemis/docs/dartemis.html)

Example Games using dartemis
============================
VDrones
----------------
An arcade game (with weekly updates).  
[Source Code](https://github.com/davidB/vdrones)  
[Playable version](http://vdrones.appspot.com/) - Chrome/Firefox -

GitHub Space Off
----------------
A game originally created for the GitHub Game Off 2012  
[Source Code](https://github.com/denniskaselow/game-off-2012)  
[Playable version](http://denniskaselow.github.com/game-off-2012/)

darteroids
----------
An very simple example included in the example folder of dartemis:  
[Source Code](https://github.com/denniskaselow/dartemis/tree/master/example/web)  
[Playable version](http://denniskaselow.github.com/dartemis/example/darteroids/web/darteroids.html)

Add-ons
=======
* [dartemis_addons](https://github.com/davidB/dartemis_addons) - A set of addons to use with dartemis (like EntityStateMachine, ...)
