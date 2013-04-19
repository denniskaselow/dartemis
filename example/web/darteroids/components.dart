part of darteroids;

class CircularBody extends FreeListComponent {
  num radius;
  String color;

  CircularBody._();
  factory CircularBody(num radius, String color) {
    CircularBody body = new FreeListComponent.of(CircularBody, _constructor);
    body.radius = radius;
    body.color = color;
    return body;
  }
  static CircularBody _constructor() => new CircularBody._();
}

class Position extends FreeListComponent {
  num _x, _y;

  Position._();
  factory Position(num x, num y) {
    Position position = new FreeListComponent.of(Position, _constructor);
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

class Velocity extends FreeListComponent {
  num x, y;

  Velocity._();
  factory Velocity([num x = 0, num y = 0]) {
    Velocity velocity = new FreeListComponent.of(Velocity, _constructor);
    velocity.x = x;
    velocity.y = y;
    return velocity;
  }
  static Velocity _constructor() => new Velocity._();
}

class PlayerDestroyer extends FreeListComponent {
  PlayerDestroyer._();
  factory PlayerDestroyer() => new FreeListComponent.of(PlayerDestroyer, _constructor);
  static PlayerDestroyer _constructor() => new PlayerDestroyer._();
}

class AsteroidDestroyer extends FreeListComponent {
  AsteroidDestroyer._();
  factory AsteroidDestroyer() => new FreeListComponent.of(AsteroidDestroyer, _constructor);
  static AsteroidDestroyer _constructor() => new AsteroidDestroyer._();
}

class Cannon extends Component {
  bool shoot = false;
  num targetX, targetY;
  num cooldown = 0;

  void target(num targetX, num targetY) {
    this.targetX = targetX;
    this.targetY = targetY;
  }

  bool get canShoot {
    if (shoot && cooldown <= 0) return true;
    return false;
  }
}

class Decay extends FreeListComponent {
  num timer;

  Decay._();
  factory Decay(num timer) {
    Decay decay = new FreeListComponent.of(Decay, _constructor);
    decay.timer = timer;
    return decay;
  }
  static Decay _constructor() => new Decay._();
}

class Status extends Component {
  int lifes;
  num invisiblityTimer;

  Status({this.lifes : 1, this.invisiblityTimer : 0});

  bool get invisible => invisiblityTimer > 0;
}