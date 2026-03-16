import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/analytics/analytics_manager.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_config.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_manager.dart';

// ============================================================
// BattlePass Screen — MG-0012 (Raid RPG)
// Template: Reusable across all MG games
//
// Sections:
//   1. Season header (name, timer, level progress)
//   2. Tier reward grid (free + premium columns)
//   3. Mission list (daily / weekly tabs)
//   4. Premium upgrade CTA
//
// Analytics events:
//   - battlepass_screen_view
//   - battlepass_claim_reward
//   - battlepass_claim_all
//   - battlepass_premium_purchase
//   - battlepass_mission_claim
// ============================================================

/// Game-specific constants — the ONLY section that varies per game.
class _GameConfig {
  _GameConfig._();

  static const String gameId = 'mg-0012';
  // gameTitle removed — unused (was 'Raid RPG')
  static const Color accentColor = MGColors.gold; // Africa Gold
  static const Color premiumColor = MGColors.orangeRed; // Africa Orange
}

class BattlePassScreen extends StatefulWidget {
  final VoidCallback onBack;

  const BattlePassScreen({super.key, required this.onBack});

  @override
  State<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends State<BattlePassScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _bp = GetIt.I<BattlePassManager>();

  AnalyticsManager? _analytics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tryInitAnalytics();
  }

  void _tryInitAnalytics() {
    try {
      _analytics = AnalyticsManager.getInstance(_GameConfig.gameId);
      _analytics?.logScreenView('battlepass_screen');
      _analytics?.logFeatureUsed('battlepass_open');
    } catch (_) {
      // Analytics not initialized — skip silently in dev
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────

  void _claimReward(int level, {required bool isPremium}) {
    final rewards = _bp.claimReward(level, isPremiumReward: isPremium);
    if (rewards.isNotEmpty) {
      _analytics?.logEvent('battlepass_claim_reward', parameters: {
        'level': level,
        'is_premium': isPremium,
        'reward_count': rewards.length,
      });
      _showRewardSnackBar(rewards);
    }
  }

  void _claimAll() {
    final rewards = _bp.claimAllAvailable();
    if (rewards.isNotEmpty) {
      _analytics?.logEvent('battlepass_claim_all', parameters: {
        'reward_count': rewards.length,
      });
      _showRewardSnackBar(rewards);
    }
  }

  void _purchasePremium() {
    _bp.purchasePremium();
    _analytics?.logEvent('battlepass_premium_purchase', parameters: {
      'price_usd': _bp.currentSeason?.premiumPrice ?? 9.99,
    });
  }

  void _claimMission(String missionId) {
    final success = _bp.claimMissionReward(missionId);
    if (success) {
      _analytics?.logEvent('battlepass_mission_claim', parameters: {
        'mission_id': missionId,
      });
    }
  }

  void _showRewardSnackBar(List<BPReward> rewards) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Claimed ${rewards.length} reward(s)!',
          style: MGTextStyles.body.copyWith(color: MGColors.textHighEmphasis),
        ),
        backgroundColor: _GameConfig.accentColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _bp,
      builder: (context, _) {
        final season = _bp.currentSeason;
        if (season == null) return _buildNoSeason();
        return _buildContent(season);
      },
    );
  }

  Widget _buildNoSeason() {
    return Scaffold(
      backgroundColor: MGColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: MGColors.surface,
        leading: MGIconButton(
          icon: Icons.arrow_back,
          onPressed: widget.onBack,
        ),
        title: const Text('Battle Pass', style: MGTextStyles.h2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_membership, size: 64,
                color: MGColors.textMediumEmphasis),
            const SizedBox(height: MGSpacing.md),
            Text(
              'No Active Season',
              style: MGTextStyles.h2.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
            ),
            const SizedBox(height: MGSpacing.sm),
            Text(
              'A new season will start soon!',
              style: MGTextStyles.body.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BPSeasonConfig season) {
    return Scaffold(
      backgroundColor: MGColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // ── Season Header ──
          _buildSeasonHeader(season),

          // ── Level Progress ──
          SliverToBoxAdapter(child: _buildLevelProgress(season)),

          // ── Claim All Button ──
          if (_bp.unclaimedRewardCount > 0)
            SliverToBoxAdapter(child: _buildClaimAllButton()),

          // ── Premium CTA ──
          if (!_bp.isPremium)
            SliverToBoxAdapter(child: _buildPremiumCta(season)),

          // ── Reward Grid Header ──
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  MGSpacing.md, MGSpacing.lg, MGSpacing.md, MGSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: _GameConfig.accentColor),
                  SizedBox(width: MGSpacing.sm),
                  Text('Rewards', style: MGTextStyles.h2),
                ],
              ),
            ),
          ),

          // ── Tier Reward List ──
          _buildTierList(season),

          // ── Mission Section ──
          SliverToBoxAdapter(child: _buildMissionSection()),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: MGSpacing.xxl),
          ),
        ],
      ),
    );
  }

  // ── Season Header ─────────────────────────────────────────

  Widget _buildSeasonHeader(BPSeasonConfig season) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: MGColors.surface,
      leading: MGIconButton(
        icon: Icons.arrow_back,
        onPressed: widget.onBack,
        color: MGColors.textHighEmphasis,
      ),
      actions: [
        if (_bp.isPremium)
          Container(
            margin: const EdgeInsets.only(right: MGSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: MGSpacing.sm,
              vertical: MGSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _GameConfig.premiumColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _GameConfig.premiumColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: _GameConfig.premiumColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'PREMIUM',
                  style: MGTextStyles.caption.copyWith(
                    color: _GameConfig.premiumColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          season.nameKr,
          style: MGTextStyles.h2.copyWith(color: MGColors.textHighEmphasis),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _GameConfig.accentColor.withValues(alpha: 0.6),
                MGColors.surface,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.card_membership, size: 48,
                    color: _GameConfig.accentColor.withValues(alpha: 0.7)),
                const SizedBox(height: MGSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MGSpacing.md,
                    vertical: MGSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.white70, size: 16),
                      const SizedBox(width: MGSpacing.xs),
                      Text(
                        '${season.remainingDays} days remaining',
                        style: MGTextStyles.body.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Level Progress ────────────────────────────────────────

  Widget _buildLevelProgress(BPSeasonConfig season) {
    final isMaxLevel = _bp.currentLevel >= season.maxLevel;

    return Container(
      margin: const EdgeInsets.all(MGSpacing.md),
      padding: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: MGColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${_bp.currentLevel}',
                style: MGTextStyles.h2.copyWith(
                  color: _GameConfig.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isMaxLevel
                    ? 'MAX LEVEL'
                    : '${_bp.currentExp} / ${_bp.expToNextLevel + _bp.currentExp} EXP',
                style: MGTextStyles.caption.copyWith(
                  color: MGColors.textMediumEmphasis,
                ),
              ),
            ],
          ),
          const SizedBox(height: MGSpacing.sm),
          MGLinearProgress(
            value: _bp.levelProgress,
            valueColor: _GameConfig.accentColor,
          ),
          const SizedBox(height: MGSpacing.xs),
          Text(
            isMaxLevel
                ? 'All tiers unlocked!'
                : '${_bp.expToNextLevel} EXP to next level',
            style: MGTextStyles.caption.copyWith(
              color: MGColors.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Claim All Button ──────────────────────────────────────

  Widget _buildClaimAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MGSpacing.md),
      child: MGButton(
        label: 'Claim All (${_bp.unclaimedRewardCount})',
        onPressed: _claimAll,
      ),
    );
  }

  // ── Premium CTA ───────────────────────────────────────────

  Widget _buildPremiumCta(BPSeasonConfig season) {
    return Container(
      margin: const EdgeInsets.all(MGSpacing.md),
      padding: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _GameConfig.premiumColor.withValues(alpha: 0.3),
            _GameConfig.accentColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _GameConfig.premiumColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: _GameConfig.premiumColor, size: 32),
          const SizedBox(width: MGSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: MGTextStyles.h2.copyWith(
                    color: _GameConfig.premiumColor,
                  ),
                ),
                Text(
                  'Unlock exclusive rewards at every tier!',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.textMediumEmphasis,
                  ),
                ),
              ],
            ),
          ),
          MGButton(
            label: '\$${season.premiumPrice.toStringAsFixed(2)}',
            onPressed: _purchasePremium,
            size: MGButtonSize.small,
          ),
        ],
      ),
    );
  }

  // ── Tier List ─────────────────────────────────────────────

  Widget _buildTierList(BPSeasonConfig season) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tier = season.tiers[index];
          return _buildTierRow(tier);
        },
        childCount: season.tiers.length,
      ),
    );
  }

  Widget _buildTierRow(BPTier tier) {
    final isUnlocked = _bp.currentLevel >= tier.level;
    final isCurrent = _bp.currentLevel == tier.level;
    final canClaimFree =
        _bp.canClaimReward(tier.level, isPremiumReward: false);
    final canClaimPremium =
        _bp.canClaimReward(tier.level, isPremiumReward: true);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: isCurrent
            ? _GameConfig.accentColor.withValues(alpha: 0.1)
            : MGColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? _GameConfig.accentColor
              : isUnlocked
                  ? MGColors.border
                  : MGColors.border.withValues(alpha: 0.3),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // ── Level Badge ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? _GameConfig.accentColor.withValues(alpha: 0.2)
                  : MGColors.border.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? _GameConfig.accentColor
                    : MGColors.border,
              ),
            ),
            child: Center(
              child: Text(
                '${tier.level}',
                style: MGTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? _GameConfig.accentColor
                      : MGColors.textMediumEmphasis,
                ),
              ),
            ),
          ),
          const SizedBox(width: MGSpacing.sm),

          // ── Free Rewards ──
          Expanded(
            child: _buildRewardCell(
              rewards: tier.freeRewards,
              label: 'Free',
              canClaim: canClaimFree,
              isClaimed: isUnlocked && !canClaimFree &&
                  tier.freeRewards.isNotEmpty,
              isLocked: !isUnlocked,
              onClaim: () => _claimReward(tier.level, isPremium: false),
            ),
          ),

          // ── Divider ──
          Container(
            width: 1,
            height: 48,
            color: MGColors.border.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(horizontal: MGSpacing.xs),
          ),

          // ── Premium Rewards ──
          Expanded(
            child: _buildRewardCell(
              rewards: tier.premiumRewards,
              label: 'Premium',
              canClaim: canClaimPremium,
              isClaimed: isUnlocked && !canClaimPremium &&
                  tier.premiumRewards.isNotEmpty && _bp.isPremium,
              isLocked: !isUnlocked || !_bp.isPremium,
              isPremium: true,
              onClaim: () => _claimReward(tier.level, isPremium: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCell({
    required List<BPReward> rewards,
    required String label,
    required bool canClaim,
    required bool isClaimed,
    required bool isLocked,
    bool isPremium = false,
    VoidCallback? onClaim,
  }) {
    if (rewards.isEmpty) {
      return const SizedBox(height: 48);
    }

    final reward = rewards.first;
    final accentColor =
        isPremium ? _GameConfig.premiumColor : _GameConfig.accentColor;

    return GestureDetector(
      onTap: canClaim ? onClaim : null,
      child: Container(
        padding: const EdgeInsets.all(MGSpacing.xs),
        decoration: canClaim
            ? BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor),
              )
            : null,
        child: Row(
          children: [
            Icon(
              _getRewardIcon(reward.type),
              color: isClaimed
                  ? MGColors.textMediumEmphasis
                  : isLocked
                      ? MGColors.textMediumEmphasis.withValues(alpha: 0.5)
                      : accentColor,
              size: 20,
            ),
            const SizedBox(width: MGSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.nameKr,
                    style: MGTextStyles.caption.copyWith(
                      color: isLocked
                          ? MGColors.textMediumEmphasis
                          : MGColors.textHighEmphasis,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (reward.amount > 1)
                    Text(
                      'x${reward.amount}',
                      style: MGTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: MGColors.textMediumEmphasis,
                      ),
                    ),
                ],
              ),
            ),
            if (isClaimed)
              Icon(Icons.check_circle, color: accentColor, size: 18)
            else if (canClaim)
              Icon(Icons.download, color: accentColor, size: 18)
            else if (isLocked)
              Icon(Icons.lock, color: MGColors.textMediumEmphasis.withValues(
                  alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }

  IconData _getRewardIcon(BPRewardType type) {
    return switch (type) {
      BPRewardType.currency => Icons.monetization_on,
      BPRewardType.item => Icons.inventory_2,
      BPRewardType.character => Icons.person,
      BPRewardType.costume => Icons.checkroom,
      BPRewardType.title => Icons.badge,
      BPRewardType.frame => Icons.crop_square,
      BPRewardType.emoji => Icons.emoji_emotions,
      BPRewardType.summonTicket => Icons.confirmation_number,
    };
  }

  // ── Mission Section ───────────────────────────────────────

  Widget _buildMissionSection() {
    return Container(
      margin: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: MGColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: _GameConfig.accentColor,
            labelColor: _GameConfig.accentColor,
            unselectedLabelColor: MGColors.textMediumEmphasis,
            tabs: const [
              Tab(text: 'Daily Missions'),
              Tab(text: 'Weekly Missions'),
            ],
          ),
          // Tab content
          SizedBox(
            height: _calculateMissionListHeight(),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMissionList(_bp.dailyMissions),
                _buildMissionList(_bp.weeklyMissions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMissionListHeight() {
    final maxCount = [
      _bp.dailyMissions.length,
      _bp.weeklyMissions.length,
    ].reduce((a, b) => a > b ? a : b);
    return (maxCount * 80.0).clamp(160.0, 320.0);
  }

  Widget _buildMissionList(List<BPMission> missions) {
    if (missions.isEmpty) {
      return Center(
        child: Text(
          'No missions available',
          style: MGTextStyles.body.copyWith(
            color: MGColors.textMediumEmphasis,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(MGSpacing.sm),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: missions.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: MGColors.border,
      ),
      itemBuilder: (context, index) {
        return _buildMissionTile(missions[index]);
      },
    );
  }

  Widget _buildMissionTile(BPMission mission) {
    final progress = _bp.getMissionProgress(mission.id);
    final isCompleted = _bp.isMissionCompleted(mission.id);
    final isClaimed =
        _bp.state?.missionProgress[mission.id]?.isClaimed ?? false;
    final currentValue =
        _bp.state?.missionProgress[mission.id]?.currentValue ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MGSpacing.sm),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: MGColors.border,
                  color: _GameConfig.accentColor,
                  strokeWidth: 3,
                ),
                Center(
                  child: isClaimed
                      ? const Icon(Icons.check,
                          color: _GameConfig.accentColor, size: 20)
                      : Text(
                          '${(progress * 100).toInt()}%',
                          style: MGTextStyles.caption.copyWith(fontSize: 10),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MGSpacing.sm),

          // Mission info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.titleKr,
                  style: MGTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isClaimed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  '$currentValue / ${mission.targetValue}',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.textMediumEmphasis,
                  ),
                ),
              ],
            ),
          ),

          // EXP reward
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MGSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _GameConfig.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${mission.expReward} EXP',
              style: MGTextStyles.caption.copyWith(
                color: _GameConfig.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: MGSpacing.xs),

          // Claim button
          if (isCompleted && !isClaimed)
            MGButton(
              label: 'Claim',
              onPressed: () => _claimMission(mission.id),
              size: MGButtonSize.small,
            )
          else if (isClaimed)
            const Icon(Icons.check_circle, color: _GameConfig.accentColor, size: 24)
          else
            const Icon(Icons.lock_outline,
                color: MGColors.textMediumEmphasis, size: 20),
        ],
      ),
    );
  }
}
