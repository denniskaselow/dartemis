part of darteroids;

class MovementSystem extends EntityProcessingSystem {
  Mapper<Position> positionMapper;
  Mapper<Velocity> velocityMapper;

  MovementSystem() : super(new Aspect.forAllOf([Position, Velocity]));

  void processEntity(Entity entity) {
    Position pos = positionMapper[entity];
    Velocity vel = velocityMapper[entity];

    pos
      ..x += vel.x * world.delta / 10.0
      ..y += vel.y * world.delta / 10.0;
  }
}

class BulletSpawningSystem extends EntityProcessingSystem {
  static const num bulletSpeed = 2.5;

  Mapper<Position> positionMapper;
  Mapper<Cannon> cannonMapper;
  Mapper<Velocity> velocityMapper;

  BulletSpawningSystem()
      : super(new Aspect.forAllOf([Cannon, Position, Velocity]));

  void processEntity(Entity entity) {
    Cannon cannon = cannonMapper[entity];

    if (cannon.canShoot) {
      Position pos = positionMapper[entity];
      Velocity vel = velocityMapper[entity];
      fireBullet(pos, vel, cannon);
    } else if (cannon.cooldown > 0) {
      cannon.cooldown -= world.delta;
    }
  }

  void fireBullet(Position shooterPos, Velocity shooterVel, Cannon cannon) {
    cannon.cooldown = 1000;
    Entity bullet = world.createEntity()
      ..addComponent(new Position(shooterPos.x, shooterPos.y));
    num dirX = cannon.targetX - shooterPos.x;
    num dirY = cannon.targetY - shooterPos.y;
    num distance = sqrt(pow(dirX, 2) + pow(dirY, 2));
    num velX = shooterVel.x + bulletSpeed * (dirX / distance);
    num velY = shooterVel.y + bulletSpeed * (dirY / distance);
    bullet
      ..addComponent(new Velocity(velX, velY))
      ..addComponent(new CircularBody.down(2, "red"))
      ..addComponent(new Decay(5000))
      ..addComponent(new AsteroidDestroyer())
      ..addToWorld();
  }
}

class DecaySystem extends EntityProcessingSystem {
  Mapper<Decay> decayMapper;

  DecaySystem() : super(new Aspect.forAllOf([Decay]));

  void processEntity(Entity entity) {
    Decay decay = decayMapper[entity];

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
  Mapper<Position> positionMapper;
  Mapper<CircularBody> bodyMapper;

  AsteroidDestructionSystem()
      : super(new Aspect.forAllOf([AsteroidDestroyer, Position]));

  void processEntity(Entity entity) {
    Position destroyerPos = positionMapper[entity];

    groupManager.getEntities(groupAsteroids).forEach((Entity asteroid) {
      Position asteroidPos = positionMapper[asteroid];
      CircularBody asteroidBody = bodyMapper[asteroid];

      if (doCirclesCollide(destroyerPos.x, destroyerPos.y, 0, asteroidPos.x,
          asteroidPos.y, asteroidBody.radius)) {
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
    Entity asteroid = world.createEntity()
      ..addComponent(new Position(asteroidPos.x, asteroidPos.y));
    num vx = generateRandomVelocity();
    num vy = generateRandomVelocity();
    asteroid.addComponent(new Velocity(vx, vy));
    num radius = asteroidBody.radius / sqrtOf2;
    asteroid
      ..addComponent(new CircularBody.down(radius, asteroidColor))
      ..addComponent(new PlayerDestroyer())
      ..addToWorld();
    groupManager.add(asteroid, groupAsteroids);
  }
}

class PlayerCollisionDetectionSystem extends EntitySystem {
  TagManager tagManager;
  Mapper<Status> statusMapper;
  Mapper<Position> positionMapper;
  Mapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem()
      : super(new Aspect.forAllOf([PlayerDestroyer, Position, CircularBody]));

  void processEntities(Iterable<Entity> entities) {
    Entity player = tagManager.getEntity(tagPlayer);
    Position playerPos = positionMapper[player];
    Status playerStatus = statusMapper[player];
    CircularBody playerBody = bodyMapper[player];

    if (!playerStatus.invisible) {
      entities.forEach((entity) {
        Position pos = positionMapper[entity];
        CircularBody body = bodyMapper[entity];

        if (doCirclesCollide(pos.x, pos.y, body.radius, playerPos.x,
            playerPos.y, playerBody.radius)) {
          playerStatus.lifes--;
          playerStatus.invisiblityTimer = 5000;
          playerPos
            ..x = maxWidth ~/ 2
            ..y = maxHeight ~/ 2;
          return;
        }
      });
    } else {
      playerStatus.invisiblityTimer -= world.delta;
    }
  }

  bool checkProcessing() => true;
}
