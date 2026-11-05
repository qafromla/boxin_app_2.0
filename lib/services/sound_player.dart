import 'package:audioplayers/audioplayers.dart';

import 'app_settings.dart';

/// Plays the bell and beep sounds.
///
/// The bell and the beep use separate players, so a countdown beep no longer
/// cuts off the bell. Every method checks the Sound setting itself.
class SoundPlayer {
  static AudioPlayer? _bellPlayer;
  static AudioPlayer? _beepPlayer;

  static AudioPlayer get _bell => _bellPlayer ??= AudioPlayer();
  static AudioPlayer get _beep => _beepPlayer ??= AudioPlayer();

  /// Round starts: the classic "ding-ding" start bell.
  static Future<void> playRoundStart() =>
      _play(_bell, 'sounds/start_boxing_bell.mp3');

  /// Round ends / rest starts: a different bell, so you can tell by ear.
  static Future<void> playRestStart() => _play(_bell, 'sounds/boxing_bell.mp3');

  /// Whole workout finished.
  static Future<void> playWorkoutEnd() =>
      _play(_bell, 'sounds/boxing_bell.mp3');

  /// Short countdown beep (last 5 seconds).
  static Future<void> playBeep() => _play(_beep, 'sounds/beep_sound_1.wav');

  static Future<void> _play(AudioPlayer player, String asset) async {
    if (!AppSettings.soundOn.value) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // A sound problem must never stop the workout.
    }
  }
}
