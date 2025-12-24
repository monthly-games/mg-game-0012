import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../raid_manager.dart';

class BossComponent extends SpriteComponent with HasGameRef {
  final RaidManager raidManager;
  double _lastHp = 0;

  BossComponent({required this.raidManager}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('boss_ice_golem.png');
    size = Vector2(150, 150); // Big boss
    _lastHp = raidManager.bossHp;

    // Listen to changes for hit callback?
    // Easier to check in update for simple prototype
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (raidManager.bossHp < _lastHp) {
      // Took damage
      _lastHp = raidManager.bossHp;
      // Hit effect
      add(
        ColorEffect(
          Colors.red,
          EffectController(duration: 0.1, alternate: true, repeatCount: 1),
          opacityTo: 0.7,
        ),
      );
      add(
        ScaleEffect.by(
          Vector2.all(1.1),
          EffectController(duration: 0.1, alternate: true, repeatCount: 1),
        ),
      );
    }
  }
}
