part of rpg;

class IA implements LevelUp.StageContactListener {
  LevelUp.PixiPhysicsItem<Player> _player;
  List<LevelUp.PixiPhysicsItem<Mob>> _mobs;
  num timeSinceSync = 0.0;

  IA(LevelUp.PixiPhysicsItem<Player> this._player,
      List<LevelUp.PixiPhysicsItem<Mob>> this._mobs) {
    assert(_player != null);
    assert(_mobs != null);

    LevelUp.RenderingManager.scheduleRenderingAction(_renderLoop);
  }

  _renderLoop(num dt) {
    if (dt - timeSinceSync < 200) {
      // No more than once per 200 ms
      return;
    }

    timeSinceSync = dt;

    math.Point playerPosition =
        new math.Point(_player.body.worldCenter.x, _player.body.worldCenter.y);

    for (LevelUp.PixiPhysicsItem<Mob> mob in _mobs) {
      math.Point mobPosition =
          new math.Point(mob.body.worldCenter.x, mob.body.worldCenter.y);

      switch (_getMobPositionVsPlayer(mobPosition, playerPosition, mob)) {
        case MobPosition.NEAR:
          num angle = LevelUp.MathHelper
              .radianAngleBetween2Objects(playerPosition, mobPosition);

          mob.body.setTransform(mob.body.position, angle);
          mob.body.linearVelocity = new Vector2(
              math.sin(angle) * mob.item.speed * Mob.BASE_SPEED,
              -math.cos(angle) * mob.item.speed * Mob.BASE_SPEED);
          break;
        case MobPosition.FAR:
          mob.item.stop();
          break;
        case MobPosition.TOUCHING:
          mob.item.stop();
          break;
      }

      if (mob.item.attacking &&
          (dt - mob.item.lastAttackTime) >= mob.item.attackTiming) {
        mob.item.lastAttackTime = dt;
        Logger.debug("${mob.item} attacks Player");
      }
    }
  }

  MobPosition _getMobPositionVsPlayer(math.Point mobPosition,
      math.Point playerPosition, LevelUp.PixiPhysicsItem<Mob> mob) {
    // FIXME find a better way to get a stage reference
    Contact contact = stage.getContactBetweenItems(mob, _player);
    if (contact != null) {
      mob.item.attacking = true;
      return MobPosition.TOUCHING;
    }

    mob.item.attacking = false;
    mob.item.lastAttackTime = 0.0;

    num deltaX = (mobPosition.x - playerPosition.x).abs();
    num deltaY = (mobPosition.y - playerPosition.y).abs();

    if (deltaX < 200 && deltaY < 200) {
      return MobPosition.NEAR;
    }

    return MobPosition.FAR;
  }

  resolveClick(math.Point clickPosition, LevelUp.GameStage stage) {
    List<LevelUp.PhysicsItem> itemsAtPoint = stage.getItemsInZone(
        new math.Rectangle(clickPosition.x, clickPosition.y, 0, 0));

    bool targetFound = false;

    for (LevelUp.PhysicsItem physicItem in itemsAtPoint) {
      if (physicItem is LevelUp.PixiPhysicsItem &&
          physicItem.item is Clickable) {
        Contact contact = stage.getContactBetweenItems(_player, physicItem);

        if (contact != null) {
          _player.item.target = null;
          _player.item.stop();
          Logger.debug("Attack ${physicItem.item}");
          return;
        } else {
          _player.item.target = physicItem.item;
          targetFound = true;
          break;
        }
      }
    }

    if (!targetFound) {
      _player.item.target = null;
    }

    _player.item.moveTo(clickPosition);
  }

  @override
  void onContactBegin(
      LevelUp.Item spriteA, LevelUp.Item spriteB, Contact contact) {
    if (spriteA.item is Player) {
      if (spriteB.item is Mob) {
        if (_player.item.target == spriteB.item) {
          Logger.debug("Attack ${spriteB.item}");
          _player.item.stop();
        }
      } else {
        _player.item.stop();
      }
    }

    if (spriteB.item is Player) {
      if (spriteA.item is Mob) {
        if (_player.item.target == spriteA.item) {
          Logger.debug("Attack ${spriteA.item}");
          _player.item.stop();
        }
      } else {
        _player.item.stop();
      }
    }

    if ((spriteA.item is Mob) && !(spriteB.item is Mob)) {
      spriteA.item.stop();
    }

    if ((spriteB.item is Mob) && !(spriteA.item is Mob)) {
      spriteB.item.stop();
    }
  }

  @override
  void onContactEnd(
      LevelUp.Item spriteA, LevelUp.Item spriteB, Contact contact) {}
}

enum MobPosition { FAR, NEAR, TOUCHING }
