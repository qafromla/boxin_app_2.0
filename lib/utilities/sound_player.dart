import 'package:audioplayers/audioplayers.dart';

class SoundPlayer {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playRoundStartSound() async {
    await _audioPlayer.play(AssetSource('sounds/boxing_bell_1.wav'));
  }

  static Future<void> playEndRoundSound() async {
    await _audioPlayer.play(AssetSource('sounds/boxing_bell_1.wav'));
  }

  static Future<void> playBeepSound() async {
    await _audioPlayer.play(AssetSource('sounds/beep_sound_1.wav'));
  }

  static Future<void> playRestStartSound() async {
    await _audioPlayer.play(AssetSource('sounds/boxing_bell_1.wav'));
  }
}
