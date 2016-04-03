part of rpg;

abstract class Element extends PIXI.Sprite implements LevelUp.PhysicsItem {
  static const SIZE = 40;

  ElementType _type;

  Element(PIXI.Texture texture, PIXI.Rectangle frame, ElementType this._type)
      : super(texture.clone()) {
    if (frame != null) {
      this.texture.frame = frame;
    }

    width = SIZE;
    height = SIZE;
  }

  ElementType get type => _type;

  int get categoryBit;

  @override
  Body body;

  @override
  BodyDef get bodyDef => new BodyDef()..type = BodyType.KINEMATIC;

  @override
  FixtureDef buildFixtureDef() {
    double semiSize = (Element.SIZE / 2).toDouble();

    PolygonShape shape = new PolygonShape()
      ..setAsBox(semiSize, semiSize, new Vector2(semiSize, semiSize), 0.0);

    Filter filter = new Filter()..categoryBits = categoryBit;

    return new FixtureDef()
      ..shape = shape
      ..density = 0.0
      ..restitution = 0.0
      ..friction = 0.0
      ..filter = filter;
  }
}

enum ElementType { GROUND, WALL, VOID }
