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
part 'src/world/worldmap.dart';
part 'src/world/element.dart';
part 'src/world/elements/ground.dart';
part 'src/world/elements/wall.dart';
part 'src/world/elements/void.dart';

LevelUp.GameStage stage;
WorldMap world;
LevelUp.PixiPhysicsItem<Player> player;

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
      ..position = new PIXI.Point.fromValues(300, 200);

    stage.setCameraFocus(player, 320, 240);

    world.draw(stage);
    stage.addChild(player);

    html.Rectangle clientRect = stage.view.getBoundingClientRect();

    html.window.onResize.listen((e) {
      clientRect = stage.view.getBoundingClientRect();
    });

    html.document.onClick.listen((html.MouseEvent e) {
      math.Point playerPosition =
          new math.Point(player.body.position.x, player.body.position.y);
      math.Point clickPosition = new math.Point(
          e.client.x - clientRect.left + stage.cameraX,
          e.client.y - clientRect.top + stage.cameraY);

      num angle = LevelUp.MathHelper
          .radianAngleBetweenMouseAndObject(clickPosition, playerPosition);

      player.item.destination = clickPosition;
      player.body.setTransform(player.body.position, angle);
      player.body.applyLinearImpulse(
          new Vector2(math.sin(angle) * 20000, -math.cos(angle) * 20000),
          new Vector2(player.body.worldCenter.x, player.body.worldCenter.y),
          true);
    });
  });
}

class _ContactListener implements LevelUp.StageContactListener {
  void onContactBegin(
      LevelUp.Item spriteA, LevelUp.Item spriteB, Contact contact) {
    if ((spriteA.item is Player) || (spriteB.item is Player)) {
      player.item.stop();
    }
  }

  void onContactEnd(
      LevelUp.Item spriteA, LevelUp.Item spriteB, Contact contact) {}
}
