import 'package:mg_common_game/systems/tutorial/tutorial.dart';

/// Tutorial configuration for MG-0012: Year-End Raid Event RPG.
///
/// Placeholder tutorial steps — replace with localized strings
/// and add targetSelector for highlight positioning in production.
const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Year-End Raid Event RPG Tutorial',
  steps: [
    TutorialStep(
      id: 'welcome',
      title: 'Welcome, Hero!',
      description: 'Embark on an epic adventure.',
      actionHint: 'Tap to continue',
    ),
    TutorialStep(
      id: 'recruit',
      title: 'Recruit a Hero',
      description: 'Visit the tavern to recruit allies.',
      actionHint: 'Tap recruit',
      targetSelector: 'recruit_button',
    ),
    TutorialStep(
      id: 'first_battle',
      title: 'Enter Battle',
      description: 'Fight enemies to gain experience.',
      actionHint: 'Tap battle',
      targetSelector: 'battle_button',
    ),
    TutorialStep(
      id: 'equip',
      title: 'Equip Gear',
      description: 'Equip weapons and armor to power up.',
      actionHint: 'Tap to continue',
    ),
  ],
  skippable: true,
  showOnFirstLaunch: true,
  trigger: TutorialTrigger.firstLaunch,
);
