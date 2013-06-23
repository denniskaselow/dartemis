part of darteroids;

class PlayerControlSystem extends IntervalEntitySystem {
  static const int UP = 87;
  static const int DOWN = 83;
  static const int LEFT = 65;
  static const int RIGHT = 68;

  bool moveUp = false;
  bool moveDown = false;
  bool moveLeft = false;
  bool moveRight = false;
  bool shoot = false;

  num targetX = 0;
  num targetY = 0;

  ComponentMapper<Velocity> velocityMapper;
  ComponentMapper<Cannon> cannonMapper;
  TagManager tagManager;

  CanvasElement canvas;

  PlayerControlSystem(this.canvas) : super(20, Aspect.getAspectForAllOf([Velocity, Cannon]));

  void initialize() {
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
    cannonMapper = new ComponentMapper<Cannon>(Cannon, world);

    tagManager = world.getManager(new TagManager().runtimeType);
    window.onKeyDown.listen(handleKeyDown);
    window.onKeyUp.listen(handleKeyUp);
    canvas.onMouseDown.listen(handleMouseDown);
    canvas.onMouseUp.listen(handleMouseUp);
  }

  void processEntities(ReadOnlyBag<Entity> entities) {
    Entity player = tagManager.getEntity(TAG_PLAYER);
    Velocity velocity = velocityMapper.get(player);
    Cannon cannon = cannonMapper.get(player);

    if (moveUp) {
      velocity.y -= 0.1;
    } else if (moveDown) {
      velocity.y += 0.1;
    }
    if (moveLeft) {
      velocity.x -= 0.1;
    } else if(moveRight) {
      velocity.x += 0.1;
    }
    cannon.shoot = shoot;
    if (shoot) {
      cannon.target(targetX, targetY);
    }
  }

  void handleKeyDown(KeyboardEvent e) {
    int keyCode = e.keyCode;
    if (keyCode == UP) {
      moveUp = true;
      moveDown = false;
    } else if (keyCode == DOWN) {
      moveUp = false;
      moveDown = true;
    } else if (keyCode == LEFT) {
      moveLeft = true;
      moveRight = false;
    } else if (keyCode == RIGHT) {
      moveLeft = false;
      moveRight = true;
    }
  }

  void handleKeyUp(KeyboardEvent e) {
    int keyCode = e.keyCode;
    if (keyCode == UP) {
      moveUp = false;
    } else if (keyCode == DOWN) {
      moveDown = false;
    } else if (keyCode == LEFT) {
      moveLeft = false;
    } else if (keyCode == RIGHT) {
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
