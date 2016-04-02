part of rpg;

abstract class Mob extends PIXI.Graphics implements LevelUp.PhysicsItem, Clickable {
  static const int CATEGORY_BITS = 1 << 3;
  static const int BASE_SPEED = 50;
  static const int BASE_ATTACK_RATE = 1000;

  MobType _type;
  int _mapX;
  int _mapY;

  Mob(MobType this._type, this._mapX, this._mapY);

  MobType get type => _type;
  int get mapX => _mapX;
  int get mapY => _mapY;

  int get size;
  int get speed;
  int get _attackRate;

  num lastAttackTime = 0;
  bool attacking = false;
  double get attackTiming => BASE_ATTACK_RATE / _attackRate;

  @override
  Body body;

  @override
  BodyDef get bodyDef => new BodyDef()
    ..type = BodyType.DYNAMIC
    ..fixedRotation = true;

  @override
  FixtureDef buildFixtureDef() {
    int mobSize = size;

    double semiSize = (mobSize / 2).toDouble();

    PolygonShape shape = new PolygonShape()..setAsBoxXY(semiSize, semiSize);

    Filter filter = new Filter()
      ..categoryBits = CATEGORY_BITS
      ..maskBits = WallElement.CATEGORY_BITS | Player.CATEGORY_BITS | Mob.CATEGORY_BITS;

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
}

enum MobType { BASIC }
