part of rpg;

class IA {
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
    if( dt - timeSinceSync < 100 ) { // No more than once per 100 ms
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
    }
  }

  MobPosition _getMobPositionVsPlayer(math.Point mobPosition,
      math.Point playerPosition, LevelUp.PixiPhysicsItem<Mob> mob) {

    for (ContactEdge ce = mob.body.getContactList(); ce != null; ce = ce.next) {
      if (ce.other.userData is LevelUp.PixiPhysicsItem) {
        LevelUp.PixiPhysicsItem physicItem =
            ce.other.userData as LevelUp.PixiPhysicsItem;
        if (physicItem.item is Player) {
          return MobPosition.TOUCHING;
        }
      }
    }

    num deltaX = (mobPosition.x - playerPosition.x).abs();
    num deltaY = (mobPosition.y - playerPosition.y).abs();

    if (deltaX < 200 && deltaY < 200) {
      return MobPosition.NEAR;
    }

    return MobPosition.FAR;
  }
}

enum MobPosition { FAR, NEAR, TOUCHING }
