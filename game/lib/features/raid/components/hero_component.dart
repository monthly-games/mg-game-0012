import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../raid_manager.dart';

class HeroComponent extends SpriteComponent with HasGameRef {
  final RaidManager raidManager;

  // Auto Attack
  double _attackTimer = 0.0;
  final double _attackInterval = 1.0;
  final double _autoDamage = 50.0;
  final double _skillDamage = 200.0;

  HeroComponent({required this.raidManager}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('hero_knight_winter.png');
    size = Vector2(64, 64);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (raidManager.phase != RaidPhase.active) return;

    _attackTimer += dt;
    if (_attackTimer >= _attackInterval) {
      _attackTimer = 0;
      _performAttack(false);
    }
  }

  void useSkill() {
    _performAttack(true);
  }

  Future<void> _performAttack(bool isSkill) async {
    final damage = isSkill ? _skillDamage : _autoDamage;
    raidManager.dealDamage(damage);

    // Audio
    if (isSkill) {
      FlameAudio.play('sfx_skill.wav');
    } else {
      FlameAudio.play('sfx_attack.wav');
    }

    // Visuals
    final targetPos = Vector2(position.x, position.y - 100);

    // Spawn VFX if skill
    if (isSkill) {
      gameRef.add(
        SpriteComponent()
          ..sprite = await gameRef.loadSprite('vfx_ice_shard.png')
          ..position = targetPos
          ..size = Vector2(64, 64)
          ..anchor = Anchor.center
          ..priority = 15
          ..add(
            SequenceEffect([
              MoveEffect.by(Vector2(0, -50), EffectController(duration: 0.5)),
              OpacityEffect.fadeOut(EffectController(duration: 0.2)),
              RemoveEffect(),
            ]),
          ),
      );
    }

    add(
      MoveEffect.by(
        Vector2(0, -20),
        EffectController(duration: 0.1, alternate: true),
      ),
    );

    // If skill, maybe bigger shake or color
    if (isSkill) {
      add(
        ColorEffect(
          Colors.blue,
          EffectController(duration: 0.2, alternate: true),
          opacityTo: 0.8,
        ),
      );
    }
  }
}
