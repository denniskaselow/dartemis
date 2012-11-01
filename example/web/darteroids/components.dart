part of darteroids;

class PhysicalBody extends Component {
  PhysicalBody.hack();

  num radius;
  String color;

  PhysicalBody(this.radius, this.color);
}

class Position extends Component {
  Position.hack();

  num _x;
  num _y;

  Position(this._x, this._y);

  set x(num x) => _x = x % MAXWIDTH;
  get x => _x;

  set y(num y) => _y = y % MAXHEIGHT;
  get y => _y;
}

class Velocity extends Component {
  Velocity.hack();

  num x;
  num y;

  Velocity([this.x = 0, this.y = 0]);
}