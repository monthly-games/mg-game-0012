import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/analytics/analytics_manager.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';
import 'package:mg_common_game/systems/gacha/gacha_pool.dart';

// ============================================================
// Gacha Screen — MG-0012 (Raid RPG)
// Template: Reusable across all MG games
//
// Sections:
//   1. Pool selector (tabs for each active pool)
//   2. Currency display (gold + pity counter)
//   3. Pull buttons (1x + 10x)
//   4. Results modal (shows pulled items)
//   5. History + stats
//
// Analytics events:
//   - gacha_screen_view
//   - gacha_pull_single
//   - gacha_pull_multi
//   - gacha_pool_switch
// ============================================================

/// Game-specific constants — the ONLY section that varies per game.
class _GameConfig {
  _GameConfig._();

  static const String gameId = 'mg-0012';
  static const int singlePullCost = 300;
  static const int multiPullCost = 2700; // 10x with discount
  static const Color accentColor = MGColors.gold; // Africa Gold
  static const Color premiumColor = Color(0xFFFF6B35); // Africa Orange
}

class GachaScreen extends StatefulWidget {
  final VoidCallback onBack;

  const GachaScreen({super.key, required this.onBack});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  final _gacha = GetIt.I<GachaManager>();
  final _gold = GetIt.I<GoldManager>();

  AnalyticsManager? _analytics;
  String? _selectedPoolId;
  List<GachaResult>? _lastResults;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _tryInitAnalytics();
    // Default to first active pool
    final pools = _gacha.activePools;
    if (pools.isNotEmpty) {
      _selectedPoolId = pools.first.id;
    }
  }

  void _tryInitAnalytics() {
    try {
      _analytics = AnalyticsManager.getInstance(_GameConfig.gameId);
      _analytics?.logScreenView('gacha_screen');
      _analytics?.logFeatureUsed('gacha_open');
    } catch (_) {
      // Analytics not initialized — skip silently in dev
    }
  }

  // ── Actions ───────────────────────────────────────────────

  void _selectPool(String poolId) {
    setState(() => _selectedPoolId = poolId);
    _analytics?.logEvent('gacha_pool_switch', parameters: {
      'pool_id': poolId,
    });
  }

  void _pullSingle() {
    if (_selectedPoolId == null) return;
    if (_gold.currentGold < _GameConfig.singlePullCost) return;

    _gold.trySpendGold(_GameConfig.singlePullCost);
    final result = _gacha.pull(_selectedPoolId!);
    if (result != null) {
      setState(() {
        _lastResults = [result];
        _showResults = true;
      });
      _analytics?.logEvent('gacha_pull_single', parameters: {
        'pool_id': _selectedPoolId!,
        'result_rarity': result.item.rarity.nameKr,
        'result_item': result.item.id,
        'is_pity': result.isPityTriggered,
      });
    }
  }

  void _pullMulti() {
    if (_selectedPoolId == null) return;
    if (_gold.currentGold < _GameConfig.multiPullCost) return;

    _gold.trySpendGold(_GameConfig.multiPullCost);
    final results = _gacha.multiPull(_selectedPoolId!);
    if (results.isNotEmpty) {
      setState(() {
        _lastResults = results;
        _showResults = true;
      });

      // Track highest rarity
      final highestRarity = results
          .map((r) => r.item.rarity.index)
          .reduce((a, b) => a > b ? a : b);
      _analytics?.logEvent('gacha_pull_multi', parameters: {
        'pool_id': _selectedPoolId!,
        'count': results.length,
        'highest_rarity': GachaRarity.values[highestRarity].nameKr,
      });
    }
  }

  void _dismissResults() {
    setState(() {
      _showResults = false;
      _lastResults = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _gacha,
      builder: (context, _) {
        return Stack(
          children: [
            _buildMainContent(),
            if (_showResults && _lastResults != null)
              _buildResultsOverlay(_lastResults!),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    final pools = _gacha.activePools;
    if (pools.isEmpty) return _buildNoPools();

    final selectedPool = pools.firstWhere(
      (p) => p.id == _selectedPoolId,
      orElse: () => pools.first,
    );

    return Scaffold(
      backgroundColor: MGColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          _buildHeader(selectedPool),

          // ── Pool Selector ──
          if (pools.length > 1)
            SliverToBoxAdapter(child: _buildPoolSelector(pools)),

          // ── Currency & Pity Display ──
          SliverToBoxAdapter(child: _buildCurrencyBar(selectedPool)),

          // ── Pull Buttons ──
          SliverToBoxAdapter(child: _buildPullButtons()),

          // ── Rate Info ──
          SliverToBoxAdapter(child: _buildRateInfo(selectedPool)),

          // ── Recent History ──
          SliverToBoxAdapter(child: _buildHistorySection()),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: MGSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPools() {
    return Scaffold(
      backgroundColor: MGColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: MGColors.surface,
        leading: MGIconButton(
          icon: Icons.arrow_back,
          onPressed: widget.onBack,
        ),
        title: const Text('Summon', style: MGTextStyles.h2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64,
                color: MGColors.textMediumEmphasis),
            const SizedBox(height: MGSpacing.md),
            Text(
              'No Active Banners',
              style: MGTextStyles.h2.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
            ),
            const SizedBox(height: MGSpacing.sm),
            Text(
              'New banners will arrive soon!',
              style: MGTextStyles.body.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(GachaPool pool) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: MGColors.surface,
      leading: MGIconButton(
        icon: Icons.arrow_back,
        onPressed: widget.onBack,
        color: MGColors.textHighEmphasis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pool.nameKr,
          style: MGTextStyles.h2.copyWith(color: MGColors.textHighEmphasis),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _GameConfig.accentColor.withValues(alpha: 0.5),
                MGColors.surface,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.auto_awesome, size: 56,
                    color: _GameConfig.accentColor.withValues(alpha: 0.7)),
                if (pool.description != null) ...[
                  const SizedBox(height: MGSpacing.sm),
                  Text(
                    pool.description!,
                    style: MGTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Pool Selector ─────────────────────────────────────────

  Widget _buildPoolSelector(List<GachaPool> pools) {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(
          MGSpacing.md, MGSpacing.md, MGSpacing.md, 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pools.length,
        separatorBuilder: (_, __) => const SizedBox(width: MGSpacing.sm),
        itemBuilder: (context, index) {
          final pool = pools[index];
          final isSelected = pool.id == _selectedPoolId;
          return GestureDetector(
            onTap: () => _selectPool(pool.id),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MGSpacing.md,
                vertical: MGSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? _GameConfig.accentColor.withValues(alpha: 0.2)
                    : MGColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? _GameConfig.accentColor
                      : MGColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  pool.nameKr,
                  style: MGTextStyles.body.copyWith(
                    color: isSelected
                        ? _GameConfig.accentColor
                        : MGColors.textMediumEmphasis,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Currency & Pity Display ───────────────────────────────

  Widget _buildCurrencyBar(GachaPool pool) {
    final pity = _gacha.getPityState(pool.id);
    final remaining = _gacha.remainingPity(pool.id);

    return Container(
      margin: const EdgeInsets.all(MGSpacing.md),
      padding: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: MGColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Gold display
          Expanded(
            child: StreamBuilder<int>(
              stream: _gold.onGoldChanged,
              initialData: _gold.currentGold,
              builder: (context, snapshot) {
                return Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        color: MGColors.gold, size: 24),
                    const SizedBox(width: MGSpacing.xs),
                    Text(
                      '${snapshot.data ?? 0}',
                      style: MGTextStyles.h2.copyWith(
                        color: MGColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Pity counter
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MGSpacing.sm,
              vertical: MGSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: MGColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Pity',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.textMediumEmphasis,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${pity?.currentPity ?? 0}/$remaining',
                  style: MGTextStyles.body.copyWith(
                    color: _GameConfig.premiumColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: MGSpacing.sm),

          // Total pulls
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MGSpacing.sm,
              vertical: MGSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: MGColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Total',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.textMediumEmphasis,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${pity?.totalPulls ?? 0}',
                  style: MGTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pull Buttons ──────────────────────────────────────────

  Widget _buildPullButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MGSpacing.md),
      child: StreamBuilder<int>(
        stream: _gold.onGoldChanged,
        initialData: _gold.currentGold,
        builder: (context, snapshot) {
          final gold = snapshot.data ?? 0;
          final canSingle = gold >= _GameConfig.singlePullCost;
          final canMulti = gold >= _GameConfig.multiPullCost;

          return Row(
            children: [
              // Single Pull
              Expanded(
                child: _buildPullButton(
                  label: 'Summon x1',
                  cost: _GameConfig.singlePullCost,
                  enabled: canSingle,
                  onPressed: _pullSingle,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: MGSpacing.md),
              // Multi Pull
              Expanded(
                flex: 2,
                child: _buildPullButton(
                  label: 'Summon x10',
                  cost: _GameConfig.multiPullCost,
                  enabled: canMulti,
                  onPressed: _pullMulti,
                  isPrimary: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPullButton({
    required String label,
    required int cost,
    required bool enabled,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final bgColor = isPrimary ? _GameConfig.accentColor : MGColors.surface;
    final fgColor = isPrimary ? MGColors.backgroundDark : MGColors.textHighEmphasis;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: MGSpacing.md),
        decoration: BoxDecoration(
          color: enabled
              ? bgColor
              : MGColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? (isPrimary ? _GameConfig.accentColor : MGColors.border)
                : MGColors.border.withValues(alpha: 0.3),
          ),
          boxShadow: enabled && isPrimary
              ? [
                  BoxShadow(
                    color: _GameConfig.accentColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: MGTextStyles.body.copyWith(
                color: enabled ? fgColor : MGColors.textDisabled,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: MGSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on,
                    color: enabled ? MGColors.gold : MGColors.textDisabled,
                    size: 16),
                const SizedBox(width: 4),
                Text(
                  '$cost',
                  style: MGTextStyles.caption.copyWith(
                    color: enabled ? fgColor : MGColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Rate Info ─────────────────────────────────────────────

  Widget _buildRateInfo(GachaPool pool) {
    return Container(
      margin: const EdgeInsets.all(MGSpacing.md),
      padding: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: MGColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: _GameConfig.accentColor, size: 18),
              const SizedBox(width: MGSpacing.xs),
              Text('Drop Rates', style: MGTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
          const SizedBox(height: MGSpacing.sm),
          ...GachaRarity.values.reversed.map((rarity) {
            final rate = pool.getRateForRarity(rarity);
            if (rate <= 0) return const SizedBox.shrink();
            return _buildRateRow(rarity, rate);
          }),
        ],
      ),
    );
  }

  Widget _buildRateRow(GachaRarity rarity, double rate) {
    final color = _getRarityColor(rarity);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 36,
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                rarity.nameKr,
                style: MGTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: MGSpacing.sm),
          Expanded(
            child: MGLinearProgress(
              value: rate / 100,
              valueColor: color,
              height: 6,
            ),
          ),
          const SizedBox(width: MGSpacing.sm),
          SizedBox(
            width: 48,
            child: Text(
              '${rate.toStringAsFixed(1)}%',
              style: MGTextStyles.caption.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ── History Section ───────────────────────────────────────

  Widget _buildHistorySection() {
    final history = _gacha.history;
    if (history.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MGSpacing.md),
      padding: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: MGColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Pulls', style: MGTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: MGSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: history.take(20).map((entry) {
              final color = _getRarityColor(entry.rarity);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  entry.rarity.nameKr,
                  style: MGTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Results Overlay ───────────────────────────────────────

  Widget _buildResultsOverlay(List<GachaResult> results) {
    // Sort by rarity descending for dramatic reveal
    final sorted = List<GachaResult>.from(results)
      ..sort((a, b) => b.item.rarity.index.compareTo(a.item.rarity.index));

    final hasHighRarity = sorted.any(
        (r) => r.item.rarity.index >= GachaRarity.superRare.index);

    return GestureDetector(
      onTap: _dismissResults,
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Title
              Text(
                results.length == 1 ? 'SUMMON RESULT' : 'SUMMON RESULTS',
                style: MGTextStyles.h2.copyWith(
                  color: hasHighRarity
                      ? _GameConfig.accentColor
                      : MGColors.textHighEmphasis,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: MGSpacing.lg),

              // Result cards
              Expanded(
                flex: 3,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: sorted.map((result) {
                      return _buildResultCard(result);
                    }).toList(),
                  ),
                ),
              ),

              // Tap to dismiss
              Padding(
                padding: const EdgeInsets.all(MGSpacing.lg),
                child: Text(
                  'Tap anywhere to continue',
                  style: MGTextStyles.caption.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(GachaResult result) {
    final color = _getRarityColor(result.item.rarity);
    final isHighRarity =
        result.item.rarity.index >= GachaRarity.superRare.index;

    return Container(
      width: 100,
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: isHighRarity ? 2 : 1,
        ),
        boxShadow: isHighRarity
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.item.rarity.nameKr,
              style: MGTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: MGSpacing.sm),

          // Item icon placeholder
          Icon(
            _getItemIcon(result.item),
            color: color,
            size: 36,
          ),
          const SizedBox(height: MGSpacing.xs),

          // Item name
          Text(
            result.item.nameKr,
            style: MGTextStyles.caption.copyWith(
              color: MGColors.textHighEmphasis,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Pity indicator
          if (result.isPityTriggered)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'PITY!',
                style: MGTextStyles.caption.copyWith(
                  color: _GameConfig.premiumColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Color _getRarityColor(GachaRarity rarity) {
    return switch (rarity) {
      GachaRarity.normal => MGColors.common,
      GachaRarity.rare => MGColors.rare,
      GachaRarity.superRare => MGColors.epic,
      GachaRarity.superRare ||
      GachaRarity.ultraRare => const Color(0xFFA335EE),
      GachaRarity.legendary => MGColors.legendary,
    };
  }

  IconData _getItemIcon(GachaItem item) {
    return switch (item.rarity) {
      GachaRarity.normal => Icons.circle,
      GachaRarity.rare => Icons.diamond,
      GachaRarity.superRare => Icons.auto_awesome,
      GachaRarity.superRare ||
      GachaRarity.ultraRare => Icons.stars,
      GachaRarity.legendary => Icons.whatshot,
    };
  }
}
