part of darteroids;

class MovementSystem extends EntityProcessingSystem {

  @Mapper(Position)
  ComponentMapper<Position> positionMapper;
  @Mapper(Velocity)
  ComponentMapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    Velocity vel = velocityMapper.get(entity);

    pos.x += vel.x;
    pos.y += vel.y;
  }
}

class BulletSpawningSystem extends EntityProcessingSystem {

  static const num bulletSpeed = 2.5;

  @Mapper(Position)
  ComponentMapper<Position> positionMapper;
  @Mapper(Cannon)
  ComponentMapper<Cannon> cannonMapper;
  @Mapper(Velocity)
  ComponentMapper<Velocity> velocityMapper;

  BulletSpawningSystem() : super(Aspect.getAspectForAllOf([Cannon, Position, Velocity]));

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

  @Mapper(Decay)
  ComponentMapper<Decay> decayMapper;

  DecaySystem() : super(Aspect.getAspectForAllOf([Decay]));

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
  @Mapper(Position)
  ComponentMapper<Position> positionMapper;
  @Mapper(CircularBody)
  ComponentMapper<CircularBody> bodyMapper;

  AsteroidDestructionSystem() : super(Aspect.getAspectForAllOf([AsteroidDestroyer, Position]));

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
    asteroid.addComponent(new Position(asteroidPos.x, asteroidPos.y));
    num vx = generateRandomVelocity();
    num vy = generateRandomVelocity();
    asteroid.addComponent(new Velocity(vx, vy));
    num radius = asteroidBody.radius / sqrtOf2;
    asteroid.addComponent(new CircularBody(radius, ASTEROID_COLOR));
    asteroid.addComponent(new PlayerDestroyer());
    asteroid.addToWorld();
    groupManager.add(asteroid, GROUP_ASTEROIDS);
  }

}

class PlayerCollisionDetectionSystem extends EntitySystem {
  TagManager tagManager;
  @Mapper(Status)
  ComponentMapper<Status> statusMapper;
  @Mapper(Position)
  ComponentMapper<Position> positionMapper;
  @Mapper(CircularBody)
  ComponentMapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem() : super(Aspect.getAspectForAllOf([PlayerDestroyer, Position, CircularBody]));

  void processEntities(ReadOnlyBag<Entity> entities) {
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