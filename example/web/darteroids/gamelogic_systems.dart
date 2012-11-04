part of darteroids;

class PlayerControlSystem extends IntervalEntitySystem {
  const int UP = 87;
  const int DOWN = 83;
  const int LEFT = 65;
  const int RIGHT = 68;

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

  PlayerControlSystem(this.canvas) : super(20, Aspect.getAspectForAllOf(new Velocity.hack().runtimeType, [new Cannon.hack().runtimeType]));

  void initialize() {
    velocityMapper = new ComponentMapper(new Velocity.hack().runtimeType, world);
    cannonMapper = new ComponentMapper(new Cannon.hack().runtimeType, world);

    tagManager = world.getManager(new TagManager().runtimeType);
    window.on.keyDown.add(handleKeyDown);
    window.on.keyUp.add(handleKeyUp);
    canvas.on.mouseDown.add(handleMouseDown);
    canvas.on.mouseUp.add(handleMouseUp);
  }

  void processEntities(ImmutableBag<Entity> entities) {
    Entity player = tagManager.getEntity(PLAYER);
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
    targetX = e.layerX;
    targetY = e.layerY;
    shoot = true;
  }

  void handleMouseUp(MouseEvent e) {
    shoot = false;
  }
}

class MovementSystem extends EntityProcessingSystem {

  ComponentMapper<Position> positionMapper;
  ComponentMapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.getAspectForAllOf(new Position.hack().runtimeType, [new Velocity.hack().runtimeType]));

  void initialize() {
    positionMapper = new ComponentMapper(new Position.hack().runtimeType, world);
    velocityMapper = new ComponentMapper(new Velocity.hack().runtimeType, world);
  }

  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    Velocity vel = velocityMapper.get(entity);

    pos.x += vel.x;
    pos.y += vel.y;
  }
}

class BulletSpawningSystem extends EntityProcessingSystem {

  const num bulletSpeed = 2.5;

  ComponentMapper<Position> positionMapper;
  ComponentMapper<Cannon> cannonMapper;
  ComponentMapper<Velocity> velocityMapper;

  BulletSpawningSystem() : super(Aspect.getAspectForAllOf(new Cannon.hack().runtimeType, [new Position.hack().runtimeType, new Velocity.hack().runtimeType]));

  void initialize() {
    positionMapper = new ComponentMapper(new Position.hack().runtimeType, world);
    velocityMapper = new ComponentMapper(new Velocity.hack().runtimeType, world);
    cannonMapper = new ComponentMapper(new Cannon.hack().runtimeType, world);
  }

  void processEntity(Entity entity) {
    Cannon cannon = cannonMapper.get(entity);

    if (cannon.canShoot) {
      Position pos = positionMapper.get(entity);
      Velocity vel = velocityMapper.get(entity);
      fireBullet(pos, vel, cannon);
    } else if (cannon.cooldown > 0){
      cannon.cooldown -= world.delta;
    }
  }

  void fireBullet(Position shooterPos, Velocity shooterVel, Cannon cannon) {
    cannon.cooldown = 1000;
    Entity bullet = world.createEntity();
    bullet.addComponent(new Position(shooterPos.x, shooterPos.y));
    num dirX = cannon.targetX - shooterPos.x;
    num dirY = cannon.targetY - shooterPos.y;
    num distance = sqrt(pow(dirX, 2) + pow(dirY, 2));
    num velX = shooterVel.x + bulletSpeed * (dirX / distance);
    num velY = shooterVel.y + bulletSpeed * (dirY / distance);
    bullet.addComponent(new Velocity(velX, velY));
    bullet.addComponent(new CircularBody(2, "red"));
    bullet.addComponent(new Decay(5000));
    bullet.addToWorld();
  }
}

class DecaySystem extends EntityProcessingSystem {

  ComponentMapper<Decay> decayMapper;

  DecaySystem() : super(Aspect.getAspectForAllOf(new Decay.hack().runtimeType));

  void initialize() {
    decayMapper = new ComponentMapper<Decay>(new Decay.hack().runtimeType, world);
  }

  void processEntity(Entity entity) {
    Decay decay = decayMapper.get(entity);

    if (decay.timer < 0) {
      entity.deleteFromWorld();
    } else {
      decay.timer -= world.delta;
    }
  }
}

class PlayerCollisionDetectionSystem extends EntitySystem {
  TagManager tagManager;
  ComponentMapper<Lives> livesMapper;
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem() : super(Aspect.getAspectForAllOf(new PlayerDestroyer.hack().runtimeType, [new Position.hack().runtimeType]));

  void initialize() {
    tagManager = world.getManager(new TagManager().runtimeType);
    livesMapper = new ComponentMapper(new Lives.hack().runtimeType, world);
    positionMapper = new ComponentMapper(new Position.hack().runtimeType, world);
    bodyMapper = new ComponentMapper(new CircularBody.hack().runtimeType, world);
  }

  void processEntities(ImmutableBag<Entity> entities) {
    Entity player = tagManager.getEntity(PLAYER);
    Position playerPos = positionMapper.get(player);
    Lives playerLives = livesMapper.get(player);
    CircularBody playerBody = bodyMapper.get(player);

    entities.forEach((entity) {
      Position pos = positionMapper.get(entity);
      CircularBody body = bodyMapper.get(entity);

      num minDistance = playerBody.radius + body.radius;
      num distance = sqrt(pow((playerPos.x - pos.x), 2) + pow((playerPos.y - pos.y), 2));
      if (distance < minDistance) {
        playerLives.amount--;
        playerPos.x = MAXWIDTH~/2;
        playerPos.y = MAXHEIGHT~/2;
        return;
      }
    });
  }

  bool checkProcessing() => true;
}