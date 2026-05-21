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
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final secondary = colorScheme.tertiary;
    final progress = (level.levelIndex / kLevelDesign.length).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text('Live Run'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(primary, Colors.white, 0.18)!,
              Color.lerp(secondary, Colors.black, 0.18)!,
              const Color(0xFF172033),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GameplayHeroPanel(
                      primary: primary,
                      secondary: secondary,
                      level: level,
                      spawn: spawn,
                      goldBank: goldBank,
                      xpBank: xpBank,
                      progress: progress,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _MetricPill(
                          icon: Icons.bolt_rounded,
                          label: 'Difficulty ${level.difficulty.toStringAsFixed(2)}',
                          color: Colors.amber,
                        ),
                        _MetricPill(
                          icon: Icons.groups_rounded,
                          label: '${spawn.enemyCount} targets',
                          color: Colors.redAccent,
                        ),
                        _MetricPill(
                          icon: Icons.timer_rounded,
                          label: '${spawn.spawnCadenceSeconds.toStringAsFixed(2)}s cadence',
                          color: Colors.lightBlueAccent,
                        ),
                        _MetricPill(
                          icon: Icons.inventory_2_rounded,
                          label: '$goldBank gold / $xpBank xp',
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(Colors.white, primary, 0.55)!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const ValueKey('complete-action'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.white,
                        foregroundColor: Color.lerp(primary, Colors.black, 0.40),
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      onPressed: completeAction,
                      icon: const Icon(Icons.touch_app_rounded),
                      label: Text('Complete Action - claim ${level.goldReward}g / ${level.xpReward}xp'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameplayHeroPanel extends StatelessWidget {
  const _GameplayHeroPanel({
    required this.primary,
    required this.secondary,
    required this.level,
    required this.spawn,
    required this.goldBank,
    required this.xpBank,
    required this.progress,
  });

  final Color primary;
  final Color secondary;
  final GameLevelDesign level;
  final WaveSpawnEntry spawn;
  final int goldBank;
  final int xpBank;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final stageIcon = _loopIcon(MyApp.coreFunLoop);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(stageIcon, color: primary, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MyApp.gameTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${MyApp.gameId} - ${MyApp.coreFunLoop}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.84),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _GameplayStage(
            primary: primary,
            secondary: secondary,
            level: level,
            spawn: spawn,
            goldBank: goldBank,
            xpBank: xpBank,
            progress: progress,
          ),
          const SizedBox(height: 18),
          Text(
            'Level ${level.levelIndex} - ${level.stage}',
            key: const ValueKey('level-name'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            level.objective,
            key: const ValueKey('level-objective'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock next: ${level.progressionUnlock}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
          ),
        ],
      ),
    );
  }
}

class _GameplayStage extends StatelessWidget {
  const _GameplayStage({
    required this.primary,
    required this.secondary,
    required this.level,
    required this.spawn,
    required this.goldBank,
    required this.xpBank,
    required this.progress,
  });

  final Color primary;
  final Color secondary;
  final GameLevelDesign level;
  final WaveSpawnEntry spawn;
  final int goldBank;
  final int xpBank;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final stageHeight = compact ? 360.0 : 430.0;
        return Container(
          height: stageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(primary, Colors.white, 0.32)!,
                Color.lerp(secondary, Colors.white, 0.22)!,
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.36), width: 2),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 72, 18, 72),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Lane(color: Colors.white, label: 'Lane A', progress: progress),
                      _Lane(color: Colors.amberAccent, label: 'Lane B', progress: (progress + 0.16).clamp(0.0, 1.0)),
                      _Lane(color: Colors.lightGreenAccent, label: 'Lane C', progress: (progress + 0.28).clamp(0.0, 1.0)),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 16,
                child: _SceneToken(
                  icon: _loopIcon(MyApp.coreFunLoop),
                  label: 'Hero',
                  value: 'Ready',
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 18,
                top: 16,
                child: _SceneToken(
                  icon: Icons.flag_rounded,
                  label: 'Wave',
                  value: '${spawn.wave}',
                  color: Colors.amberAccent,
                ),
              ),
              Positioned(
                left: 18,
                bottom: 16,
                child: _SceneToken(
                  icon: Icons.savings_rounded,
                  label: 'Bank',
                  value: '${goldBank}g',
                  color: Colors.greenAccent,
                ),
              ),
              Positioned(
                right: 18,
                bottom: 16,
                child: _SceneToken(
                  icon: Icons.psychology_alt_rounded,
                  label: 'XP',
                  value: '$xpBank',
                  color: Colors.lightBlueAccent,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: compact ? 216 : 280,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.track_changes_rounded, color: primary, size: 42),
                      const SizedBox(height: 10),
                      Text(
                        level.stage,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Color.lerp(primary, Colors.black, 0.30),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${spawn.enemyCount} targets - ${spawn.pressureBudget} pressure',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.black.withValues(alpha: 0.70),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    required this.color,
    required this.label,
    required this.progress,
  });

  final Color color;
  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.double_arrow_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.check_circle_rounded, color: color, size: 20),
        ],
      ),
    );
  }
}

class _SceneToken extends StatelessWidget {
  const _SceneToken({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.48)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.74),
                ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

IconData _loopIcon(String loop) {
  final normalized = loop.toLowerCase();
  if (normalized.contains('build') || normalized.contains('craft') || normalized.contains('merge')) {
    return Icons.construction_rounded;
  }
  if (normalized.contains('battle') || normalized.contains('fight') || normalized.contains('raid')) {
    return Icons.local_fire_department_rounded;
  }
  if (normalized.contains('collect') || normalized.contains('card')) {
    return Icons.style_rounded;
  }
  if (normalized.contains('puzzle') || normalized.contains('match')) {
    return Icons.extension_rounded;
  }
  if (normalized.contains('race') || normalized.contains('dash')) {
    return Icons.speed_rounded;
  }
  if (normalized.contains('idle') || normalized.contains('grow')) {
    return Icons.trending_up_rounded;
  }
  return Icons.auto_awesome_rounded;
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