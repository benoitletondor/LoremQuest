part of rpg;

class BasicMob extends Mob {
  static const int SIZE = 15;

  BasicMob(int mapX, int mapY) : super(MobType.BASIC, mapX, mapY) {
    beginFill(0xFF0000);
    drawRect(-SIZE / 2, -SIZE / 2, SIZE, SIZE);
  }

  @override
  int get size => SIZE;

  @override
  int get speed => 1;

  @override
  int get _attackRate => 1;
}