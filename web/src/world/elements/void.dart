part of rpg;

class VoidElement extends Element {
  static const int CATEGORY_BITS = 1 << 3;

  VoidElement() : super(PIXI.Texture.EMPTY, null, ElementType.VOID);

  @override
  int get categoryBit => CATEGORY_BITS;
}
