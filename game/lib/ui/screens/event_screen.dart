import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';
import '../../features/event/event_manager.dart';

class EventScreen extends StatelessWidget {
  final EventManager eventManager;
  final VoidCallback onBack;

  const EventScreen({
    super.key,
    required this.eventManager,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: eventManager,
      builder: (context, _) {
        final event = eventManager.currentEvent;
        if (event == null) {
          return _buildNoEvent();
        }
        return _buildEventContent(context, event);
      },
    );
  }

  Widget _buildNoEvent() {
    return Scaffold(
      backgroundColor: MGColors.background,
      appBar: AppBar(
        backgroundColor: MGColors.surface,
        leading: MGIconButton(
          icon: Icons.arrow_back,
          onPressed: onBack,
        ),
        title: Text('Events', style: MGTextStyles.headline),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: MGColors.textMediumEmphasis),
            SizedBox(height: MGSpacing.md),
            Text(
              'No Active Events',
              style: MGTextStyles.headline.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
            ),
            SizedBox(height: MGSpacing.sm),
            Text(
              'Check back later for seasonal events!',
              style: MGTextStyles.body.copyWith(
                color: MGColors.textMediumEmphasis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context, SeasonEvent event) {
    final themeColor = _parseColor(event.themeColor);

    return Scaffold(
      backgroundColor: MGColors.background,
      body: CustomScrollView(
        slivers: [
          // Event Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: themeColor,
            leading: MGIconButton(
              icon: Icons.arrow_back,
              onPressed: onBack,
              color: Colors.white,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.name,
                style: MGTextStyles.headline.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeColor.withOpacity(0.8),
                      themeColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ac_unit, size: 64, color: Colors.white70),
                      SizedBox(height: MGSpacing.sm),
                      _buildEventTimer(event),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Event Stats
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(MGSpacing.md),
              color: MGColors.surface,
              child: Column(
                children: [
                  Text(
                    event.description,
                    style: MGTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MGSpacing.md),
                  _buildStatsRow(),
                ],
              ),
            ),
          ),

          // Server Progress
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(MGSpacing.md),
              padding: EdgeInsets.all(MGSpacing.md),
              decoration: BoxDecoration(
                color: MGColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.public, color: themeColor),
                      SizedBox(width: MGSpacing.sm),
                      Text('Server Progress', style: MGTextStyles.headline),
                    ],
                  ),
                  SizedBox(height: MGSpacing.sm),
                  MGLinearProgress(
                    value: eventManager.serverProgress,
                    color: themeColor,
                  ),
                  SizedBox(height: MGSpacing.xs),
                  Text(
                    '${_formatNumber(eventManager.serverTotalDamage)} / ${_formatNumber(eventManager.serverTargetDamage)}',
                    style: MGTextStyles.caption.copyWith(
                      color: MGColors.textMediumEmphasis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Milestones Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MGSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.flag, color: themeColor),
                  SizedBox(width: MGSpacing.sm),
                  Text('Milestones', style: MGTextStyles.headline),
                ],
              ),
            ),
          ),

          // Milestone List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final milestone = event.milestones[index];
                return _buildMilestoneCard(milestone, themeColor);
              },
              childCount: event.milestones.length,
            ),
          ),

          // Rewards Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(MGSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: themeColor),
                  SizedBox(width: MGSpacing.sm),
                  Text('Rewards', style: MGTextStyles.headline),
                ],
              ),
            ),
          ),

          // Rewards Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: MGSpacing.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final reward = event.rewards[index];
                  return _buildRewardCard(reward, themeColor);
                },
                childCount: event.rewards.length,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: MGSpacing.xl),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTimer(SeasonEvent event) {
    final phase = event.phase;
    String statusText;
    Color statusColor;

    switch (phase) {
      case EventPhase.upcoming:
        statusText = 'Starts Soon';
        statusColor = Colors.orange;
        break;
      case EventPhase.active:
        statusText = '${event.formattedTimeRemaining} remaining';
        statusColor = Colors.greenAccent;
        break;
      case EventPhase.ended:
        statusText = 'Event Ended';
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
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
          Icon(Icons.timer, color: statusColor, size: 16),
          SizedBox(width: MGSpacing.xs),
          Text(
            statusText,
            style: MGTextStyles.body.copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          Icons.whatshot,
          _formatNumber(eventManager.totalDamageDealt),
          'Total Damage',
          MGColors.error,
        ),
        _buildStatItem(
          Icons.star,
          '${eventManager.eventPoints}',
          'Event Points',
          MGColors.gold,
        ),
        _buildStatItem(
          Icons.sports_kabaddi,
          '${eventManager.raidParticipations}',
          'Raids',
          MGColors.secondary,
        ),
        _buildStatItem(
          Icons.emoji_events,
          '${eventManager.bossKills}',
          'Boss Kills',
          MGColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: MGSpacing.xs),
        Text(value, style: MGTextStyles.headline.copyWith(color: color)),
        Text(
          label,
          style: MGTextStyles.caption.copyWith(
            color: MGColors.textMediumEmphasis,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(EventMilestone milestone, Color themeColor) {
    final progress = (eventManager.totalDamageDealt / milestone.targetDamage)
        .clamp(0.0, 1.0);
    final canClaim = eventManager.totalDamageDealt >= milestone.targetDamage &&
        !milestone.isClaimed;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      padding: EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: milestone.isClaimed
            ? themeColor.withOpacity(0.2)
            : MGColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: milestone.isClaimed ? themeColor : MGColors.outline,
        ),
      ),
      child: Row(
        children: [
          // Progress Circle
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: MGColors.outline,
                  color: themeColor,
                  strokeWidth: 4,
                ),
                Center(
                  child: milestone.isClaimed
                      ? Icon(Icons.check, color: themeColor, size: 20)
                      : Text(
                          '${(progress * 100).toInt()}%',
                          style: MGTextStyles.caption,
                        ),
                ),
              ],
            ),
          ),
          SizedBox(width: MGSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.name, style: MGTextStyles.body),
                Text(
                  '${_formatNumber(eventManager.totalDamageDealt)} / ${_formatNumber(milestone.targetDamage)}',
                  style: MGTextStyles.caption.copyWith(
                    color: MGColors.textMediumEmphasis,
                  ),
                ),
              ],
            ),
          ),

          // Reward
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.monetization_on, color: MGColors.gold, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${milestone.goldReward}',
                    style: MGTextStyles.body.copyWith(color: MGColors.gold),
                  ),
                ],
              ),
              if (milestone.specialRewardId != null)
                Icon(Icons.card_giftcard, color: themeColor, size: 16),
            ],
          ),
          SizedBox(width: MGSpacing.sm),

          // Claim Button
          if (canClaim)
            MGButton(
              text: 'Claim',
              onPressed: () => eventManager.claimMilestone(milestone.id),
              size: MGButtonSize.small,
            )
          else if (milestone.isClaimed)
            Icon(Icons.check_circle, color: themeColor)
          else
            Icon(Icons.lock, color: MGColors.textMediumEmphasis),
        ],
      ),
    );
  }

  Widget _buildRewardCard(EventReward reward, Color themeColor) {
    final isUnlocked = eventManager.eventPoints >= reward.requiredPoints;

    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: isUnlocked ? themeColor.withOpacity(0.2) : MGColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? themeColor : MGColors.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getRewardIcon(reward.id),
            color: isUnlocked ? themeColor : MGColors.textMediumEmphasis,
            size: 32,
          ),
          SizedBox(height: MGSpacing.xs),
          Text(
            reward.name,
            style: MGTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: MGSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: MGColors.gold, size: 12),
              Text(
                '${reward.requiredPoints}',
                style: MGTextStyles.caption.copyWith(
                  color: MGColors.textMediumEmphasis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(String rewardId) {
    if (rewardId.contains('title')) return Icons.badge;
    if (rewardId.contains('skin')) return Icons.person;
    if (rewardId.contains('pet')) return Icons.pets;
    return Icons.card_giftcard;
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
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
