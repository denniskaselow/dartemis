library darteroids;

import 'dart:math';
import 'dart:html' hide Entity;

import 'package:dartemis/dartemis.dart';

part 'darteroids/components.dart';
part 'darteroids/render_systems.dart';
part 'darteroids/gamelogic_systems.dart';

const String PLAYER = "player";
const int MAXWIDTH = 600;
const int MAXHEIGHT = 600;
const int HUDHEIGHT = 100;

void main() {
  CanvasElement canvas = query('#gamecontainer');
  canvas.parent.rect.then((ElementRect rect) {
    canvas.width = MAXWIDTH;
    canvas.height = MAXHEIGHT + HUDHEIGHT;

    Darteroids darteroids = new Darteroids(canvas);
    darteroids.start();
  });
}

class Darteroids {
  CanvasElement canvas;
  CanvasRenderingContext2D context2d;
  num lastTime = 0;
  World world;
  Random random = new Random();

  Darteroids(this.canvas) {
    context2d = canvas.context2d;
  }

  void start() {
    world = new World();

    Entity player = world.createEntity();
    player.addComponent(new Position(MAXWIDTH~/2, MAXHEIGHT~/2));
    player.addComponent(new Velocity());
    player.addComponent(new CircularBody(20, "white"));
    player.addComponent(new Lives(3));
    player.addComponent(new Cannon());
    player.addToWorld();

    addAsteroids();

    TagManager manager = new TagManager();
    manager.register(PLAYER, player);
    world.addManager(manager);

    world.addSystem(new PlayerControlSystem(canvas));
    world.addSystem(new BulletSpawningSystem());
    world.addSystem(new MovementSystem());
    world.addSystem(new PlayerCollisionDetectionSystem());
    world.addSystem(new BackgroundRenderSystem(context2d));
    world.addSystem(new CirleRenderingSystem(context2d));
    world.addSystem(new HudRenderSystem(context2d));

    world.initialize();

    gameLoop(0);
  }

  void addAsteroids() {

    for (int i = 0; i < 10; i++) {
      Entity darteroid = world.createEntity();
      darteroid.addComponent(new Position(MAXWIDTH * random.nextDouble(), MAXHEIGHT * random.nextDouble()));
      num vx = generateRandomVelocity();
      num vy = generateRandomVelocity();
      darteroid.addComponent(new Velocity(vx, vy));
      darteroid.addComponent(new CircularBody(10 + 20 * random.nextDouble(), "#AAA"));
      darteroid.addComponent(new PlayerDestroyer());
      darteroid.addToWorld();
    }
  }

  num generateRandomVelocity() {
    num velocity = 0.5 + 1.5 * random.nextDouble();
    velocity = velocity * (random.nextBool() ? 1 : -1);
    return velocity;
  }

  void gameLoop(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();

    requestRedraw();
  }

  void requestRedraw() {
    window.requestAnimationFrame(gameLoop);
  }
}