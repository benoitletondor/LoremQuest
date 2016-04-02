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

void main() {
  world = new WorldMap("level1");
  world.load().then((WorldConfiguration configuration) {
    int worldSizeX = configuration.width * Element.SIZE;
    int worldSizeY = configuration.height * Element.SIZE;

    stage = new LevelUp.GameStage(
        new LevelUp.PixiRenderer(PIXI.autoDetectRenderer(640, 480)),
        new _ContactListener(),
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

    player = new LevelUp.PixiPhysicsItem(new Player())
      ..position = new PIXI.Point.fromValues(
          configuration.playerX * Element.SIZE,
          configuration.playerY * Element.SIZE);

    stage.setCameraFocus(player, 320, 240);

    world.draw(stage);
    stage.addChild(player);

    List<LevelUp.PixiPhysicsItem<Mob>> mobs = new List();

    for (Mob mob in configuration.mobs) {
      LevelUp.PixiPhysicsItem mobItem = new LevelUp.PixiPhysicsItem(mob)
        ..position = new PIXI.Point.fromValues(
            mob.mapX * Element.SIZE, mob.mapY * Element.SIZE);

      mobs.add(mobItem);
      stage.addChild(mobItem);
    }

    ia = new IA(player, mobs);

    html.Rectangle clientRect = stage.view.getBoundingClientRect();

    html.window.onResize.listen((e) {
      clientRect = stage.view.getBoundingClientRect();
    });

    html.document.onClick.listen((html.MouseEvent e) {
      math.Point clickPosition = new math.Point(
          e.client.x - clientRect.left + stage.cameraX,
          e.client.y - clientRect.top + stage.cameraY);

      List<LevelUp.PhysicsItem> itemsAtPoint = stage.getItemsInZone(
          new math.Rectangle(clickPosition.x, clickPosition.y, 0, 0));

      for (LevelUp.PhysicsItem physicItem in itemsAtPoint) {
        if (physicItem is LevelUp.PixiPhysicsItem &&
            physicItem.item is Clickable) {
          Logger.debug("Found item: ${physicItem.item}");
          return;
        }
      }

      player.item.moveTo(clickPosition);
    });
  });
}

class _ContactListener implements LevelUp.StageContactListener {
  void onContactBegin(
      LevelUp.Item spriteA, LevelUp.Item spriteB, Contact contact) {
    if ((spriteA.item is Player) && !(spriteB.item is Mob)) {
      player.item.stop();
    }

    if ((spriteB.item is Player) && !(spriteA.item is Mob)) {
      player.item.stop();
    }

    if ((spriteA.item is Mob) && !(spriteB.item is Mob)) {
      spriteA.item.stop();
    }

    if ((spriteB.item is Mob) && !(spriteA.item is Mob)) {
      spriteB.item.stop();
    }
  }

  void onContactEnd(
      LevelUp.Item spriteA, LevelUp.Item spriteB, Contact contact) {}
}
