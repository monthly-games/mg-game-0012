import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Year-End Raid Event RPG (MG-0012)
/// Raid JRPG + Event 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Raid/Combat Effects
  void showDamageNumber(Vector2 position, int damage, {bool isCritical = false, bool isBoss = false}) {
    gameRef.add(_DamageNumber(position: position, damage: damage, isCritical: isCritical, isBoss: isBoss));
  }

  void showHit(Vector2 position, {Color color = Colors.white, bool isCritical = false}) {
    gameRef.add(_createHitEffect(position: position, color: color, isCritical: isCritical));
  }

  void showBossPhaseTransition(Vector2 position) {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (!isMounted) return;
        gameRef.add(_createExplosionEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 80, (_random.nextDouble() - 0.5) * 60), color: i == 1 ? Colors.purple : Colors.red, count: 30, radius: 70));
      });
    }
    _triggerScreenShake(intensity: 10, duration: 0.8);
    gameRef.add(_PhaseText(position: position));
  }

  void showBossDefeat(Vector2 position) {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!isMounted) return;
        final offset = Vector2((_random.nextDouble() - 0.5) * 100, (_random.nextDouble() - 0.5) * 80);
        gameRef.add(_createExplosionEffect(position: position + offset, color: [Colors.orange, Colors.red, Colors.yellow][i % 3], count: 40, radius: 80));
      });
    }
    _triggerScreenShake(intensity: 15, duration: 1.2);
    gameRef.add(_VictoryText(position: position));
  }

  void showSkillActivation(Vector2 position, Color skillColor) {
    gameRef.add(_createConvergeEffect(position: position, color: skillColor));
    gameRef.add(_createGroundCircle(position: position, color: skillColor));
  }

  void showCoopAttack(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.cyan, count: 35, radius: 80));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 20));
    gameRef.add(_CoopText(position: position));
  }

  void showLootDrop(Vector2 position, {bool isRare = false}) {
    final color = isRare ? Colors.purple : Colors.blue;
    gameRef.add(_createSparkleEffect(position: position, color: color, count: isRare ? 18 : 10));
    if (isRare) gameRef.add(_createGroundCircle(position: position, color: Colors.purple));
  }

  void showEventBanner(Vector2 position) {
    gameRef.add(_createSparkleEffect(position: position, color: Colors.amber, count: 25));
    gameRef.add(_createRisingEffect(position: position, color: Colors.yellow, count: 15, speed: 80));
  }

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  void _triggerScreenShake({double intensity = 5, double duration = 0.3}) {
    if (gameRef.camera.viewfinder.children.isNotEmpty) {
      gameRef.camera.viewfinder.add(MoveByEffect(Vector2(intensity, 0), EffectController(duration: duration / 10, repeatCount: (duration * 10).toInt(), alternate: true)));
    }
  }

  // Private generators
  ParticleSystemComponent _createHitEffect({required Vector2 position, required Color color, required bool isCritical}) {
    final count = isCritical ? 22 : 12;
    final speed = isCritical ? 150.0 : 100.0;
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.4, generator: (i) {
      final angle = (i / count) * 2 * pi;
      final velocity = Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5));
      return AcceleratedParticle(position: position.clone(), speed: velocity, acceleration: Vector2(0, 200), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, (isCritical ? 5 : 3) * (1.0 - particle.progress * 0.5), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.8, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 100), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 14, lifespan: 0.5, generator: (i) {
      final startAngle = (i / 14) * 2 * pi;
      final startPos = Vector2(cos(startAngle), sin(startAngle)) * 55;
      return MovingParticle(from: position + startPos, to: position.clone(), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress * 0.5).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.5, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 55 + _random.nextDouble() * 45;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 45), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path();
        for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) path.moveTo(cos(a) * size, sin(a) * size); else path.lineTo(cos(a) * size, sin(a) * size); }
        path.close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createRisingEffect({required Vector2 position, required Color color, required int count, required double speed}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.9, generator: (i) {
      final spreadX = (_random.nextDouble() - 0.5) * 35;
      return AcceleratedParticle(position: position.clone() + Vector2(spreadX, 0), speed: Vector2(0, -speed), acceleration: Vector2(0, -20), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 3, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 1, lifespan: 0.7, generator: (i) {
      return ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        final radius = 18 + progress * 40;
        canvas.drawCircle(Offset(position.x, position.y), radius, Paint()..color = color.withOpacity(opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 3);
      });
    }));
  }
}

class _DamageNumber extends TextComponent {
  _DamageNumber({required Vector2 position, required int damage, required bool isCritical, required bool isBoss}) : super(text: '$damage', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: isBoss ? 32 : (isCritical ? 26 : 18), fontWeight: FontWeight.bold, color: isBoss ? Colors.orange : (isCritical ? Colors.yellow : Colors.white), shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -50), EffectController(duration: 0.8, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.8, startDelay: 0.3))); add(RemoveEffect(delay: 1.1)); }
}

class _PhaseText extends TextComponent {
  _PhaseText({required Vector2 position}) : super(text: 'PHASE CHANGE!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 2, shadows: [Shadow(color: Colors.purple, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.4, curve: Curves.elasticOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.5, startDelay: 1.0))); add(RemoveEffect(delay: 2.5)); }
}

class _VictoryText extends TextComponent {
  _VictoryText({required Vector2 position}) : super(text: 'RAID CLEAR!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 3, shadows: [Shadow(color: Colors.orange, blurRadius: 15)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.elasticOut))); add(RemoveEffect(delay: 3.5)); }
}

class _CoopText extends TextComponent {
  _CoopText({required Vector2 position}) : super(text: 'COMBO ATTACK!', position: position + Vector2(0, -50), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyan, shadows: [Shadow(color: Colors.blue, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.25, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.4))); add(RemoveEffect(delay: 1.4)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}
