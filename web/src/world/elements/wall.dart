part of rpg;

class Wall extends Element {
  static const int CATEGORY_BITS = 1 << 1;

  Wall() : super(ElementType.WALL) {
    beginFill(0xeeb223);
    drawRect(0, 0, Element.SIZE, Element.SIZE);
  }

  int get categoryBit => CATEGORY_BITS;
}
