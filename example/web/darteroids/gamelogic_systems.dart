part of darteroids;

class MovementSystem extends EntityProcessingSystem {
  Mapper<Position> positionMapper;
  Mapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.forAllOf([Position, Velocity]));

  @override
  void initialize() {
    positionMapper = Mapper<Position>(world);
    velocityMapper = Mapper<Velocity>(world);
  }

  @override
  void processEntity(int entity) {
    final pos = positionMapper[entity];
    final vel = velocityMapper[entity];

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

  BulletSpawningSystem() : super(Aspect.forAllOf([Cannon, Position, Velocity]));

  @override
  void initialize() {
    positionMapper = Mapper<Position>(world);
    cannonMapper = Mapper<Cannon>(world);
    velocityMapper = Mapper<Velocity>(world);
  }

  @override
  void processEntity(int entity) {
    final cannon = cannonMapper[entity];

    if (cannon.canShoot) {
      final pos = positionMapper[entity];
      final vel = velocityMapper[entity];
      fireBullet(pos, vel, cannon);
    } else if (cannon.cooldown > 0) {
      cannon.cooldown -= world.delta;
    }
  }

  void fireBullet(Position shooterPos, Velocity shooterVel, Cannon cannon) {
    cannon.cooldown = 1000;
    final dirX = cannon.targetX - shooterPos.x;
    final dirY = cannon.targetY - shooterPos.y;
    final distance = sqrt(pow(dirX, 2) + pow(dirY, 2));
    final velX = shooterVel.x + bulletSpeed * (dirX / distance);
    final velY = shooterVel.y + bulletSpeed * (dirY / distance);

    world.createEntity([
      Position(shooterPos.x, shooterPos.y),
      Velocity(velX, velY),
      CircularBody.down(2, 'red'),
      Decay(5000),
      AsteroidDestroyer(),
    ]);
  }
}

class DecaySystem extends EntityProcessingSystem {
  Mapper<Decay> decayMapper;

  DecaySystem() : super(Aspect.forAllOf([Decay]));

  @override
  void initialize() {
    decayMapper = Mapper<Decay>(world);
  }

  @override
  void processEntity(int entity) {
    final decay = decayMapper[entity];

    if (decay.timer < 0) {
      world.deleteEntity(entity);
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
      : super(Aspect.forAllOf([AsteroidDestroyer, Position]));

  @override
  void initialize() {
    positionMapper = Mapper<Position>(world);
    bodyMapper = Mapper<CircularBody>(world);
    groupManager = world.getManager<GroupManager>();
  }

  @override
  void processEntity(int entity) {
    final destroyerPos = positionMapper[entity];

    for (final asteroid in groupManager.getEntities(groupAsteroids)) {
      final asteroidPos = positionMapper[asteroid];
      final asteroidBody = bodyMapper[asteroid];

      if (doCirclesCollide(destroyerPos.x, destroyerPos.y, 0, asteroidPos.x,
          asteroidPos.y, asteroidBody.radius)) {
        deleteFromWorld(asteroid);
        deleteFromWorld(entity);
        if (asteroidBody.radius > 10) {
          createNewAsteroids(asteroidPos, asteroidBody);
          createNewAsteroids(asteroidPos, asteroidBody);
        }
      }
    }
  }

  void createNewAsteroids(Position asteroidPos, CircularBody asteroidBody) {
    final vx = generateRandomVelocity();
    final vy = generateRandomVelocity();
    final radius = asteroidBody.radius / sqrtOf2;

    final asteroid = world.createEntity([
      Position(asteroidPos.x, asteroidPos.y),
      Velocity(vx, vy),
      CircularBody.down(radius, asteroidColor),
      PlayerDestroyer(),
    ]);

    groupManager.add(asteroid, groupAsteroids);
  }
}

class PlayerCollisionDetectionSystem extends EntitySystem {
  TagManager tagManager;
  Mapper<Status> statusMapper;
  Mapper<Position> positionMapper;
  Mapper<CircularBody> bodyMapper;

  PlayerCollisionDetectionSystem()
      : super(Aspect.forAllOf([PlayerDestroyer, Position, CircularBody]));

  @override
  void initialize() {
    positionMapper = Mapper<Position>(world);
    statusMapper = Mapper<Status>(world);
    bodyMapper = Mapper<CircularBody>(world);
    tagManager = world.getManager<TagManager>();
  }

  @override
  void processEntities(Iterable<int> entities) {
    final player = tagManager.getEntity(tagPlayer);
    final playerPos = positionMapper[player];
    final playerStatus = statusMapper[player];
    final playerBody = bodyMapper[player];

    if (!playerStatus.invisible) {
      for (final entity in entities) {
        final pos = positionMapper[entity];
        final body = bodyMapper[entity];

        if (doCirclesCollide(pos.x, pos.y, body.radius, playerPos.x,
            playerPos.y, playerBody.radius)) {
          playerStatus.lifes--;
          playerStatus.invisiblityTimer = 5000;
          playerPos
            ..x = maxWidth ~/ 2
            ..y = maxHeight ~/ 2;
          return;
        }
      }
    } else {
      playerStatus.invisiblityTimer -= world.delta;
    }
  }

  @override
  bool checkProcessing() => true;
}
