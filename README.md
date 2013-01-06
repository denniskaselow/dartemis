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

Getting started
===============

1. Add dartemis to your project by adding it to your **pubspec.yaml**
2. Import it in your project:

  ```dart
  import 'package:dartemis/dartemis.dart';
  ```
3. Create a world:

  ```dart
  World world = new World();
  ```
4. Create entities, add components to them and finally add those entities to the world. Entities with different components will be processed by different systems:

  ```dart
  Entity entity  = world.createEntity();
  entity.addComponent(new Position(0, 0));
  entity.addComponent(new Velocity(1, 1));
  entity.addToWorld();
  ```
A Component is a pretty simple structure and should not contain any logic:

  ```dart
  class Position extends Component {
      num x,y;
      Position(this.x, this.y);
  }
  ```
5. Define a systems that should process your entities. The `Apsect` defines which components an entity needs to have in order to be processed by the system:

  ```dart
  class MovementSystem extends EntityProcessingSystem {
      ComponentMapper<Position> positionMapper;
      ComponentMapper<Velocity> velocityMapper;
    
      MovementSystem() : super(Aspect.getAspectForAllOf(Position, [Velocity]));
    
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
  
  **CAUTION**: These lines:
  ```dart
  MovementSystem() : super(Aspect.getAspectForAllOf(Position, [Velocity]));
  positionMapper = new ComponentMapper<Position>(Position, world);
  ```
  currently won't work in in the Dart VM. They do work if they are compiled to javascript and the editor does not mark them as warnings or errors. It will work once the Dart VM support [literal types as expressions](https://code.google.com/p/dart/issues/detail?id=6282).
  To workaround this you have to create an instance of your component and use the runtimeType of that object instead:
  ```dart
  positionMapper = new ComponentMapper<Position>(new Position(runtimeType, world);
  ```
  
6. Add your system to the world:
  ```dart  
  world.addSystem(new MovementSystem());
  ```

7. Initialize the world:
  ```dart
  world.initialize();
  ```

8. In your game loop you then process your systems:
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
darteroids
----------
An very simple example included in the example folder of dartemis:
[Source Code](https://github.com/denniskaselow/dartemis/tree/master/example/web)
[Playable version](http://denniskaselow.github.com/dartemis/example/darteroids/darteroids.html)

GitHub Space Off
----------------
A game originally created for the GitHub Game Off 2012
[Source Code](https://github.com/denniskaselow/game-off-2012)
[Playable version](http://denniskaselow.github.com/game-off-2012/)
