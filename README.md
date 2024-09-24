dartemis
========
[![Build Status](https://github.com/denniskaselow/dartemis/actions/workflows/dart.yml/badge.svg)](https://github.com/denniskaselow/dartemis/actions/workflows/dart.yml)
[![Coverage Status](https://coveralls.io/repos/github/denniskaselow/dartemis/badge.svg?branch=master)](https://coveralls.io/github/denniskaselow/dartemis?branch=master)
[![Pub](https://img.shields.io/pub/v/dartemis.svg)](https://pub.dartlang.org/packages/dartemis)

Content
=======
* [About](#about)
* [Getting Started](#getting-started)
* [Documentation](#documentation)
* [Example Games](#example-games-using-dartemis)

About
=====
**dartemis** is a Dart port of the Entity System Framework **Artemis**.

The original has been written in Java by Arni Arent and Tiago Costa and can be found here: 
[https://gamadu.com/artemis/ (archived)](https://archive.is/1xRWW) with the source available here: 
https://code.google.com/p/artemis-framework/

Ports for other languages are also available:

* C#: https://github.com/thelinuxlich/artemis_CSharp
* Python: https://github.com/kernhanda/PyArtemis

Some useful links about what an Entity System/Entity Component System is:

* [https://piemaster.net/2011/07/entity-component-artemis/ (archived)](https://archive.ph/yGyxW)
* http://t-machine.org/index.php/2007/09/03/entity-systems-are-the-future-of-mmog-development-part-1/
* https://www.richardlord.net/blog/what-is-an-entity-framework

Getting started
===============
1. Add dartemis to your project by adding it to your **pubspec.yaml**:

   ```yaml
   dependencies:
     dartemis: any
   ```

2. Import it in your project:

   ```dart
   import 'package:dartemis/dartemis.dart';
   ```
3. Create a world:

   ```dart
   final world = World();
   ```
4. Create an entity from a list of components. Entities with different components will be processed by different systems:

   ```dart
   world.createEntity([
     Position(0, 0), 
     Velocity(1, 1),
   ]);
   ```
   A `Component` is a pretty simple structure and should not contain any logic:

   ```dart
   class Position extends Component {
     num x, y;
     Position(this.x, this.y);
   }
   ```
   Or if you want to use a `PooledComponent`:

   ```dart
   class Position extends PooledComponent {
     late num x, y;
    
     Position._();
     factory Position(num x, num y) {
       final position = Pooled.of<Position>(() => Position._())
         ..x = x
         ..y = y;
       return position;
     }
   }
   ```
   By using a factory constructor and calling the static function `Pooled.of`, dartemis is able to reuse destroyed components and they will not be garbage collected.

5. Define a systems that should process your entities. The `Aspect` defines which components an entity needs to have in order to be processed by the system:

   ```dart
   class MovementSystem extends EntityProcessingSystem {
     late Mapper<Position> positionMapper;
     late Mapper<Velocity> velocityMapper;

     MovementSystem() : super(Aspect.forAllOf([Position, Velocity]));

     void initialize() {
       // initialize your system
       // Mappers, Systems and Managers have to be assigned here
       // see dartemis_builder if you don't want to write this code
       positionMapper = Mapper<Position>(world);
       velocityMapper = Mapper<Velocity>(world);
     }

     void processEntity(Entity entity) {
       Position position = positionMapper[entity];
       Velocity vel = velocityMapper[entity];
       position
         ..x += vel.x * world.delta
         ..y += vel.y * world.delta;
     }
   }
   ```
   Or using [dartemis_builder](https://pub.dev/packages/dartemis_builder)   
   
   ```dart
   part 'filename.g.part';
   
   @Generate(
     EntityProcessingSystem,
     allOf: [
       Position,
       Velocity,
     ],
   )
   class SimpleMovementSystem extends _$SimpleMovementSystem {
     @override
     void processEntity(Entity entity, Position position, Velocity velocity) {    
       position
         ..x += velocity.x * world.delta
         ..y += velocity.y * world.delta;
     }
   }
   ```
6. Add your system to the world:

   ```dart
   world.addSystem(MovementSystem());
   ```
7. Initialize the world:

   ```dart
   world.initialize();   
   ```
8. Usually your logic requires a delta, so you need to set it in your game loop:

   ```dart
   world.delta = delta;
   ```
9. In your game loop you then process your systems:

   ```dart
   world.process();
   ```

Documentation
=============
API
---
[Reference Manual](https://pub.dartlang.org/documentation/dartemis/latest/index.html)

Example Games using dartemis
============================
* [darteroids](https://denniskaselow.github.io/dartemis/example/darteroids/web/darteroids.html) - Very simple example included in the example folder of dartemis, ([Source](https://github.com/denniskaselow/dartemis/tree/master/example/web))
* [Shapeocalypse](https://isowosi.itch.io/shapeocalypse/) - A fast paced reaction game using 
  Angular, WebAudio and WebGL
* [damacreat](https://isowosi.itch.io/damacreat) - An iogame similar to agar.io about creatures 
  made of dark matter (circles) consuming dark energy (circles) and other dark matter creatures (circles), which can shoot black holes (circles)
