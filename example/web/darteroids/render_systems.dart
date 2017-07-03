part of darteroids;

class CircleRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D context;

  Mapper<Position> positionMapper;
  Mapper<CircularBody> bodyMapper;
  Mapper<Status> statusMapper;

  CircleRenderingSystem(this.context)
      : super(new Aspect.forAllOf([Position, CircularBody]));

  @override
  void processEntity(Entity entity) {
    Position pos = positionMapper[entity];
    CircularBody body = bodyMapper[entity];
    Status status = statusMapper.getSafe(entity);

    context.save();

    try {
      context
        ..lineWidth = 0.5
        ..fillStyle = body.color
        ..strokeStyle = body.color;
      if (null != status && status.invisible) {
        if (status.invisiblityTimer % 600 < 300) {
          context.globalAlpha = 0.4;
        }
      }

      drawCirle(pos, body);

      if (pos.x + body.radius > maxWidth) {
        drawCirle(pos, body, offsetX: -maxWidth);
      } else if (pos.x - body.radius < 0) {
        drawCirle(pos, body, offsetX: maxWidth);
      }
      if (pos.y + body.radius > maxHeight) {
        drawCirle(pos, body, offsetY: -maxHeight);
      } else if (pos.y - body.radius < 0) {
        drawCirle(pos, body, offsetY: maxHeight);
      }

      context.stroke();
    } finally {
      context.restore();
    }
  }

  void drawCirle(Position pos, CircularBody body,
      {int offsetX: 0, int offsetY: 0}) {
    context
      ..beginPath()
      ..arc(pos.x + offsetX, pos.y + offsetY, body.radius, 0, PI * 2, false)
      ..closePath()
      ..fill();
  }
}

class BackgroundRenderSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context;

  BackgroundRenderSystem(this.context);

  @override
  void processSystem() {
    context.save();
    try {
      context
        ..fillStyle = "black"
        ..beginPath()
        ..rect(0, 0, maxWidth, maxHeight + hudHeight)
        ..closePath()
        ..fill();
    } finally {
      context.restore();
    }
  }
}

class HudRenderSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context;
  TagManager tagManager;
  Mapper<Status> statusMapper;

  HudRenderSystem(this.context);

  @override
  void processSystem() {
    context.save();
    try {
      context
        ..fillStyle = "#555"
        ..beginPath()
        ..rect(0, maxHeight, maxWidth, maxHeight + hudHeight)
        ..closePath()
        ..fill();

      Entity player = tagManager.getEntity(tagPlayer);
      Status status = statusMapper[player];

      context.fillStyle = playerColor;
      for (int i = 0; i < status.lifes; i++) {
        context
          ..beginPath()
          ..arc(50 + i * 50, maxHeight + hudHeight ~/ 2, 15, 0, PI * 2, false)
          ..closePath()
          ..fill();
      }
    } finally {
      context.restore();
    }
  }
}
