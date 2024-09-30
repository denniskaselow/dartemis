part of '../main.dart';

class CircleRenderingSystem extends EntityProcessingSystem {
  final CanvasRenderingContext2D context;

  late final Mapper<Position> positionMapper;
  late final Mapper<CircularBody> bodyMapper;
  late final Mapper<Status> statusMapper;

  CircleRenderingSystem(this.context, {super.group})
      : super(Aspect.forAllOf([Position, CircularBody]));

  @override
  void initialize(World world) {
    super.initialize(world);
    positionMapper = Mapper<Position>(world);
    statusMapper = Mapper<Status>(world);
    bodyMapper = Mapper<CircularBody>(world);
  }

  @override
  void processEntity(Entity entity) {
    final pos = positionMapper[entity];
    final body = bodyMapper[entity];
    final status = statusMapper.getSafe(entity);

    context.save();

    try {
      context
        ..lineWidth = 0.5
        ..fillStyle = body.color.toJS
        ..strokeStyle = body.color.toJS;
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

  void drawCirle(
    Position pos,
    CircularBody body, {
    int offsetX = 0,
    int offsetY = 0,
  }) {
    context
      ..beginPath()
      ..arc(pos.x + offsetX, pos.y + offsetY, body.radius, 0, pi * 2)
      ..closePath()
      ..fill();
  }
}

class BackgroundRenderSystem extends VoidEntitySystem {
  final CanvasRenderingContext2D context;

  BackgroundRenderSystem(this.context, {super.group});

  @override
  void processSystem() {
    context.save();
    try {
      context
        ..fillStyle = 'black'.toJS
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
  final CanvasRenderingContext2D context;
  late final TagManager tagManager;
  late final Mapper<Status> statusMapper;

  HudRenderSystem(this.context, {super.group});

  @override
  void initialize(World world) {
    super.initialize(world);
    tagManager = world.getManager<TagManager>();
    statusMapper = Mapper<Status>(world);
  }

  @override
  void processSystem() {
    context.save();
    try {
      context
        ..fillStyle = '#555'.toJS
        ..beginPath()
        ..rect(0, maxHeight, maxWidth, maxHeight + hudHeight)
        ..closePath()
        ..fill();

      final player = tagManager.getEntity(tagPlayer)!;
      final status = statusMapper[player];

      context.fillStyle = playerColor.toJS;
      for (var i = 0; i < status.lifes; i++) {
        context
          ..beginPath()
          ..arc(50 + i * 50, maxHeight + hudHeight ~/ 2, 15, 0, pi * 2)
          ..closePath()
          ..fill();
      }
    } finally {
      context.restore();
    }
  }
}
