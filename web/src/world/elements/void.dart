part of rpg;

class Void extends Element {
  static const int CATEGORY_BITS = 1 << 3;

  Void() : super(ElementType.VOID) {
    beginFill(0x000000);
    drawRect(0, 0, Element.SIZE, Element.SIZE);
  }

  int get categoryBit => CATEGORY_BITS;
}
