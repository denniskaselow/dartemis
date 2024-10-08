part of '../main.dart';

class PlayerControlSystem extends IntervalEntitySystem {
  static const int up = 87;
  static const int down = 83;
  static const int left = 65;
  static const int right = 68;

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

  final CanvasElement canvas;

  PlayerControlSystem(this.canvas)
      : super(20, Aspect.forAllOf([Velocity, Cannon]));

  @override
  void initialize(World world) {
    super.initialize(world);
    tagManager = world.getManager<TagManager>();
    velocityMapper = Mapper<Velocity>(world);
    cannonMapper = Mapper<Cannon>(world);

    window.onKeyDown.listen(handleKeyDown);
    window.onKeyUp.listen(handleKeyUp);
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
    targetX = e.offset.x;
    targetY = e.offset.y;
    shoot = true;
  }

  void handleMouseUp(MouseEvent e) {
    shoot = false;
  }
}
