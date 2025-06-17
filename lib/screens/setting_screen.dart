import 'package:boxing_app/widgets/countdown_overlay.dart';
import 'package:flutter/material.dart';
import 'package:boxing_app/widgets/icon_buttons.dart';
import 'package:boxing_app/widgets/bottom_button.dart';
import 'package:boxing_app/screens/timer_sreen.dart';
import '../main.dart'; // Import the themeNotifier
import 'package:boxing_app/screens/traing_history_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _showCoundown = false;
  int _roundLength = 180;

  int _restTime = 60;

  int _rounds = 12;

  void _incrementRoundLength() {
    setState(() {
      _roundLength += 30;
    });
  }

  void _decrementRoundLength() {
    setState(() {
      if (_roundLength > 30) {
        _roundLength -= 30;
      }
    });
  }

  void _incrementRestTime() {
    setState(() {
      _restTime += 30;
    });
  }

  void _decrementRestTime() {
    setState(() {
      if (_restTime > 30) {
        _restTime -= 30;
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
      appBar: AppBar(
        title: Text('Boxing Timer Setting'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'darkMode') {
                setState(() {
                  themeNotifier.value =
                      themeNotifier.value == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                });
              } else if (value == 'subscription') {
                // Future functionality for subscription
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Subscription'),
                        content: Text('This feature will be available soon.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                );
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainingHistoryScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'darkMode',
                  child: Row(
                    children: [
                      Text('Dark Mode'),
                      Spacer(),
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
                ),
                PopupMenuItem<String>(
                  value: 'subscription',
                  child: Text('Subscription'),
                  // Add this line
                ),
                PopupMenuItem<String>(
                  value: 'history',
                  child: Text('Traing History'),
                  // Add this line
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                    RoundIconButton(
                      icon: Icons.add,
                      onPressed: _incrementRestTime,
                    ),
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
                    RoundIconButton(
                      icon: Icons.add,
                      onPressed: _incrementRounds,
                    ),
                  ],
                ),
                SizedBox(height: 50),

                Spacer(),
                BottomButton(
                  bottomTitle: 'Start timer',
                  onTap: () {
                    setState(() {
                      _showCoundown = true;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_showCoundown)
            CountdownOverlay(
              onCountdownComplete: () {
                setState(() {
                  _showCoundown = false;
                });
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
    );
  }
}
