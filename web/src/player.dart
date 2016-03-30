part of rpg;

class Player extends PIXI.Graphics implements LevelUp.PhysicsItem {
  static const int CATEGORY_BITS = 0x1;
  static const int SIZE = 20;

  Body body;
  bool _watching = false;
  math.Point _destination;

  Player() : super() {
    beginFill(0xFF00FF);
    drawRect(-SIZE / 2, -SIZE / 2, SIZE, SIZE);
  }

// ------------------------------------------------------->

  FixtureDef buildFixtureDef() {
    double semiSize = (SIZE / 2).toDouble();

    PolygonShape shape = new PolygonShape()..setAsBoxXY(semiSize, semiSize);

    Filter filter = new Filter()
      ..categoryBits = CATEGORY_BITS
      ..maskBits = Wall.CATEGORY_BITS;

    return new FixtureDef()
      ..shape = shape
      ..density = 0.0
      ..restitution = 0.0
      ..friction = 0.0
      ..filter = filter;
  }

  BodyDef get bodyDef => new BodyDef()..type = BodyType.DYNAMIC;

  stop() {
    if (body.linearVelocity.x != 0.0 || body.linearVelocity.y != 0.0) {
      body.linearVelocity = new Vector2(0.0, 0.0);
    }

    if (body.angularVelocity != 0.0) {
      body.angularVelocity = 0.0;
    }

    _unsubscribe();
  }

  void set destination(math.Point destination) {
    _destination = destination;
    _subscribe();
  }

  _renderLoop(num dt) {
    if (_destination != null &&
        (body.position.x - _destination.x).abs() < 5.0 &&
        (body.position.y - _destination.y).abs() < 5.0) {
      stop();
    }
  }

  _subscribe() {
    if (_watching == true) {
      return;
    }

    _watching = true;

    LevelUp.RenderingManager.scheduleRenderingAction(_renderLoop);
  }

  _unsubscribe() {
    if (!_watching) {
      return;
    }

    _watching = false;

    LevelUp.RenderingManager.unscheduleRenderingAction(_renderLoop);
  }
}
