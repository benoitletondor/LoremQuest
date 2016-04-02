part of rpg;

typedef void HealthChangeListener(int health);

class Player extends PIXI.Graphics implements LevelUp.PhysicsItem {
  static const int CATEGORY_BITS = 0x1;
  static const int SIZE = 20;
  static const int BASE_HEALTH = 1000;
  static const int BASE_SPEED = 100000;

  @override
  Body body;

  bool _watching = false;
  math.Point _destination = null;
  Mob target = null;

  HealthChangeListener _healthListener;
  int _health = BASE_HEALTH;
  int get health => _health;
  set health(int value) {
    _health = value;
    if( _healthListener != null ) {
      _healthListener(value);
    }
  }

  int get attackPower => 50;

  Player() : super() {
    beginFill(0xFF00FF);
    drawRect(-SIZE / 2, -SIZE / 2, SIZE, SIZE);
  }

// ------------------------------------------------------->

  @override
  FixtureDef buildFixtureDef() {
    double semiSize = (SIZE / 2).toDouble();

    PolygonShape shape = new PolygonShape()..setAsBoxXY(semiSize, semiSize);

    Filter filter = new Filter()
      ..categoryBits = CATEGORY_BITS
      ..maskBits = WallElement.CATEGORY_BITS | Mob.CATEGORY_BITS;

    return new FixtureDef()
      ..shape = shape
      ..density = 10.0
      ..restitution = 0.0
      ..friction = 0.0
      ..filter = filter;
  }

  @override
  BodyDef get bodyDef => new BodyDef()
    ..type = BodyType.STATIC
    ..fixedRotation = true;

  set healthListener(HealthChangeListener listener) =>
    _healthListener = listener;

  stop() {
    _destination = null;
    body.setType(BodyType.STATIC);

    if (body.linearVelocity.x != 0.0 || body.linearVelocity.y != 0.0) {
      body.linearVelocity = new Vector2(0.0, 0.0);
    }

    if (body.angularVelocity != 0.0) {
      body.angularVelocity = 0.0;
    }

    _unsubscribe();
  }

  void moveTo(math.Point destination) {
    _destination = destination;
    body.setType(BodyType.DYNAMIC);
    _subscribe();
  }

  _renderLoop(num dt) {
    if (_destination != null) {
      if ((body.position.x - _destination.x).abs() < 5.0 &&
          (body.position.y - _destination.y).abs() < 5.0) {
        stop();
      } else {
        math.Point playerPosition =
            new math.Point(body.position.x, body.position.y);

        num angle = LevelUp.MathHelper
            .radianAngleBetween2Objects(_destination, playerPosition);

        body.setTransform(body.position, angle);
        body.linearVelocity = new Vector2(
            math.sin(angle) * Player.BASE_SPEED,
            -math.cos(angle) * Player.BASE_SPEED);
      }
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
