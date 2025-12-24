import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../event/event_manager.dart';

enum RaidPhase { active, victory, defeat }

class RaidHero {
  final String id;
  final String name;
  final String iconPath;
  bool isUnlocked;
  int level;
  double baseDps;
  int unlockCost;
  double baseCost;
  final Color color;

  RaidHero({
    required this.id,
    required this.name,
    required this.iconPath,
    this.isUnlocked = false,
    this.level = 1,
    this.baseDps = 10.0,
    this.unlockCost = 100,
    this.baseCost = 50.0,
    this.color = Colors.grey,
  });

  double get dps => baseDps * level;
  // Cost increases by 10% per level
  int get upgradeCost => (baseCost * (1 + 0.1 * (level - 1))).toInt();

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUnlocked': isUnlocked,
    'level': level,
  };
}

class RaidManager extends ChangeNotifier {
  double _bossHp = 10000.0;
  final double _maxBossHp = 10000.0;

  double _timeRemaining = 60.0;
  final double _totalTime = 60.0;

  RaidPhase _phase = RaidPhase.active;

  // Event Manager for tracking seasonal progress
  EventManager? _eventManager;

  double get bossHp => _bossHp;
  double get maxBossHp => _maxBossHp;
  double get timeRemaining => _timeRemaining;
  RaidPhase get phase => _phase;
  EventManager? get eventManager => _eventManager;

  int get gold => GetIt.I<GoldManager>().currentGold;
  double get currentTime => _totalTime - _timeRemaining;
  double get totalTime => _totalTime;

  final List<RaidHero> _heroes = [
    RaidHero(
      id: 'hero_warrior',
      name: "Warrior",
      iconPath: "hero_warrior.png", // Will need asset
      isUnlocked: true, // First one free
      baseDps: 15,
      unlockCost: 0,
      baseCost: 50,
      color: Colors.redAccent,
    ),
    RaidHero(
      id: 'hero_archer',
      name: "Archer",
      iconPath: "hero_archer.png",
      baseDps: 35,
      unlockCost: 500,
      baseCost: 150,
      color: Colors.greenAccent,
    ),
    RaidHero(
      id: 'hero_mage',
      name: "Mage",
      iconPath: "hero_mage.png",
      baseDps: 80,
      unlockCost: 2000,
      baseCost: 400,
      color: Colors.purpleAccent,
    ),
  ];

  List<RaidHero> get heroes => _heroes;

  // DPS Tracking
  double _damageDealtTotal = 0.0;
  double _trackingTimer = 0.0;
  double _currentDps = 0.0;

  // Pending Gold (to batch updates)
  double _pendingGold = 0.0;

  RaidManager() {
    _eventManager = EventManager();
    _loadState();
  }

  void update(double dt) {
    if (_phase != RaidPhase.active) return;

    _timeRemaining -= dt;
    if (_timeRemaining <= 0) {
      _timeRemaining = 0;
      _phase = RaidPhase.defeat;
      notifyListeners();
      // Logic to restart?
    }

    // Auto-Attack
    for (var hero in _heroes) {
      if (hero.isUnlocked) {
        dealDamage(hero.dps * dt);
      }
    }

    // DPS Calc
    _trackingTimer += dt;
    if (_trackingTimer >= 1.0) {
      _currentDps =
          _damageDealtTotal / (_totalTime - _timeRemaining + 0.1); // Avoid div0
      _trackingTimer = 0;
      notifyListeners();
    }
  }

  void dealDamage(double amount) {
    if (_phase != RaidPhase.active) return;

    _bossHp -= amount;
    _damageDealtTotal += amount;

    // Track damage for event milestones
    _eventManager?.addDamage(amount.toInt());

    // Reward: 1 Gold per 100 Damage (tuned for balance)
    _pendingGold += amount * 0.01;
    if (_pendingGold >= 1.0) {
      int goldToAdd = _pendingGold.floor();
      GetIt.I<GoldManager>().addGold(goldToAdd);
      _pendingGold -= goldToAdd;
    }

    if (_bossHp <= 0) {
      _bossHp = 0;
      _phase = RaidPhase.victory;
      GetIt.I<GoldManager>().addGold(1000); // Boss Kill Bonus
      _eventManager?.recordBossKill();
    }
    notifyListeners();
  }

  void upgradeHero(RaidHero hero) {
    if (!hero.isUnlocked) {
      if (GetIt.I<GoldManager>().spendGold(hero.unlockCost)) {
        hero.isUnlocked = true;
        hero.level = 1;
        _saveState();
        notifyListeners();
      }
    } else {
      if (GetIt.I<GoldManager>().spendGold(hero.upgradeCost)) {
        hero.level++;
        _saveState();
        notifyListeners();
      }
    }
  }

  // Reset for next fight
  void restartRaid() {
    _bossHp = _maxBossHp; // Scale this for next tier?
    _timeRemaining = _totalTime;
    _damageDealtTotal = 0;
    _phase = RaidPhase.active;
    _eventManager?.recordRaidParticipation();
    notifyListeners();
  }

  // Persistence
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('raid_heroes');
    if (jsonStr != null) {
      final List<dynamic> list = jsonDecode(jsonStr);
      for (var item in list) {
        final hero = _heroes.firstWhere(
          (h) => h.id == item['id'],
          orElse: () => _heroes[0],
        );
        hero.isUnlocked = item['isUnlocked'];
        hero.level = item['level'];
      }
    }
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_heroes.map((h) => h.toJson()).toList());
    await prefs.setString('raid_heroes', jsonStr);
  }

  String get formattedTime {
    final int sec = _timeRemaining.ceil();
    return "00:${sec.toString().padLeft(2, '0')}";
  }
}
