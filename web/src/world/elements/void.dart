part of rpg;

class VoidElement extends Element {
  static const int CATEGORY_BITS = 1 << 3;

  VoidElement() : super(ElementType.VOID) {
    beginFill(0x000000);
    drawRect(0, 0, Element.SIZE, Element.SIZE);
  }

  @override
  int get categoryBit => CATEGORY_BITS;
}
