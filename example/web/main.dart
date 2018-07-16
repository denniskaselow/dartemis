library darteroids;

import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:dartemis/dartemis.dart';

part 'darteroids/components.dart';
part 'darteroids/gamelogic_systems.dart';
part 'darteroids/input_systems.dart';
part 'darteroids/render_systems.dart';

const String tagPlayer = "player";
const String groupAsteroids = "ASTEROIDS";
const String playerColor = "#ff0000";
const String asteroidColor = "#BBB";
const int maxWidth = 600;
const int maxHeight = 600;
const int hudHeight = 100;

final Random random = Random();
final CanvasElement canvas = querySelector('#gamecontainer');

void main() {
  canvas
    ..width = maxWidth
    ..height = maxHeight + hudHeight;

  Darteroids(canvas).start();
}

class Darteroids {
  CanvasElement canvas;
  CanvasRenderingContext2D context2d;
  num lastTime = 0;
  World world;

  Darteroids(this.canvas) {
    context2d = canvas.context2D;
  }

  void start() {
    world = World();

    final player = world.createEntity()
      ..addComponent(Position(maxWidth ~/ 2, maxHeight ~/ 2))
      ..addComponent(Velocity())
      ..addComponent(CircularBody.down(20, playerColor))
      ..addComponent(Cannon())
      ..addComponent(Status(lifes: 3, invisiblityTimer: 5000))
      ..addToWorld();

    final tagManager = TagManager()..register(player, tagPlayer);
    world.addManager(tagManager);
    final groupManager = GroupManager();
    world.addManager(groupManager);

    addAsteroids(groupManager);

    world
      ..addSystem(PlayerControlSystem(canvas))
      ..addSystem(BulletSpawningSystem())
      ..addSystem(DecaySystem())
      ..addSystem(MovementSystem())
      ..addSystem(AsteroidDestructionSystem())
      ..addSystem(PlayerCollisionDetectionSystem())
      ..addSystem(BackgroundRenderSystem(context2d), group: 1)
      ..addSystem(CircleRenderingSystem(context2d), group: 1)
      ..addSystem(HudRenderSystem(context2d), group: 1)
      ..initialize();

    physicsLoop();
    renderLoop(16.66);
  }

  void addAsteroids(GroupManager groupManager) {
    for (int i = 0; i < 10; i++) {
      final asteroid = world.createEntity()
        ..addComponent(Position(
            maxWidth * random.nextDouble(), maxHeight * random.nextDouble()));
      final vx = generateRandomVelocity();
      final vy = generateRandomVelocity();
      asteroid
        ..addComponent(Velocity(vx, vy))
        ..addComponent(
            CircularBody.down(10 + 20 * random.nextDouble(), asteroidColor))
        ..addComponent(PlayerDestroyer())
        ..addToWorld();
      groupManager.add(asteroid, groupAsteroids);
    }
  }

  void physicsLoop() {
    world
      ..delta = 5.0
      ..process();

    Future.delayed(const Duration(milliseconds: 5), physicsLoop);
  }

  void renderLoop(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process(1);

    window.animationFrame.then(renderLoop);
  }
}

num generateRandomVelocity() =>
    0.5 + 1.5 * random.nextDouble() * (random.nextBool() ? 1 : -1);

bool doCirclesCollide(
    num x1, num y1, num radius1, num x2, num y2, num radius2) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final d = radius1 + radius2;
  return (dx * dx + dy * dy) < (d * d);
}
