import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A ready-made workout the user can pick with one tap.
class WorkoutPreset {
  final String name;
  final int rounds;
  final int roundLength; // seconds
  final int restTime; // seconds

  const WorkoutPreset(this.name, this.rounds, this.roundLength, this.restTime);
}

const kPresets = <WorkoutPreset>[
  WorkoutPreset('Pro Fight', 12, 180, 60),
  WorkoutPreset('Amateur', 3, 180, 60),
  WorkoutPreset('Sparring', 6, 120, 60),
  WorkoutPreset('Heavy Bag', 5, 180, 30),
  WorkoutPreset('Quick HIIT', 8, 60, 30),
];

/// The user's settings. They are saved on the device, so the app remembers
/// them after it is closed (previously everything reset on every launch).
class AppSettings {
  static const _kTheme = 'theme_mode';
  static const _kSound = 'sound_on';
  static const _kRounds = 'rounds';
  static const _kRoundLength = 'round_length';
  static const _kRest = 'rest_time';

  static const minRoundLength = 30;
  static const maxRoundLength = 600;
  static const minRest = 0;
  static const maxRest = 300;
  static const maxRounds = 30;

  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  static final soundOn = ValueNotifier<bool>(true);
  static final rounds = ValueNotifier<int>(12);
  static final roundLength = ValueNotifier<int>(180);
  static final restTime = ValueNotifier<int>(60);

  static SharedPreferences? _prefs;

  /// Call once at app start, before runApp.
  static Future<void> load() async {
    final prefs = _prefs = await SharedPreferences.getInstance();
    themeMode.value = switch (prefs.getString(_kTheme)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    soundOn.value = prefs.getBool(_kSound) ?? true;
    rounds.value = (prefs.getInt(_kRounds) ?? 12).clamp(1, maxRounds);
    roundLength.value = (prefs.getInt(_kRoundLength) ?? 180).clamp(
      minRoundLength,
      maxRoundLength,
    );
    restTime.value = (prefs.getInt(_kRest) ?? 60).clamp(minRest, maxRest);
  }

  static Future<void> setDarkMode(bool dark) async {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    await _prefs?.setString(_kTheme, dark ? 'dark' : 'light');
  }

  static Future<void> setSoundOn(bool on) async {
    soundOn.value = on;
    await _prefs?.setBool(_kSound, on);
  }

  static Future<void> setWorkout({
    required int rounds,
    required int roundLength,
    required int restTime,
  }) async {
    AppSettings.rounds.value = rounds;
    AppSettings.roundLength.value = roundLength;
    AppSettings.restTime.value = restTime;
    await _prefs?.setInt(_kRounds, rounds);
    await _prefs?.setInt(_kRoundLength, roundLength);
    await _prefs?.setInt(_kRest, restTime);
  }
}
