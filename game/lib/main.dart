import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const gameId = 'MG-0012';
  static const gameTitle = 'Year-End Raid Event RPG';
  static const coreFunLoop = kCoreFunLoop;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: gameTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E24AA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/game': (_) => const GameScreen(),
        '/engine': (_) => const FrameLoopScreen(),
        '/levels': (_) => const LevelRoadmapScreen(),
        '/daily': (_) => const DailyHubScreen(),
        '/retention': (_) => const RetentionHubScreen(),
        '/guild-war': (_) => const GuildWarScreen(),
        '/tournament': (_) => const TournamentScreen(),
        '/seasonal-event': (_) => const SeasonalEventScreen(),
      },
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.videogame_asset_rounded, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    MyApp.gameId,
                    key: const ValueKey('game-id'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MyApp.gameTitle,
                    key: const ValueKey('game-title'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Core Fun: ${MyApp.coreFunLoop}',
                    key: const ValueKey('core-fun-loop'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    key: const ValueKey('start-game'),
                    onPressed: () => Navigator.of(context).pushNamed('/game'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Game'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('level-roadmap'),
                    onPressed: () => Navigator.of(context).pushNamed('/levels'),
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Level Roadmap'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _MenuAction(
                        route: '/engine',
                        buttonKey: ValueKey('engine-loop'),
                        icon: Icons.memory_rounded,
                        label: 'Engine',
                      ),
                      _MenuAction(
                        route: '/retention',
                        buttonKey: ValueKey('rewards'),
                        icon: Icons.card_giftcard_rounded,
                        label: 'Rewards',
                      ),
                      _MenuAction(
                        route: '/daily',
                        buttonKey: ValueKey('daily-quests'),
                        icon: Icons.today_rounded,
                        label: 'Daily',
                      ),
                      _MenuAction(
                        route: '/guild-war',
                        buttonKey: ValueKey('guild-war'),
                        icon: Icons.groups_rounded,
                        label: 'Guild',
                      ),
                      _MenuAction(
                        route: '/tournament',
                        buttonKey: ValueKey('tournament'),
                        icon: Icons.emoji_events_rounded,
                        label: 'Tournament',
                      ),
                      _MenuAction(
                        route: '/seasonal-event',
                        buttonKey: ValueKey('seasonal-event'),
                        icon: Icons.event_rounded,
                        label: 'Event',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({
    required this.route,
    required this.buttonKey,
    required this.icon,
    required this.label,
  });

  final String route;
  final ValueKey<String> buttonKey;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: OutlinedButton.icon(
        key: buttonKey,
        onPressed: () => Navigator.of(context).pushNamed(route),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int levelIndex = 0;
  int goldBank = 0;
  int xpBank = 0;

  GameLevelDesign get currentLevel => kLevelDesign[levelIndex];

  void completeAction() {
    setState(() {
      goldBank += currentLevel.goldReward;
      xpBank += currentLevel.xpReward;
      if (levelIndex < kLevelDesign.length - 1) {
        levelIndex += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = currentLevel;
    final spawn = kWaveSpawnTable[levelIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Game Ready')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Primary loop: ${MyApp.coreFunLoop}',
                  key: const ValueKey('primary-loop'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Level ${level.levelIndex} - ${level.stage}',
                  key: const ValueKey('level-name'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Objective: ${level.objective}',
                  key: const ValueKey('level-objective'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Wave ${level.wave} | Difficulty ${level.difficulty.toStringAsFixed(2)}',
                  key: const ValueKey('difficulty-label'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pressure: ${spawn.enemyCount} enemies every '
                  '${spawn.spawnCadenceSeconds.toStringAsFixed(2)}s',
                  key: const ValueKey('pressure-label'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (level.levelIndex / kLevelDesign.length).clamp(0.0, 1.0),
                ),
                const SizedBox(height: 16),
                Text(
                  'Reward bank: $goldBank gold / $xpBank xp',
                  key: const ValueKey('reward-bank'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const ValueKey('complete-action'),
                  onPressed: completeAction,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Complete Action'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrameLoopGame extends FlameGame {
  double elapsedSeconds = 0;
  int frameTicks = 0;

  @override
  void update(double dt) {
    elapsedSeconds += dt;
    frameTicks += 1;
    super.update(dt);
  }
}

class FrameLoopScreen extends StatelessWidget {
  const FrameLoopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engine Loop')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'GameWidget frame loop is active for runtime input, update, and render validation.',
              key: ValueKey('engine-loop-status'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: GameWidget(game: _FrameLoopGame())),
        ],
      ),
    );
  }
}

class LevelRoadmapScreen extends StatelessWidget {
  const LevelRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level Roadmap')),
      body: ListView.builder(
        key: const ValueKey('level-list'),
        padding: const EdgeInsets.all(16),
        itemCount: kLevelDesign.length,
        itemBuilder: (context, index) {
          final level = kLevelDesign[index];
          final spawn = kWaveSpawnTable[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${level.levelIndex}')),
            title: Text('Level ${level.levelIndex} - ${level.stage}'),
            subtitle: Text(
              'Wave ${level.wave} | difficulty ${level.difficulty.toStringAsFixed(2)} | '
              '${spawn.enemyCount} enemies | reward ${level.goldReward}g/${level.xpReward}xp',
            ),
          );
        },
      ),
    );
  }
}

class DailyHubScreen extends StatelessWidget {
  const DailyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Daily Quests',
      detail: 'Short goals keep the fun loop moving.',
      icon: Icons.today_rounded,
    );
  }
}

class RetentionHubScreen extends StatelessWidget {
  const RetentionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Rewards',
      detail: 'Progression loop: return, claim, improve.',
      icon: Icons.card_giftcard_rounded,
    );
  }
}

class GuildWarScreen extends StatelessWidget {
  const GuildWarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Guild War',
      detail: 'Social competition is reachable from the main loop.',
      icon: Icons.groups_rounded,
    );
  }
}

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Tournament',
      detail: 'Competitive goals are available for mastery.',
      icon: Icons.emoji_events_rounded,
    );
  }
}

class SeasonalEventScreen extends StatelessWidget {
  const SeasonalEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      title: 'Seasonal Event',
      detail: 'Timed content gives the loop a fresh reason to return.',
      icon: Icons.event_rounded,
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({required this.title, required this.detail, required this.icon});

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56),
              const SizedBox(height: 16),
              Text(
                title,
                key: const ValueKey('screen-title'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(detail, key: const ValueKey('screen-detail'), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

*/