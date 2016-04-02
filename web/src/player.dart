part of rpg;

typedef void HealthChangeListener(int health);

class Player extends PIXI.Sprite implements LevelUp.PhysicsItem {
  static const int CATEGORY_BITS = 0x1;
  static const int BASE_HEALTH = 1000;
  static const int BASE_SPEED = 100000;

  static const int FRAME_WIDTH = 66;
  static List<PIXI.Rectangle> frames = <PIXI.Rectangle>[
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*0, 0, FRAME_WIDTH, 78),
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*1, 0, FRAME_WIDTH, 78),
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*2, 0, FRAME_WIDTH, 78)
  ];

  @override
  Body body;

  bool _watching = false;
  math.Point _destination = null;
  Mob target = null;

  int _frameIndex = 0;
  num _lastFrameUpdate = 0;

  HealthChangeListener _healthListener;
  int _health = BASE_HEALTH;
  int get health => _health;
  set health(int value) {
    _health = value;
    if (_healthListener != null) {
      _healthListener(value);
    }
  }

  int get attackPower => 50;

  Player(PIXI.Texture texture) : super(texture) {
    this.width /= 2;
    this.height /= 2;
    this.anchor = new PIXI.Point.fromValues(0.5, 0.5);
  }

// ------------------------------------------------------->

  @override
  FixtureDef buildFixtureDef() {
    PolygonShape shape = new PolygonShape()..setAsBoxXY(width / 2, height / 2);

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
        body.linearVelocity = new Vector2(math.sin(angle) * Player.BASE_SPEED,
            -math.cos(angle) * Player.BASE_SPEED);
      }
    }
  }

  frameAnimation(num dt) {
    if (_destination != null && dt - _lastFrameUpdate >= 150) {
      _lastFrameUpdate = dt;

      _frameIndex++;
      if( _frameIndex >= frames.length ) {
        _frameIndex = 0;
      }

      texture.frame = frames[_frameIndex];
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
