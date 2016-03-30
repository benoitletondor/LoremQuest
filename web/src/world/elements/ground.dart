part of rpg;

class Ground extends Element {
  static const int CATEGORY_BITS = 1 << 2;

  Ground() : super(ElementType.GROUND) {
    beginFill(0xAABBCC);
    drawRect(0, 0, Element.SIZE, Element.SIZE);
  }

  int get categoryBit => CATEGORY_BITS;
}
