part of rpg;

abstract class Mob extends PIXI.Sprite
    implements LevelUp.PhysicsItem, Clickable {
  static const int CATEGORY_BITS = 1 << 3;
  static const int BASE_SPEED = 50;
  static const int BASE_ATTACK_RATE = 1000;
  static const int BASE_POWER = 10;

  MobType _type;
  int _mapX;
  int _mapY;

  num lastAttackTime = 0;
  bool attacking = false;
  int get speed => BASE_SPEED * _speedMultiplier;
  double get attackTiming => BASE_ATTACK_RATE / _attackRate;
  int get attackPower => BASE_POWER * _powerMultiplier;

  int _frameIndex = 0;
  int _attackingFrameIndex = 0;
  num _lastFrameUpdate = 0;

  MobType get type => _type;
  int get mapX => _mapX;
  int get mapY => _mapY;

  Mob(PIXI.Texture texture, MobType this._type, this._mapX, this._mapY)
      : super(texture.clone()) {
    this.anchor = new PIXI.Point.fromValues(0.5, 0.5);
  }

  int get _speedMultiplier;
  int get _attackRate;
  int get _powerMultiplier;
  int health;
  List<PIXI.Rectangle> get _frames;
  List<PIXI.Rectangle> get _attackingFrames;

  @override
  Body body;

  @override
  BodyDef get bodyDef => new BodyDef()
    ..type = BodyType.DYNAMIC
    ..fixedRotation = true;

  @override
  FixtureDef buildFixtureDef() {
    PolygonShape shape = new PolygonShape()..setAsBoxXY(width / 2, height / 2);

    Filter filter = new Filter()
      ..categoryBits = CATEGORY_BITS
      ..maskBits =
          WallElement.CATEGORY_BITS | Player.CATEGORY_BITS | Mob.CATEGORY_BITS;

    return new FixtureDef()
      ..shape = shape
      ..density = 500000.0
      ..restitution = 0.0
      ..friction = 50000.0
      ..filter = filter;
  }

  stop() {
    if (body.linearVelocity.x != 0.0 || body.linearVelocity.y != 0.0) {
      body.linearVelocity = new Vector2(0.0, 0.0);
    }

    if (body.angularVelocity != 0.0) {
      body.angularVelocity = 0.0;
    }
  }

  frameAnimation(num dt) {
    if( attacking ) {
      if (dt - _lastFrameUpdate >= (attackTiming / 4)) {
        _lastFrameUpdate = dt;

        _attackingFrameIndex++;
        if( _attackingFrameIndex >= _attackingFrames.length ) {
          _attackingFrameIndex = 0;
        }

        texture.frame = _attackingFrames[_attackingFrameIndex];
      }
    }
    else if( body.linearVelocity.x != 0.0 || body.linearVelocity.y != 0.0 ) {
      if (dt - _lastFrameUpdate >= (100 * _speedMultiplier)) {
        _lastFrameUpdate = dt;

        _frameIndex++;
        if( _frameIndex >= _frames.length ) {
          _frameIndex = 0;
        }

        texture.frame = _frames[_frameIndex];
      }
    }
  }
}

enum MobType { SPIDER }
