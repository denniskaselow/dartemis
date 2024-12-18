library darteroids;

import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:dartemis/dartemis.dart';
import 'package:web/web.dart';

part 'darteroids/components.dart';
part 'darteroids/gamelogic_systems.dart';
part 'darteroids/input_systems.dart';
part 'darteroids/render_systems.dart';

const String tagPlayer = 'player';
const String groupAsteroids = 'ASTEROIDS';
const String playerColor = '#ff0000';
const String asteroidColor = '#BBB';
const int maxWidth = 600;
const int maxHeight = 600;
const int hudHeight = 100;

final Random random = Random();

void main() async {
  final canvas = document.querySelector('#gamecontainer')! as HTMLCanvasElement
    ..width = maxWidth
    ..height = maxHeight + hudHeight;

  await Darteroids(canvas).start();
}

class Darteroids {
  final HTMLCanvasElement canvas;
  final CanvasRenderingContext2D context2d;
  final World world;
  num lastTime = 0;
  final Stopwatch physicsLoopTimer = Stopwatch()..start();

  Darteroids(this.canvas)
      : context2d = canvas.context2D,
        world = World();

  Future<void> start() async {
    final player = world.createEntity([
      Position(maxWidth ~/ 2, maxHeight ~/ 2),
      Velocity(),
      CircularBody(20, playerColor),
      Cannon(),
      Status(lifes: 3, invisiblityTimer: 5000),
    ]);

    final tagManager = TagManager()..register(player, tagPlayer);
    final groupManager = GroupManager();
    world
      ..addManager(tagManager)
      ..addManager(groupManager);

    addAsteroids(groupManager);

    world
      ..addSystem(PlayerControlSystem(canvas))
      ..addSystem(BulletSpawningSystem())
      ..addSystem(DecaySystem())
      ..addSystem(MovementSystem())
      ..addSystem(AsteroidDestructionSystem())
      ..addSystem(PlayerCollisionDetectionSystem())
      ..addSystem(BackgroundRenderSystem(context2d, group: 1))
      ..addSystem(CircleRenderingSystem(context2d, group: 1))
      ..addSystem(HudRenderSystem(context2d, group: 1))
      ..initialize();

    physicsLoop();
    renderLoop(16.66);
  }

  void addAsteroids(GroupManager groupManager) {
    for (var i = 0; i < 33; i++) {
      final vx = generateRandomVelocity();
      final vy = generateRandomVelocity();
      final asteroid = world.createEntity([
        Position(
          maxWidth * random.nextDouble(),
          maxHeight * random.nextDouble(),
        ),
        Velocity(vx, vy),
        CircularBody(5 + 10 * random.nextDouble(), asteroidColor),
        PlayerDestroyer(),
      ]);
      groupManager.add(asteroid, groupAsteroids);
    }
  }

  void physicsLoop() {
    world
      ..delta = physicsLoopTimer.elapsedMicroseconds / 1000.0
      ..process();
    physicsLoopTimer.reset();

    Future.delayed(const Duration(milliseconds: 5), physicsLoop);
  }

  void renderLoop(num time) {
    world.delta = (time - lastTime).toDouble();
    lastTime = time;
    world.process(1);

    window.requestAnimationFrame(renderLoop.toJS);
  }
}

num generateRandomVelocity() =>
    0.5 + 1.5 * random.nextDouble() * (random.nextBool() ? 1 : -1);

bool doCirclesCollide(
  num x1,
  num y1,
  num radius1,
  num x2,
  num y2,
  num radius2,
) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final d = radius1 + radius2;
  return (dx * dx + dy * dy) < (d * d);
}
