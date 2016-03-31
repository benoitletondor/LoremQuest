part of rpg;

class WallElement extends Element {
  static const int CATEGORY_BITS = 1 << 1;

  WallElement() : super(ElementType.WALL) {
    beginFill(0xeeb223);
    drawRect(0, 0, Element.SIZE, Element.SIZE);
  }

  @override
  int get categoryBit => CATEGORY_BITS;
}
