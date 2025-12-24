import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'raid_manager.dart';
import 'components/boss_component.dart';
import 'components/hero_component.dart';

class RaidGame extends FlameGame with TapDetector {
  final RaidManager raidManager;

  RaidGame({required this.raidManager});

  @override
  Color backgroundColor() => const Color(0xFFCCE5FF); // Ice Blue

  @override
  Future<void> onLoad() async {
    // Background
    add(
      SpriteComponent()
        ..sprite = await loadSprite('bg_raid_winter.png')
        ..size = size
        ..priority = 0,
    );

    // Boss
    add(
      BossComponent(raidManager: raidManager)
        ..position = Vector2(size.x / 2, size.y / 2 - 50)
        ..priority = 10,
    );

    // Hero
    add(
      HeroComponent(raidManager: raidManager)
        ..position = Vector2(size.x / 2, size.y / 2 + 150)
        ..priority = 20,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    raidManager.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (raidManager.phase == RaidPhase.active) {
      // Manual skill / tap damage
      // Broadcast tap to hero?? Or just direct damage?
      // Let's call hero skill
      final hero = children.whereType<HeroComponent>().firstOrNull;
      hero?.useSkill();
    }
  }
}
