part of darteroids;

class MovementSystem extends EntityProcessingSystem {

  ComponentMapper<Position> positionMapper;
  ComponentMapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.getAspectForAllOf(new Position.hack().runtimeType, [new Velocity.hack().runtimeType]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(new Position.hack().runtimeType, world);
    velocityMapper = new ComponentMapper<Velocity>(new Velocity.hack().runtimeType, world);
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
    positionMapper = new ComponentMapper<Position>(new Position.hack().runtimeType, world);
    velocityMapper = new ComponentMapper<Velocity>(new Velocity.hack().runtimeType, world);
    cannonMapper = new ComponentMapper<Cannon>(new Cannon.hack().runtimeType, world);
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
  ComponentMapper<Status> statusMapper;
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem() : super(Aspect.getAspectForAllOf(new PlayerDestroyer.hack().runtimeType, [new Position.hack().runtimeType]));

  void initialize() {
    tagManager = world.getManager(new TagManager().runtimeType);
    statusMapper = new ComponentMapper(new Status.hack().runtimeType, world);
    positionMapper = new ComponentMapper(new Position.hack().runtimeType, world);
    bodyMapper = new ComponentMapper(new CircularBody.hack().runtimeType, world);
  }

  void processEntities(ImmutableBag<Entity> entities) {
    Entity player = tagManager.getEntity(PLAYER);
    Position playerPos = positionMapper.get(player);
    Status playerStatus = statusMapper.get(player);
    CircularBody playerBody = bodyMapper.get(player);

    if (!playerStatus.invisible) {
      entities.forEach((entity) {
        Position pos = positionMapper.get(entity);
        CircularBody body = bodyMapper.get(entity);

        num minDistance = playerBody.radius + body.radius;
        num distance = sqrt(pow((playerPos.x - pos.x), 2) + pow((playerPos.y - pos.y), 2));
        if (distance < minDistance) {
          playerStatus.lifes--;
          playerStatus.invisiblityTimer = 5000;
          playerPos.x = MAXWIDTH~/2;
          playerPos.y = MAXHEIGHT~/2;
          return;
        }
      });
    } else {
      playerStatus.invisiblityTimer -= world.delta;
    }
  }

  bool checkProcessing() => true;
}