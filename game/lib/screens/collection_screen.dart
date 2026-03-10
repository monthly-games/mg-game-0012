// ignore_for_file: depend_on_referenced_packages, unused_local_variable
// ============================================================
// Collection Screen — MG-0010 Dungeon Shop Simulator
// Genre: Simulator · Collection System UI
//
// Firebase Analytics Events:
//   - collection_screen_opened: Screen view tracking
//   - collection_item_viewed: {collection_id, item_id, rarity} item inspection
//   - collection_milestone_claimed: {collection_id, milestone, reward_type} milestone reward
//   - collection_completion_claimed: {collection_id, reward_type} full collection reward
//
// Template: This file is the canonical template for collection screens across all games.
// ============================================================

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/systems/collection/collection_manager.dart';
import 'package:mg_common_game/systems/collection/collection.dart';

/// Full-screen Collection UI with collection cards, item grids,
/// milestone rewards, and completion tracking.
///
/// Access pattern: `GetIt.I<CollectionManager>()` registered in main.dart.
/// Uses mg_common_game shared widgets: [MGCard], [MGLinearProgress], [MGButton].
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, required this.collectionManager});

  final CollectionManager collectionManager;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late final CollectionManager _collectionManager;

  // Firebase Analytics: cached instance for event logging
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _collectionManager = widget.collectionManager;
    _collectionManager.addListener(_onCollectionChanged);

    // Firebase Analytics: screen_view event
    _analytics.logEvent(
      name: 'collection_screen_opened',
      parameters: {
        'total_collections': _collectionManager.getAllCollections().length,
        'overall_progress': _collectionManager.getOverallProgress(),
      },
    );
  }

  @override
  void dispose() {
    _collectionManager.removeListener(_onCollectionChanged);
    super.dispose();
  }

  void _onCollectionChanged() {
    if (mounted) setState(() {});
  }

  // ── Firebase Event: Item viewed ──────────────────────────
  Future<void> _onItemViewed(String collectionId, String itemId) async {
    final collection = _collectionManager.getCollection(collectionId);
    final item = collection?.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw StateError('Item not found'),
    );

    if (item != null) {
      await _analytics.logEvent(
        name: 'collection_item_viewed',
        parameters: {
          'collection_id': collectionId,
          'item_id': itemId,
          'rarity': item.rarity.name,
          'is_unlocked': _collectionManager.isItemUnlocked(collectionId, itemId),
        },
      );
    }
  }

  // ── Firebase Event: Milestone reward claimed ─────────────
  Future<void> _onClaimMilestone(String collectionId, int milestone) async {
    final reward = _collectionManager.claimMilestoneReward(collectionId, milestone);

    if (reward != null) {
      await _analytics.logEvent(
        name: 'collection_milestone_claimed',
        parameters: {
          'collection_id': collectionId,
          'milestone': milestone,
          'reward_type': reward.type.name,
          'reward_amount': reward.amount,
        },
      );

      if (mounted) {
        _showRewardSnackBar('Milestone $milestone%: ${reward.displayText}');
      }
    }
  }

  // ── Firebase Event: Completion reward claimed ───────────
  Future<void> _onClaimCompletion(String collectionId) async {
    final reward = _collectionManager.claimCompletionReward(collectionId);

    if (reward != null) {
      await _analytics.logEvent(
        name: 'collection_completion_claimed',
        parameters: {
          'collection_id': collectionId,
          'reward_type': reward.type.name,
          'reward_amount': reward.amount,
        },
      );

      if (mounted) {
        _showRewardSnackBar('Collection Complete: ${reward.displayText}');
      }
    }
  }

  void _showRewardSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MGColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collections = _collectionManager.getAllCollections();

    return Scaffold(
      backgroundColor: MGColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: collections.isEmpty
                  ? _buildEmptyState()
                  : _buildCollectionsList(collections),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: back button + overall progress ───────────────
  Widget _buildHeader() {
    final overallProgress = _collectionManager.getOverallProgress();
    final progressPercent = (overallProgress * 100).toStringAsFixed(0);

    return Padding(
      padding: MGSpacing.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              MGIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
                color: MGColors.textHighEmphasis,
                backgroundColor: MGColors.surfaceDark,
                size: 40,
              ),
              const Spacer(),
              Text(
                'Collections',
                style: MGTextStyles.h2.copyWith(
                  color: MGColors.textHighEmphasis,
                ),
              ),
              const Spacer(),
              Container(
                padding: MGSpacing.symmetric(
                  horizontal: MGSpacing.sm,
                  vertical: MGSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: MGColors.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$progressPercent%',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.primaryAction,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.md),
          MGLinearProgress(
            value: overallProgress,
            height: 8,
            valueColor: MGColors.primaryAction,
            backgroundColor: MGColors.surfaceDark,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections,
            size: 64,
            color: MGColors.textMediumEmphasis,
          ),
          SizedBox(height: MGSpacing.md),
          Text(
            'No Collections Yet',
            style: MGTextStyles.h3.copyWith(
              color: MGColors.textHighEmphasis,
            ),
          ),
          SizedBox(height: MGSpacing.sm),
          Text(
            'Collections will appear as you unlock items',
            style: MGTextStyles.body.copyWith(
              color: MGColors.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Collections list ─────────────────────────────────────
  Widget _buildCollectionsList(List<Collection> collections) {
    return ListView.builder(
      padding: EdgeInsets.all(MGSpacing.md),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return Padding(
          padding: EdgeInsets.only(bottom: MGSpacing.md),
          child: _buildCollectionCard(collection),
        );
      },
    );
  }

  // ── Collection card ──────────────────────────────────────
  Widget _buildCollectionCard(Collection collection) {
    final progress = _collectionManager.getProgress(collection.id);
    final unlockedCount = _collectionManager.getUnlockedCount(collection.id);
    final totalCount = _collectionManager.getTotalCount(collection.id);
    final isComplete = _collectionManager.isCollectionComplete(collection.id);
    final availableMilestones =
        _collectionManager.getAvailableMilestones(collection.id);
    final completionRewardClaimed =
        _collectionManager.isCompletionRewardClaimed(collection.id);

    return MGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: MGTextStyles.h3.copyWith(
                        color: MGColors.textHighEmphasis,
                      ),
                    ),
                    SizedBox(height: MGSpacing.xs),
                    Text(
                      '$unlockedCount / $totalCount items',
                      style: MGTextStyles.caption.copyWith(
                        color: MGColors.textMediumEmphasis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: MGSpacing.symmetric(
                  horizontal: MGSpacing.sm,
                  vertical: MGSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: MGColors.surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.primaryAction,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.md),
          // Progress bar
          MGLinearProgress(
            value: progress,
            height: 8,
            valueColor: MGColors.year1Accent,
            backgroundColor: MGColors.surfaceDark,
            borderRadius: 4,
          ),
          SizedBox(height: MGSpacing.md),
          // Milestones
          if (collection.milestoneRewards != null &&
              collection.milestoneRewards!.isNotEmpty)
            _buildMilestones(collection, availableMilestones),
          // Completion reward
          if (isComplete && collection.completionReward != null)
            _buildCompletionReward(collection, completionRewardClaimed),
          // Item grid
          SizedBox(height: MGSpacing.md),
          _buildItemGrid(collection),
        ],
      ),
    );
  }

  // ── Milestones section ───────────────────────────────────
  Widget _buildMilestones(
    Collection collection,
    List<int> availableMilestones,
  ) {
    final milestones = collection.milestoneRewards!.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: MGTextStyles.caption.copyWith(
            color: MGColors.textMediumEmphasis,
          ),
        ),
        SizedBox(height: MGSpacing.sm),
        Wrap(
          spacing: MGSpacing.sm,
          runSpacing: MGSpacing.sm,
          children: milestones.map((milestone) {
            final isAvailable = availableMilestones.contains(milestone);
            final isClaimed =
                _collectionManager.isMilestoneRewardClaimed(collection.id, milestone);
            final reward = collection.milestoneRewards![milestone];

            return GestureDetector(
              onTap: isAvailable
                  ? () => _onClaimMilestone(collection.id, milestone)
                  : null,
              child: Container(
                padding: MGSpacing.symmetric(
                  horizontal: MGSpacing.sm,
                  vertical: MGSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isClaimed
                      ? MGColors.success.withOpacity(0.2)
                      : isAvailable
                          ? MGColors.warning.withOpacity(0.2)
                          : MGColors.surfaceDark,
                  border: Border.all(
                    color: isClaimed
                        ? MGColors.success
                        : isAvailable
                            ? MGColors.warning
                            : MGColors.border,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '★$milestone%',
                      style: MGTextStyles.caption.copyWith(
                        color: isClaimed
                            ? MGColors.success
                            : isAvailable
                                ? MGColors.warning
                                : MGColors.textMediumEmphasis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isClaimed)
                      Padding(
                        padding: EdgeInsets.only(left: MGSpacing.xs),
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: MGColors.success,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: MGSpacing.md),
      ],
    );
  }

  // ── Completion reward section ────────────────────────────
  Widget _buildCompletionReward(
    Collection collection,
    bool claimed,
  ) {
    final reward = collection.completionReward!;

    return Column(
      children: [
        MGButton(
          label: claimed ? 'Completion Reward Claimed' : 'Claim Completion Reward',
          size: MGButtonSize.small,
          icon: claimed ? Icons.check : Icons.card_giftcard,
          backgroundColor: claimed ? MGColors.success : MGColors.primaryAction,
          onPressed: claimed ? null : () => _onClaimCompletion(collection.id),
        ),
        SizedBox(height: MGSpacing.md),
      ],
    );
  }

  // ── Item grid ────────────────────────────────────────────
  Widget _buildItemGrid(Collection collection) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: collection.items.length,
      itemBuilder: (context, index) {
        final item = collection.items[index];
        final isUnlocked =
            _collectionManager.isItemUnlocked(collection.id, item.id);

        return GestureDetector(
          onTap: () => _onItemViewed(collection.id, item.id),
          child: _buildItemTile(item, isUnlocked),
        );
      },
    );
  }

  // ── Item tile ────────────────────────────────────────────
  Widget _buildItemTile(CollectionItem item, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? item.rarity.color.withOpacity(0.2) : MGColors.surfaceDark,
        border: Border.all(
          color: isUnlocked ? item.rarity.color : MGColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Item icon or placeholder
          if (item.iconPath != null && isUnlocked)
            Image.asset(
              item.iconPath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(item, isUnlocked);
              },
            )
          else
            _buildPlaceholder(item, isUnlocked),
          // Lock overlay
          if (!isUnlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.lock,
                color: MGColors.textHighEmphasis,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  // ── Item placeholder ─────────────────────────────────────
  Widget _buildPlaceholder(CollectionItem item, bool isUnlocked) {
    return Container(
      color: isUnlocked ? item.rarity.color.withOpacity(0.1) : MGColors.surfaceDark,
      child: Center(
        child: Icon(
          Icons.image,
          color: isUnlocked ? item.rarity.color : MGColors.textMediumEmphasis,
          size: 24,
        ),
      ),
    );
  }
}
