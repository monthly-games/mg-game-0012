import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../raid_manager.dart';
import '../combo_manager.dart';

/// Widget displaying current combo with milestone effects and decay timer
class ComboDisplay extends StatefulWidget {
  const ComboDisplay({super.key});

  @override
  State<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends State<ComboDisplay>
    with SingleTickerProviderStateMixin {
  late RaidManager raidManager;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    raidManager = GetIt.I<RaidManager>();
    raidManager.comboManager.addListener(_onComboChanged);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    raidManager.comboManager.removeListener(_onComboChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onComboChanged() {
    if (mounted) {
      setState(() {});

      // Pulse animation on milestone changes
      if (raidManager.comboManager.currentMilestone != ComboMilestone.none) {
        _pulseController.forward().then((_) => _pulseController.reverse());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final comboManager = raidManager.comboManager;

    if (comboManager.comboCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Combo Counter with Milestone
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getMilestoneColor(comboManager.currentMilestone),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getMilestoneColor(comboManager.currentMilestone)
                        .withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (comboManager.currentMilestone != ComboMilestone.none) ...[
                    Text(
                      comboManager.currentMilestone.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${comboManager.comboCount}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Decay Timer Bar
            SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Multiplier Text
                  Text(
                    '${comboManager.damageMultiplier.toStringAsFixed(1)}x DMG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: comboManager.isDecayWarning
                              ? Colors.red
                              : Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Progress Bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: comboManager.decayTimer / ComboManager.comboDecayTime,
                      child: Container(
                        decoration: BoxDecoration(
                          color: comboManager.isDecayWarning
                              ? Colors.red
                              : Colors.green,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Milestone Progress
                  if (comboManager.currentMilestone != ComboMilestone.legendary)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Next: ${_getNextMilestoneThreshold(comboManager.currentMilestone)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMilestoneColor(ComboMilestone milestone) {
    switch (milestone) {
      case ComboMilestone.none:
        return Colors.grey;
      case ComboMilestone.basic:
        return Colors.green;
      case ComboMilestone.great:
        return Colors.blue;
      case ComboMilestone.excellent:
        return Colors.purple;
      case ComboMilestone.amazing:
        return Colors.orange;
      case ComboMilestone.legendary:
        return Colors.red;
    }
  }

  int _getNextMilestoneThreshold(ComboMilestone current) {
    if (current == ComboMilestone.legendary) return 50;
    final nextIndex = current.index + 1;
    return ComboMilestone.values[nextIndex].threshold;
  }
}
