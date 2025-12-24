import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';
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

  void _performAttack(bool isSkill) {
    final damage = isSkill ? _skillDamage : _autoDamage;
    raidManager.dealDamage(damage);

    // Visuals
    final targetPos = Vector2(position.x, position.y - 100);
    // We could spawn a projectile or just a move effect

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
