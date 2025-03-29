import 'package:audioplayers/audioplayers.dart';

class SoundPlayer {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playRoundStartSound() async {
    await _audioPlayer.play(AssetSource('sounds/start_boxing_bell.mp3'));
  }

  static Future<void> playEndRoundSound() async {
    await _audioPlayer.play(AssetSource('sounds/end_boxing_bell.mp3'));
  }

  static Future<void> playBeepSound() async {
    await _audioPlayer.play(AssetSource('sounds/beep_sound.mp3'));
  }

}