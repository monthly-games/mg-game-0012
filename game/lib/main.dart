import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'ui/main_screen.dart';

import 'package:mg_common_game/core/systems/save_manager_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();

  // Unified Persistence
  await SaveManagerHelper.setupSaveManager(
    autoSaveEnabled: true,
    autoSaveIntervalSeconds: 30,
  );
  await SaveManagerHelper.legacyLoadAll();

  runApp(const MyApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
  if (!GetIt.I.isRegistered<GoldManager>()) {
    GetIt.I.registerSingleton<GoldManager>(GoldManager());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raid RPG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
