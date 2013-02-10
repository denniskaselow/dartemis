part of darteroids;

class MovementSystem extends EntityProcessingSystem {

  ComponentMapper<Position> positionMapper;
  ComponentMapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
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

  BulletSpawningSystem() : super(Aspect.getAspectForAllOf([Cannon, Position, Velocity]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
    cannonMapper = new ComponentMapper<Cannon>(Cannon, world);
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
    bullet.addComponent(new Position(world, shooterPos.x, shooterPos.y));
    num dirX = cannon.targetX - shooterPos.x;
    num dirY = cannon.targetY - shooterPos.y;
    num distance = sqrt(pow(dirX, 2) + pow(dirY, 2));
    num velX = shooterVel.x + bulletSpeed * (dirX / distance);
    num velY = shooterVel.y + bulletSpeed * (dirY / distance);
    bullet.addComponent(new Velocity(world, velX, velY));
    bullet.addComponent(new CircularBody(world, 2, "red"));
    bullet.addComponent(new Decay(world, 5000));
    bullet.addComponent(new AsteroidDestroyer(world));
    bullet.addToWorld();
  }
}

class DecaySystem extends EntityProcessingSystem {

  ComponentMapper<Decay> decayMapper;

  DecaySystem() : super(Aspect.getAspectForAllOf([Decay]));

  void initialize() {
    decayMapper = new ComponentMapper<Decay>(Decay, world);
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
  static final num sqrtOf2 = sqrt(2);
  GroupManager groupManager;
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;

  AsteroidDestructionSystem() : super(Aspect.getAspectForAllOf([AsteroidDestroyer, Position]));

  void initialize() {
    groupManager = world.getManager(new GroupManager().runtimeType);
    positionMapper = new ComponentMapper<Position>(Position, world);
    bodyMapper = new ComponentMapper<CircularBody>(CircularBody, world);
  }

  void processEntity(Entity entity) {
    Position destroyerPos = positionMapper.get(entity);

    groupManager.getEntities(GROUP_ASTEROIDS).forEach((Entity asteroid) {
      Position asteroidPos = positionMapper.get(asteroid);
      CircularBody asteroidBody = bodyMapper.get(asteroid);

      if (Utils.doCirclesCollide(destroyerPos.x, destroyerPos.y, 0, asteroidPos.x, asteroidPos.y, asteroidBody.radius)) {
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
    asteroid.addComponent(new Position(world, asteroidPos.x, asteroidPos.y));
    num vx = generateRandomVelocity();
    num vy = generateRandomVelocity();
    asteroid.addComponent(new Velocity(world, vx, vy));
    num radius = asteroidBody.radius / sqrtOf2;
    asteroid.addComponent(new CircularBody(world, radius, ASTEROID_COLOR));
    asteroid.addComponent(new PlayerDestroyer(world));
    asteroid.addToWorld();
    groupManager.add(asteroid, GROUP_ASTEROIDS);
  }

}

class PlayerCollisionDetectionSystem extends EntitySystem {
  TagManager tagManager;
  ComponentMapper<Status> statusMapper;
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem() : super(Aspect.getAspectForAllOf([PlayerDestroyer, Position, CircularBody]));

  void initialize() {
    tagManager = world.getManager(new TagManager().runtimeType);
    statusMapper = new ComponentMapper(Status, world);
    positionMapper = new ComponentMapper<Position>(Position, world);
    bodyMapper = new ComponentMapper<CircularBody>(CircularBody, world);
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

        if (Utils.doCirclesCollide(pos.x, pos.y, body.radius, playerPos.x, playerPos.y, playerBody.radius)) {
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