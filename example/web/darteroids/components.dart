part of darteroids;

class CircularBody implements Component {
  num radius;
  String color;

  CircularBody._();
  factory CircularBody(num radius, String color) {
    CircularBody body = new Component(CircularBody, _constructor);
    body.radius = radius;
    body.color = color;
    return body;
  }
  static CircularBody _constructor() => new CircularBody._();
}

class Position implements Component {
  num _x, _y;

  Position._();
  factory Position(num x, num y) {
    Position position = new Component(Position, _constructor);
    position.x = x;
    position.y = y;
    return position;
  }
  static Position _constructor() => new Position._();

  set x(num x) => _x = x % MAXWIDTH;
  get x => _x;

  set y(num y) => _y = y % MAXHEIGHT;
  get y => _y;
}

class Velocity implements Component {
  num x, y;

  Velocity._();
  factory Velocity([num x = 0, num y = 0]) {
    Velocity velocity = new Component(Velocity, _constructor);
    velocity.x = x;
    velocity.y = y;
    return velocity;
  }
  static Velocity _constructor() => new Velocity._();
}

class PlayerDestroyer implements Component {
  PlayerDestroyer._();
  factory PlayerDestroyer() => new Component(PlayerDestroyer, _constructor);
  static PlayerDestroyer _constructor() => new PlayerDestroyer._();
}

class AsteroidDestroyer implements Component {
  AsteroidDestroyer._();
  factory AsteroidDestroyer() => new Component(AsteroidDestroyer, _constructor);
  static AsteroidDestroyer _constructor() => new AsteroidDestroyer._();
}

class Cannon implements Component {
  bool shoot = false;
  num targetX, targetY;
  num cooldown = 0;

  Cannon._();
  factory Cannon() => new Component(Cannon, _constructor);
  static Cannon _constructor() => new Cannon._();

  void target(num targetX, num targetY) {
    this.targetX = targetX;
    this.targetY = targetY;
  }

  bool get canShoot {
    if (shoot && cooldown <= 0) return true;
    return false;
  }
}

class Decay implements Component {
  num timer;

  Decay._();
  factory Decay(num timer) {
    Decay decay = new Component(Decay, _constructor);
    decay.timer = timer;
    return decay;
  }
  static Decay _constructor() => new Decay._();
}

class Status implements Component {
  int lifes;
  num invisiblityTimer;

  Status._();
  factory Status({int lifes : 1, num invisiblityTimer : 0}) {
    Status status = new Component(Status, _constructor);
    status.lifes = lifes;
    status.invisiblityTimer = invisiblityTimer;
    return status;
  }
  static Status _constructor() => new Status._();

  bool get invisible => invisiblityTimer > 0;
}