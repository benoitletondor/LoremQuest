part of rpg;

class GroundElement extends Element {
  static const int CATEGORY_BITS = 1 << 2;

  GroundElement() : super(ElementType.GROUND) {
    beginFill(0xAABBCC);
    drawRect(0, 0, Element.SIZE, Element.SIZE);
  }

  @override
  int get categoryBit => CATEGORY_BITS;
}
