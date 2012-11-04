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
    bullet.addComponent(new AsteroidDestroyer());
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

class AsteroidDestructionSystem extends EntityProcessingSystem {
  GroupManager groupManager;
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;

  AsteroidDestructionSystem() : super(Aspect.getAspectForAllOf(new AsteroidDestroyer.hack().runtimeType, [new Position.hack().runtimeType]));

  void initialize() {
    groupManager = world.getManager(new GroupManager().runtimeType);
    positionMapper = new ComponentMapper<Position>(new Position.hack().runtimeType, world);
    bodyMapper = new ComponentMapper<CircularBody>(new CircularBody.hack().runtimeType, world);
  }

  void processEntity(Entity entity) {
    Position destroyerPos = positionMapper.get(entity);

    groupManager.getEntities(GROUP_ASTEROIDS).forEach((Entity asteroid) {
      Position asteroidPos = positionMapper.get(asteroid);
      CircularBody asteroidBody = bodyMapper.get(asteroid);

      num distance = sqrt(pow((destroyerPos.x - asteroidPos.x), 2) + pow((destroyerPos.y - asteroidPos.y), 2));
      if (distance < asteroidBody.radius) {
        asteroid.deleteFromWorld();
        entity.deleteFromWorld();
        if (asteroidBody.radius > 10) {
          createNewAsteroids(asteroidPos, asteroidBody);
          createNewAsteroids(asteroidPos, asteroidBody);
        }
      }
    });
  }

  void createNewAsteroids(Position asteroidPos, CircularBody asteroidBody) {
    Entity asteroid = world.createEntity();
    asteroid.addComponent(new Position(asteroidPos.x, asteroidPos.y));
    num vx = generateRandomVelocity();
    num vy = generateRandomVelocity();
    asteroid.addComponent(new Velocity(vx, vy));
    num area = PI * pow(asteroidBody.radius, 2);
    num radius = sqrt(area/(2 * PI));
    asteroid.addComponent(new CircularBody(radius, ASTEROID_COLOR));
    asteroid.addComponent(new PlayerDestroyer());
    asteroid.addToWorld();
    groupManager.add(asteroid, GROUP_ASTEROIDS);
  }

}

class PlayerCollisionDetectionSystem extends EntitySystem {
  TagManager tagManager;
  ComponentMapper<Status> statusMapper;
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem() : super(Aspect.getAspectForAllOf(new PlayerDestroyer.hack().runtimeType, [new Position.hack().runtimeType, new CircularBody.hack().runtimeType]));

  void initialize() {
    tagManager = world.getManager(new TagManager().runtimeType);
    statusMapper = new ComponentMapper(new Status.hack().runtimeType, world);
    positionMapper = new ComponentMapper<Position>(new Position.hack().runtimeType, world);
    bodyMapper = new ComponentMapper<CircularBody>(new CircularBody.hack().runtimeType, world);
  }

  void processEntities(ImmutableBag<Entity> entities) {
    Entity player = tagManager.getEntity(TAG_PLAYER);
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