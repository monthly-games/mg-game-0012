import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

/// Combo milestone thresholds with special effects
enum ComboMilestone {
  none(0, 1.0, ''),
  basic(5, 1.2, 'GOOD!'),
  great(10, 1.5, 'GREAT!'),
  excellent(15, 2.0, 'EXCELLENT!'),
  amazing(25, 3.0, 'AMAZING!'),
  legendary(50, 5.0, 'LEGENDARY!');

  final int threshold;
  final double multiplier;
  final String text;

  const ComboMilestone(this.threshold, this.multiplier, this.text);

  static ComboMilestone fromCount(int count) {
    if (count >= 50) return legendary;
    if (count >= 25) return amazing;
    if (count >= 15) return excellent;
    if (count >= 10) return great;
    if (count >= 5) return basic;
    return none;
  }
}

/// Manages combo system for raid battles
/// Rewards well-timed skill usage with damage multipliers
class ComboManager extends ChangeNotifier {
  int _comboCount = 0;
  double _decayTimer = 0.0;
  ComboMilestone _currentMilestone = ComboMilestone.none;

  // Configuration
  static const double comboDecayTime = 3.0; // seconds before combo resets
  static const double comboDecayWarning = 1.0; // seconds to show warning

  int get comboCount => _comboCount;
  double get decayTimer => _decayTimer;
  ComboMilestone get currentMilestone => _currentMilestone;
  double get damageMultiplier => _currentMilestone.multiplier;
  bool get isDecayWarning => _decayTimer <= comboDecayWarning && _decayTimer > 0;

  /// Called when player uses skill (not auto-attack)
  void addCombo() {
    _comboCount++;
    _decayTimer = comboDecayTime;

    final oldMilestone = _currentMilestone;
    _currentMilestone = ComboMilestone.fromCount(_comboCount);

    // Play milestone effects
    if (_currentMilestone != oldMilestone && _currentMilestone != ComboMilestone.none) {
      _playMilestoneEffect(_currentMilestone);
    }

    notifyListeners();
  }

  /// Update decay timer
  void update(double dt) {
    if (_comboCount == 0) return;

    _decayTimer -= dt;

    if (_decayTimer <= 0) {
      resetCombo();
    } else if (_decayTimer <= comboDecayWarning) {
      // Trigger warning state for UI
      notifyListeners();
    }
  }

  /// Reset combo counter
  void resetCombo() {
    if (_comboCount > 0) {
      _comboCount = 0;
      _decayTimer = 0;
      _currentMilestone = ComboMilestone.none;
      FlameAudio.play('sfx_combo_break.wav');
      notifyListeners();
    }
  }

  /// Get progress toward next milestone (0.0 to 1.0)
  double get progressToNextMilestone {
    if (_currentMilestone == ComboMilestone.legendary) return 1.0;

    final nextMilestone = ComboMilestone.values[_currentMilestone.index + 1];
    final currentThreshold = _currentMilestone.threshold;
    final nextThreshold = nextMilestone.threshold;

    if (nextThreshold <= currentThreshold) return 1.0;

    return (_comboCount - currentThreshold) / (nextThreshold - currentThreshold);
  }

  void _playMilestoneEffect(ComboMilestone milestone) {
    // Play sound effect
    FlameAudio.play('sfx_combo_milestone.wav');

    // Could add visual effects here via callback
    // For now, the UI will react to the milestone change
  }

  /// Get formatted combo text with milestone
  String get formattedCombo {
    if (_comboCount == 0) return '';
    return '${_currentMilestone.text} $_comboCount';
  }
}
