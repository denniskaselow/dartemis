part of darteroids;

class CircularBody extends Component {
  num radius;
  String color;
  CircularBody.down(this.radius, this.color);
}

class Position extends Component {
  num _x, _y;
  Position(this._x, this._y);

  set x(num x) => _x = x % maxWidth;
  num get x => _x;

  set y(num y) => _y = y % maxHeight;
  num get y => _y;
}

class Velocity extends Component {
  num x, y;
  Velocity([this.x = 0, this.y = 0]);
}

class PlayerDestroyer extends Component {}

class AsteroidDestroyer extends Component {}

class Cannon extends Component {
  bool shoot = false;
  num targetX, targetY;
  num cooldown = 0;

  void target(num targetX, num targetY) {
    this.targetX = targetX;
    this.targetY = targetY;
  }

  bool get canShoot => shoot && cooldown <= 0;
}

class Decay extends Component {
  num timer;
  Decay(this.timer);
}

class Status extends Component {
  int lifes;
  num invisiblityTimer;

  Status({this.lifes = 1, this.invisiblityTimer = 0});

  bool get invisible => invisiblityTimer > 0;
}
