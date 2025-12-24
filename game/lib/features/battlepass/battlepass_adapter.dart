/// 배틀패스 시스템 어댑터 - MG-0012 Raid Event
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_config.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_manager.dart';

/// Raid Event 배틀패스
class RaidBattlePass extends ChangeNotifier {
  final BattlePassManager _manager = BattlePassManager();

  RaidBattlePass() {
    _initSeason();
  }

  void _initSeason() {
    final season = BPSeasonBuilder.create28DaySeason(
      id: 'raid_season_1',
      nameKr: '레이드 이벤트 시즌 1',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      expPerLevel: 1000,
    );

    _manager.setSeason(season);
    _manager.setMissions(
      daily: _createDailyMissions(),
      weekly: _createWeeklyMissions(),
    );
  }

  List<BPMission> _createDailyMissions() {
    return const [
      BPMission(
        id: 'daily_login',
        titleKr: '게임 접속',
        descriptionKr: '게임에 접속하세요',
        type: BPMissionType.daily,
        targetValue: 1,
        expReward: 100,
        trackingKey: 'login',
      ),
      BPMission(
        id: 'daily_play',
        titleKr: '플레이 3회',
        descriptionKr: '게임을 3회 플레이하세요',
        type: BPMissionType.daily,
        targetValue: 3,
        expReward: 150,
        trackingKey: 'play',
      ),
      BPMission(
        id: 'daily_reward',
        titleKr: '보상 획득',
        descriptionKr: '보상을 5회 획득하세요',
        type: BPMissionType.daily,
        targetValue: 5,
        expReward: 100,
        trackingKey: 'reward',
      ),
    ];
  }

  List<BPMission> _createWeeklyMissions() {
    return const [
      BPMission(
        id: 'weekly_play',
        titleKr: '주간 플레이',
        descriptionKr: '게임을 20회 플레이하세요',
        type: BPMissionType.weekly,
        targetValue: 20,
        expReward: 500,
        trackingKey: 'play',
      ),
      BPMission(
        id: 'weekly_reward',
        titleKr: '주간 보상',
        descriptionKr: '보상을 50회 획득하세요',
        type: BPMissionType.weekly,
        targetValue: 50,
        expReward: 500,
        trackingKey: 'reward',
      ),
      BPMission(
        id: 'weekly_gacha',
        titleKr: '주간 뽑기',
        descriptionKr: '가챠를 10회 진행하세요',
        type: BPMissionType.weekly,
        targetValue: 10,
        expReward: 750,
        trackingKey: 'gacha',
      ),
    ];
  }

  // === Getters ===
  BPSeasonConfig? get currentSeason => _manager.currentSeason;
  int get currentLevel => _manager.currentLevel;
  int get currentExp => _manager.currentExp;
  double get levelProgress => _manager.levelProgress;
  bool get isPremium => _manager.isPremium;

  // === Actions ===
  void addExp(int amount) {
    _manager.addExp(amount);
    notifyListeners();
  }

  void purchasePremium() {
    _manager.purchasePremium();
    notifyListeners();
  }

  void incrementMission(String trackingKey, [int amount = 1]) {
    _manager.incrementMissionProgress(trackingKey, amount);
    notifyListeners();
  }

  bool claimMissionReward(String missionId) {
    final result = _manager.claimMissionReward(missionId);
    if (result) notifyListeners();
    return result;
  }

  void resetDailyMissions() {
    _manager.resetDailyMissions();
    notifyListeners();
  }

  Map<String, dynamic> toJson() => _manager.toJson();
  void loadFromJson(Map<String, dynamic> json) {
    _manager.loadFromJson(json);
    notifyListeners();
  }
}
