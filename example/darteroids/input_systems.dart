part of '../main.dart';

class PlayerControlSystem extends IntervalEntitySystem {
  static const int up = KeyCode.W;
  static const int down = KeyCode.S;
  static const int left = KeyCode.A;
  static const int right = KeyCode.D;

  bool moveUp = false;
  bool moveDown = false;
  bool moveLeft = false;
  bool moveRight = false;
  bool shoot = false;

  num targetX = 0;
  num targetY = 0;

  late final Mapper<Velocity> velocityMapper;
  late final Mapper<Cannon> cannonMapper;
  late final TagManager tagManager;

  final HTMLCanvasElement canvas;

  PlayerControlSystem(this.canvas)
      : super(20, Aspect(allOf: [Velocity, Cannon]));

  @override
  void initialize(World world) {
    super.initialize(world);
    tagManager = world.getManager<TagManager>();
    velocityMapper = Mapper<Velocity>(world);
    cannonMapper = Mapper<Cannon>(world);

    window.onKeyDown.listen(handleKeyDown);
    EventStreamProviders.keyUpEvent.forTarget(window).listen(handleKeyUp);
    canvas.onMouseDown.listen(handleMouseDown);
    canvas.onMouseUp.listen(handleMouseUp);
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    final player = tagManager.getEntity(tagPlayer)!;
    final velocity = velocityMapper[player];
    final cannon = cannonMapper[player];

    if (moveUp) {
      velocity.y -= 0.1;
    } else if (moveDown) {
      velocity.y += 0.1;
    }
    if (moveLeft) {
      velocity.x -= 0.1;
    } else if (moveRight) {
      velocity.x += 0.1;
    }
    cannon.shoot = shoot;
    if (shoot) {
      cannon.target(targetX, targetY);
    }
  }

  void handleKeyDown(KeyboardEvent e) {
    final keyCode = e.keyCode;
    if (keyCode == up) {
      moveUp = true;
      moveDown = false;
    } else if (keyCode == down) {
      moveUp = false;
      moveDown = true;
    } else if (keyCode == left) {
      moveLeft = true;
      moveRight = false;
    } else if (keyCode == right) {
      moveLeft = false;
      moveRight = true;
    }
  }

  void handleKeyUp(KeyboardEvent e) {
    final keyCode = e.keyCode;
    if (keyCode == up) {
      moveUp = false;
    } else if (keyCode == down) {
      moveDown = false;
    } else if (keyCode == left) {
      moveLeft = false;
    } else if (keyCode == right) {
      moveRight = false;
    }
  }

  void handleMouseDown(MouseEvent e) {
    targetX = e.offsetX;
    targetY = e.offsetY;
    shoot = true;
  }

  void handleMouseUp(MouseEvent e) {
    shoot = false;
  }
}
