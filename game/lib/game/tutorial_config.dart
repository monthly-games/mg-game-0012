import 'package:mg_common_game/systems/tutorial/tutorial.dart';

/// Tutorial configuration for MG-0012: Year-End Raid Event RPG.
///
/// Placeholder tutorial steps -- replace with localized strings
/// and add targetSelector for highlight positioning in production.
const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Year-End Raid Event RPG Tutorial',
  steps: [
    TutorialStep(
      id: 'play_button',
      title: '게임을 시작하세요',
      description: '플레이 버튼을 눌러 게임을 시작합니다.',
      targetSelector: 'play_button',
    ),
    TutorialStep(
      id: 'objective',
      title: '목표를 달성하세요',
      description: '화면의 안내를 따라 목표를 완수하세요.',
      targetSelector: 'objective',
    ),
    TutorialStep(
      id: 'reward',
      title: '보상을 획득하세요',
      description: '목표 달성 시 골드와 경험치를 받습니다.',
      targetSelector: 'reward',
    ),
    TutorialStep(
      id: 'unlock',
      title: '새 콘텐츠를 해제하세요',
      description: '레벨을 올려 새로운 콘텐츠를 해제하세요.',
      targetSelector: 'unlock',
    ),
  
  ],
  skippable: true,
  showOnFirstLaunch: true,
  trigger: TutorialTrigger.firstLaunch,
);
