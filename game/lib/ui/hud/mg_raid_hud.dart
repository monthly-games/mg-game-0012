import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI 기반 레이드 게임 HUD
/// mg_common_game의 공통 UI 컴포넌트 활용
class MGRaidHud extends StatelessWidget {
  final int gold;
  final double currentTime;
  final double totalTime;
  final int totalDps;
  final int bossHp;
  final int bossMaxHp;
  final String? bossName;
  final VoidCallback? onPause;

  const MGRaidHud({
    super.key,
    required this.gold,
    required this.currentTime,
    required this.totalTime,
    this.totalDps = 0,
    this.bossHp = 0,
    this.bossMaxHp = 100,
    this.bossName,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Positioned.fill(
      child: Column(
        children: [
          // 상단 HUD: 골드 + 일시정지
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 골드 표시
                MGResourceBar(
                  icon: Icons.monetization_on,
                  value: _formatNumber(gold),
                  iconColor: MGColors.gold,
                  onTap: null,
                ),

                // DPS 표시
                _buildDpsDisplay(),

                // 일시정지 버튼
                MGIconButton(
                  icon: Icons.pause,
                  onPressed: onPause,
                  size: 44,
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          MGSpacing.vSm,

          // 타이머 바
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: safeArea.left + MGSpacing.hudMargin + 20,
            ),
            child: _buildTimerBar(),
          ),

          MGSpacing.vMd,

          // 보스 HP 바
          if (bossMaxHp > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: safeArea.left + MGSpacing.hudMargin,
              ),
              child: _buildBossHpBar(),
            ),

          // 중앙 영역 확장 (게임 영역)
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildDpsDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.flash_on,
            color: Colors.red,
            size: 20,
          ),
          MGSpacing.hXs,
          Text(
            '${_formatNumber(totalDps)} DPS',
            style: MGTextStyles.hud.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    final ratio = totalTime > 0 ? currentTime / totalTime : 0.0;
    final isDanger = currentTime < 5.0;

    return Column(
      children: [
        MGLinearProgress(
          value: ratio,
          height: 14,
          valueColor: isDanger ? MGColors.error : Colors.cyan,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          borderRadius: 7,
        ),
        MGSpacing.vXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDanger
                ? Colors.red.withValues(alpha: 0.8)
                : Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: isDanger ? Colors.white : Colors.cyan,
                size: 16,
              ),
              MGSpacing.hXs,
              Text(
                '${currentTime.toStringAsFixed(1)}s',
                style: MGTextStyles.hud.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isDanger ? 20 : 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBossHpBar() {
    final percentage = bossMaxHp > 0 ? bossHp / bossMaxHp : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield,
                color: Colors.red,
                size: 20,
              ),
              MGSpacing.hXs,
              Expanded(
                child: Text(
                  bossName ?? 'BOSS',
                  style: MGTextStyles.hud.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_formatNumber(bossHp)}/${_formatNumber(bossMaxHp)}',
                style: MGTextStyles.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          MGSpacing.vXs,
          MGLinearProgress(
            value: percentage,
            height: 16,
            valueColor: _getBossHpColor(percentage),
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Color _getBossHpColor(double percentage) {
    if (percentage <= 0.25) {
      return Colors.red;
    } else if (percentage <= 0.5) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
