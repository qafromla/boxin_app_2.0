import 'package:flutter/material.dart';
import 'package:boxing_app/widgets/icon_buttons.dart';
import 'package:boxing_app/widgets/bottom_button.dart';
import 'package:boxing_app/screens/timer_sreen.dart'; // Import TimerScreen
import 'package:boxing_app/utilities/sound_player.dart';
import '../main.dart'; // Import the themeNotifier

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _roundLength = 60;

  int _restTime = 30;

  int _rounds = 3;

  void _incrementRoundLength() {
    setState(() {
      _roundLength += 10;
    });
  }

  void _decrementRoundLength() {
    setState(() {
      if (_roundLength > 10) {
        _roundLength -= 10;
      }
    });
  }

  void _incrementRestTime() {
    setState(() {
      _restTime += 10;
    });
  }

  void _decrementRestTime() {
    setState(() {
      if (_restTime > 10) {
        _restTime -= 10;
      }
    });
  }

  void _incrementRounds() {
    setState(() {
      _rounds++;
    });
  }

  void _decrementRounds() {
    setState(() {
      if (_rounds > 1) _rounds--;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = sec.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boxing Timer Setting')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            //Slider for Round Length
            Text(
              'Round Length: ${_formatTime(_roundLength)}',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(
                  icon: Icons.remove,
                  onPressed: _decrementRoundLength,
                ),
                SizedBox(width: 20.0),
                RoundIconButton(
                  icon: Icons.add,
                  onPressed: _incrementRoundLength,
                ),
              ],
            ),
            SizedBox(height: 50),
            // Slider for Rest time
            Text(
              'Rest Time: ${_formatTime(_restTime)}',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(
                  icon: Icons.remove,
                  onPressed: _decrementRestTime,
                ),
                SizedBox(width: 20.0),
                RoundIconButton(icon: Icons.add, onPressed: _incrementRestTime),
              ],
            ),
            SizedBox(height: 50),
            // Slider for Rounds
            Text(
              'Rounds: $_rounds',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(
                  icon: Icons.remove,
                  onPressed: _decrementRounds,
                ),
                SizedBox(width: 20.0),
                RoundIconButton(icon: Icons.add, onPressed: _incrementRounds),
              ],
            ),
            SizedBox(height: 50),
            // Switch for Dark Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dark Mode', style: TextStyle(fontSize: 20)),
                Switch(
                  value: themeNotifier.value == ThemeMode.dark,
                  onChanged: (value) {
                    setState(() {
                      themeNotifier.value =
                          value ? ThemeMode.dark : ThemeMode.light;
                    });
                  },
                ),
              ],
            ),
            Spacer(),
            BottomButton(
              bottomTitle: 'Start timer',
              onTap: () async {
                SoundPlayer.playRoundStartSound();
                await Future.delayed(Duration(milliseconds: 500));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TimerScreen(
                          roundLength: _roundLength,
                          restTime: _restTime,
                          rounds: _rounds,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
