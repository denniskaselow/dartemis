part of darteroids;

class CircularBody extends Component {
  CircularBody.hack();

  num radius;
  String color;

  CircularBody(this.radius, this.color);
}

class Position extends Component {
  Position.hack();

  num _x, _y;

  Position(this._x, this._y);

  set x(num x) => _x = x % MAXWIDTH;
  get x => _x;

  set y(num y) => _y = y % MAXHEIGHT;
  get y => _y;
}

class Velocity extends Component {
  Velocity.hack();

  num x, y;

  Velocity([this.x = 0, this.y = 0]);
}

class PlayerDestroyer extends Component {
  PlayerDestroyer.hack();
  PlayerDestroyer();
}

class Lives extends Component {
  Lives.hack();

  int amount;

  Lives(this.amount);
}

class Cannon extends Component {
  Cannon.hack();

  bool shoot = false;
  num targetX, targetY;
  num cooldown = 0;

  Cannon();

  void target(num targetX, num targetY) {
    this.targetX = targetX;
    this.targetY = targetY;
  }

  bool get canShoot {
    if (shoot && cooldown <= 0) return true;
    return false;
  }
}