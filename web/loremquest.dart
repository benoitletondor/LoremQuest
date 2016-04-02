library rpg;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:levelup/levelup.dart' as LevelUp;
import 'package:pixi2dart/pixi2dart.dart' as PIXI;
import 'package:box2d/box2d.dart';
import 'package:box2d/box2d_browser.dart';

part 'src/logger.dart';
part 'src/player.dart';
part 'src/ia.dart';
part 'src/world/worldmap.dart';
part 'src/world/element.dart';
part 'src/world/mob.dart';
part 'src/world/clickable.dart';
part 'src/world/elements/ground.dart';
part 'src/world/elements/wall.dart';
part 'src/world/elements/void.dart';
part 'src/world/mobs/basic.dart';

LevelUp.GameStage stage;
WorldMap world;
LevelUp.PixiPhysicsItem<Player> player;
IA ia;
LevelUp.PixiItem<PIXI.Text> scoreText;

void main() {
  world = new WorldMap("level1");
  world.load().then((WorldConfiguration configuration) {
    int worldSizeX = configuration.width * Element.SIZE;
    int worldSizeY = configuration.height * Element.SIZE;

    player = new LevelUp.PixiPhysicsItem(new Player(_onPlayerHealthChanged))
      ..position = new PIXI.Point.fromValues(
          configuration.playerX * Element.SIZE,
          configuration.playerY * Element.SIZE);

    List<LevelUp.PixiPhysicsItem<Mob>> mobs = new List();

    ia = new IA(player, mobs);

    stage = new LevelUp.GameStage(
        new LevelUp.PixiRenderer(PIXI.autoDetectRenderer(640, 480)),
        ia,
        new LevelUp.Camera(
            0, 0, 640, 480, worldSizeX, worldSizeY, LevelUp.CameraAxis.BOTH));

    html.querySelector('#container').append(stage.view);

    // Activate debug
    /*html.CanvasElement canvas =
        (new html.Element.tag('canvas') as html.CanvasElement)
          ..width = 640
          ..height = 480;

    html.querySelector('#debug').append(canvas);
    stage.debugInCanvas(canvas);*/

    stage.setCameraFocus(player, 320, 240);

    world.draw(stage);
    stage.addChild(player);

    for (Mob mob in configuration.mobs) {
      LevelUp.PixiPhysicsItem mobItem = new LevelUp.PixiPhysicsItem(mob)
        ..position = new PIXI.Point.fromValues(
            mob.mapX * Element.SIZE, mob.mapY * Element.SIZE);

      mobs.add(mobItem);
      stage.addChild(mobItem);
    }

    scoreText = new LevelUp.PixiItem(new PIXI.Text(
        "Life: ${player.item.health}",
        new PIXI.TextStyle("24px Arial", tint: 0xFF00FF)))
      ..position = new PIXI.Point.fromValues(5, 5);
    stage.addChild(scoreText);

    ia.onStageReady(stage);

    html.Rectangle clientRect = stage.view.getBoundingClientRect();

    html.window.onResize.listen((e) {
      clientRect = stage.view.getBoundingClientRect();
    });

    html.document.onClick.listen((html.MouseEvent e) {
      math.Point clickPosition = new math.Point(
          e.client.x - clientRect.left + stage.cameraX,
          e.client.y - clientRect.top + stage.cameraY);

      ia.resolveClick(clickPosition);
    });
  });
}

_onPlayerHealthChanged(int health) {
  scoreText.item.text = "Life: ${health}";
}
