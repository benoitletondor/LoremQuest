part of rpg;

class SpiderMob extends Mob {
  static const int FRAME_WIDTH = 63;
  static List<PIXI.Rectangle> frames = <PIXI.Rectangle>[
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*4, 0, FRAME_WIDTH, 41),
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*5, 0, FRAME_WIDTH, 41),
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*6, 0, FRAME_WIDTH, 41),
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*7, 0, FRAME_WIDTH, 41),
    new PIXI.Rectangle.fromValues(FRAME_WIDTH*8, 0, FRAME_WIDTH, 41)
  ];

  SpiderMob(PIXI.Texture texture, int mapX, int mapY)
      : super(texture, MobType.BASIC, mapX, mapY) {
    width /= 2;
    height /= 2;
  }

  @override
  int get _speedMultiplier => 1;

  @override
  int get _attackRate => 1;

  @override
  int get _powerMultiplier => 5;

  @override
  int health = 100;

  @override
  List<PIXI.Rectangle> get _frames => frames;
}
