part of rpg;

class Animator {
  LevelUp.PixiPhysicsItem<Player> _player;
  List<LevelUp.PixiPhysicsItem<Mob>> _mobs;

  Animator(LevelUp.PixiPhysicsItem<Player> this._player,
      List<LevelUp.PixiPhysicsItem<Mob>> this._mobs) {
    assert(_player != null);
    assert(_mobs != null);
  }

  start() {
    LevelUp.RenderingManager.scheduleRenderingAction(_animateLoop);
  }

  destroy() {
    LevelUp.RenderingManager.unscheduleRenderingAction(_animateLoop);
  }

  _animateLoop(num dt) {
    for(LevelUp.PixiPhysicsItem<Mob> mob in _mobs) {
      mob.item.frameAnimation(dt);
    }

    _player.item.frameAnimation(dt);
  }
}