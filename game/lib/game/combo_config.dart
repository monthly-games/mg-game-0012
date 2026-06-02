/// Configuration constants for the combo system in MG-0012
/// Allows for easy tuning of combo mechanics and rewards

class ComboConfig {
  ComboConfig._();

  // Timing Configuration
  /// Time in seconds before combo starts decaying
  static const double decayDuration = 3.0;

  /// Time in seconds when decay warning activates
  static const double decayWarningThreshold = 1.0;

  // Milestone Configuration
  /// Combo count required for BASIC milestone (1.2x damage)
  static const int basicMilestone = 5;

  /// Combo count required for GREAT milestone (1.5x damage)
  static const int greatMilestone = 10;

  /// Combo count required for EXCELLENT milestone (2.0x damage)
  static const int excellentMilestone = 15;

  /// Combo count required for AMAZING milestone (3.0x damage)
  static const int amazingMilestone = 25;

  /// Combo count required for LEGENDARY milestone (5.0x damage)
  static const int legendaryMilestone = 50;

  // Multiplier Configuration
  /// Damage multiplier for BASIC milestone
  static const double basicMultiplier = 1.2;

  /// Damage multiplier for GREAT milestone
  static const double greatMultiplier = 1.5;

  /// Damage multiplier for EXCELLENT milestone
  static const double excellentMultiplier = 2.0;

  /// Damage multiplier for AMAZING milestone
  static const double amazingMultiplier = 3.0;

  /// Damage multiplier for LEGENDARY milestone
  static const double legendaryMultiplier = 5.0;

  // Visual Configuration
  /// Duration of pulse animation when milestone reached (milliseconds)
  static const int milestonePulseDuration = 300;

  /// Scale factor for milestone pulse animation
  static const double milestonePulseScale = 1.2;

  // Game Balance Notes
  /// At 1 skill use per second, player can maintain ~10-15 combo consistently
  /// Legendary requires perfectly timed skill usage for 50 seconds
  /// Combo decay encourages active engagement vs passive play
}
