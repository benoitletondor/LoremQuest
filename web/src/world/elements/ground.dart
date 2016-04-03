part of rpg;

class GroundElement extends Element {
  static const int CATEGORY_BITS = 1 << 2;

  GroundElement(PIXI.Texture texture, PIXI.Rectangle rectangle)
      : super(texture, rectangle, ElementType.GROUND);

  @override
  int get categoryBit => CATEGORY_BITS;
}
