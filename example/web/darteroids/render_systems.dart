part of darteroids;

class CircleRenderingSystem extends EntityProcessingSystem {

  CanvasRenderingContext2D context;

  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;
  ComponentMapper<Status> statusMapper;

  CircleRenderingSystem(this.context) : super(Aspect.getAspectForAllOf([Position, CircularBody]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    bodyMapper = new ComponentMapper<CircularBody>(CircularBody, world);
    statusMapper = new ComponentMapper<Status>(Status, world);
  }

  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    CircularBody body = bodyMapper.get(entity);
    Status status = statusMapper.getSafe(entity);

    context.save();

    try {
      context.lineWidth = 0.5;
      context.fillStyle = body.color;
      context.strokeStyle = body.color;
      if (null != status && status.invisible) {
        if (status.invisiblityTimer % 600 < 300) {
          context.globalAlpha = 0.4;
        }
      }

      drawCirle(pos, body);

      if (pos.x + body.radius > MAXWIDTH) {
        drawCirle(pos, body, offsetX : -MAXWIDTH);
      } else if (pos.x - body.radius < 0) {
        drawCirle(pos, body, offsetX : MAXWIDTH);
      }
      if (pos.y + body.radius > MAXHEIGHT) {
        drawCirle(pos, body, offsetY : -MAXHEIGHT);
      } else if (pos.y - body.radius < 0) {
        drawCirle(pos, body, offsetY : MAXHEIGHT);
      }


      context.stroke();
    } finally {
      context.restore();
    }
  }

  void drawCirle(Position pos, CircularBody body, {int offsetX : 0, int offsetY : 0}) {
    context.beginPath();

    context.arc(pos.x + offsetX, pos.y + offsetY, body.radius, 0, PI * 2, false);

    context.closePath();
    context.fill();
  }
}

class BackgroundRenderSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context;

  BackgroundRenderSystem(this.context);

  void processSystem() {
    context.save();
    try {
      context.fillStyle = "black";

      context.beginPath();
      context.rect(0, 0, MAXWIDTH, MAXHEIGHT + HUDHEIGHT);
      context.closePath();

      context.fill();
    } finally {
      context.restore();
    }
  }
}

class HudRenderSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context;
  TagManager tagManager;
  ComponentMapper<Status> statusMapper;

  HudRenderSystem(this.context);

  void initialize() {
    tagManager = world.getManager(new TagManager().runtimeType);
    statusMapper = new ComponentMapper<Status>(Status, world);
  }

  void processSystem() {
    context.save();
    try {
      context.fillStyle = "#555";

      context.beginPath();
      context.rect(0, MAXHEIGHT, MAXWIDTH, MAXHEIGHT + HUDHEIGHT);
      context.closePath();

      context.fill();

      Entity player = tagManager.getEntity(TAG_PLAYER);
      Status status = statusMapper.get(player);

      context.fillStyle = PLAYER_COLOR;
      for (int i = 0; i < status.lifes; i++) {

        context.beginPath();
        context.arc(50 + i * 50, MAXHEIGHT + HUDHEIGHT~/2, 15, 0, PI * 2, false);
        context.closePath();

        context.fill();
      }

    } finally {
      context.restore();
    }
  }
}