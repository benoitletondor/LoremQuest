part of rpg;

class WallElement extends Element {
  static const int CATEGORY_BITS = 1 << 1;

  WallElement(PIXI.Texture texture, PIXI.Rectangle frame)
      : super(texture, frame, ElementType.WALL);

  @override
  int get categoryBit => CATEGORY_BITS;
}
