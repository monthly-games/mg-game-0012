import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum EventPhase { upcoming, active, ended }

class SeasonEvent {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String themeColor;
  final List<EventMilestone> milestones;
  final List<EventReward> rewards;

  SeasonEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.themeColor = '#4A90D9',
    this.milestones = const [],
    this.rewards = const [],
  });

  EventPhase get phase {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return EventPhase.upcoming;
    if (now.isAfter(endDate)) return EventPhase.ended;
    return EventPhase.active;
  }

  Duration get timeRemaining => endDate.difference(DateTime.now());

  String get formattedTimeRemaining {
    final remaining = timeRemaining;
    if (remaining.isNegative) return 'Ended';
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class EventMilestone {
  final String id;
  final String name;
  final int targetDamage;
  final int goldReward;
  final String? specialRewardId;
  bool isClaimed;

  EventMilestone({
    required this.id,
    required this.name,
    required this.targetDamage,
    required this.goldReward,
    this.specialRewardId,
    this.isClaimed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isClaimed': isClaimed,
  };
}

class EventReward {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int requiredPoints;
  bool isUnlocked;

  EventReward({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.requiredPoints,
    this.isUnlocked = false,
  });
}

class EventManager extends ChangeNotifier {
  SeasonEvent? _currentEvent;
  int _eventPoints = 0;
  int _totalDamageDealt = 0;
  int _raidParticipations = 0;
  int _bossKills = 0;

  // Server Progress (simulated for single player)
  int _serverTotalDamage = 0;
  int _serverTargetDamage = 1000000;

  SeasonEvent? get currentEvent => _currentEvent;
  int get eventPoints => _eventPoints;
  int get totalDamageDealt => _totalDamageDealt;
  int get raidParticipations => _raidParticipations;
  int get bossKills => _bossKills;
  int get serverTotalDamage => _serverTotalDamage;
  int get serverTargetDamage => _serverTargetDamage;
  double get serverProgress => (_serverTotalDamage / _serverTargetDamage).clamp(0.0, 1.0);

  EventManager() {
    _initializeCurrentEvent();
    _loadProgress();
  }

  void _initializeCurrentEvent() {
    final now = DateTime.now();

    // Year-end Event (December)
    _currentEvent = SeasonEvent(
      id: 'winter_raid_2024',
      name: 'Winter Raid Festival',
      description: 'Battle the Frost Dragon and earn exclusive winter rewards!',
      startDate: DateTime(now.year, 12, 1),
      endDate: DateTime(now.year, 12, 31, 23, 59, 59),
      themeColor: '#4A90D9',
      milestones: [
        EventMilestone(
          id: 'milestone_1',
          name: 'First Strike',
          targetDamage: 10000,
          goldReward: 500,
        ),
        EventMilestone(
          id: 'milestone_2',
          name: 'Dragon Slayer',
          targetDamage: 50000,
          goldReward: 1500,
        ),
        EventMilestone(
          id: 'milestone_3',
          name: 'Raid Champion',
          targetDamage: 100000,
          goldReward: 3000,
          specialRewardId: 'frost_title',
        ),
        EventMilestone(
          id: 'milestone_4',
          name: 'Legendary Raider',
          targetDamage: 500000,
          goldReward: 10000,
          specialRewardId: 'frost_hero_skin',
        ),
      ],
      rewards: [
        EventReward(
          id: 'frost_title',
          name: 'Frost Champion',
          description: 'Exclusive title for event participants',
          iconPath: 'icon_title.png',
          requiredPoints: 1000,
        ),
        EventReward(
          id: 'frost_hero_skin',
          name: 'Winter Warrior Skin',
          description: 'Limited edition hero costume',
          iconPath: 'icon_skin.png',
          requiredPoints: 5000,
        ),
        EventReward(
          id: 'frost_pet',
          name: 'Snow Sprite',
          description: 'Adorable winter companion',
          iconPath: 'icon_pet.png',
          requiredPoints: 10000,
        ),
      ],
    );
  }

  void addDamage(int damage) {
    _totalDamageDealt += damage;
    _serverTotalDamage += damage;
    _eventPoints += (damage ~/ 100);
    _checkMilestones();
    notifyListeners();
    _saveProgress();
  }

  void recordRaidParticipation() {
    _raidParticipations++;
    _eventPoints += 50;
    notifyListeners();
    _saveProgress();
  }

  void recordBossKill() {
    _bossKills++;
    _eventPoints += 200;
    notifyListeners();
    _saveProgress();
  }

  void _checkMilestones() {
    if (_currentEvent == null) return;

    for (final milestone in _currentEvent!.milestones) {
      if (!milestone.isClaimed && _totalDamageDealt >= milestone.targetDamage) {
        // Auto-claim milestones
        // In a real game, you might want to show a popup
      }
    }
  }

  bool claimMilestone(String milestoneId) {
    if (_currentEvent == null) return false;

    final milestone = _currentEvent!.milestones.firstWhere(
      (m) => m.id == milestoneId,
      orElse: () => throw Exception('Milestone not found'),
    );

    if (milestone.isClaimed) return false;
    if (_totalDamageDealt < milestone.targetDamage) return false;

    milestone.isClaimed = true;
    _saveProgress();
    notifyListeners();
    return true;
  }

  List<EventMilestone> get claimableMilestones {
    if (_currentEvent == null) return [];
    return _currentEvent!.milestones.where((m) =>
      !m.isClaimed && _totalDamageDealt >= m.targetDamage
    ).toList();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _eventPoints = prefs.getInt('event_points') ?? 0;
    _totalDamageDealt = prefs.getInt('event_total_damage') ?? 0;
    _raidParticipations = prefs.getInt('event_raid_count') ?? 0;
    _bossKills = prefs.getInt('event_boss_kills') ?? 0;
    _serverTotalDamage = prefs.getInt('event_server_damage') ?? 0;

    // Load milestone claims
    final claimedJson = prefs.getString('event_claimed_milestones');
    if (claimedJson != null && _currentEvent != null) {
      final List<dynamic> claimed = jsonDecode(claimedJson);
      for (final id in claimed) {
        final milestone = _currentEvent!.milestones.firstWhere(
          (m) => m.id == id,
          orElse: () => _currentEvent!.milestones.first,
        );
        milestone.isClaimed = true;
      }
    }

    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('event_points', _eventPoints);
    await prefs.setInt('event_total_damage', _totalDamageDealt);
    await prefs.setInt('event_raid_count', _raidParticipations);
    await prefs.setInt('event_boss_kills', _bossKills);
    await prefs.setInt('event_server_damage', _serverTotalDamage);

    if (_currentEvent != null) {
      final claimed = _currentEvent!.milestones
          .where((m) => m.isClaimed)
          .map((m) => m.id)
          .toList();
      await prefs.setString('event_claimed_milestones', jsonEncode(claimed));
    }
  }

  void resetEvent() {
    _eventPoints = 0;
    _totalDamageDealt = 0;
    _raidParticipations = 0;
    _bossKills = 0;
    _serverTotalDamage = 0;
    if (_currentEvent != null) {
      for (final m in _currentEvent!.milestones) {
        m.isClaimed = false;
      }
    }
    _saveProgress();
    notifyListeners();
  }
}
