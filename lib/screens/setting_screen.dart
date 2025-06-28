import 'package:boxing_app/widgets/countdown_overlay.dart';
import 'package:flutter/material.dart';
import 'package:boxing_app/widgets/icon_buttons.dart';
import 'package:boxing_app/widgets/bottom_button.dart';
import 'package:boxing_app/screens/timer_sreen.dart';
import '../main.dart'; // themeNotifier
import 'package:boxing_app/screens/traing_history_screen.dart';
import 'package:boxing_app/utilities/sound_setting.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _showCoundown = false;
  int _roundLength = 180;
  int _restTime = 60;
  int _rounds = 12;

  void _incrementRoundLength() => setState(() => _roundLength += 30);
  void _decrementRoundLength() => setState(() {
    if (_roundLength > 30) _roundLength -= 30;
  });

  void _incrementRestTime() => setState(() => _restTime += 30);
  void _decrementRestTime() => setState(() {
    if (_restTime > 30) _restTime -= 30;
  });

  void _incrementRounds() => setState(() => _rounds++);
  void _decrementRounds() => setState(() {
    if (_rounds > 1) _rounds--;
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final popupTheme = Theme.of(context).copyWith(
      cardColor: Colors.black,
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Boxing Timer Setting'),
        actions: [
          Theme(
            data: popupTheme,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'darkMode') {
                  setState(() {
                    themeNotifier.value =
                        themeNotifier.value == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                  });
                } else if (value == 'subscription') {
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
                } else if (value == 'sound') {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Sound'),
                          content: ValueListenableBuilder<bool>(
                            valueListenable: soundOnNotifier,
                            builder:
                                (context, soundOn, _) => SwitchListTile(
                                  title: Text(
                                    soundOn ? 'Sound is ON' : 'Sound is OFF',
                                  ),
                                  value: soundOn,
                                  onChanged: (val) {
                                    soundOnNotifier.value = val;
                                    Navigator.pop(context);
                                  },
                                  secondary: Icon(
                                    soundOn
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                  ),
                                ),
                          ),
                        ),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode, size: 20),
                          SizedBox(width: 8),
                          Text('Dark Mode'),
                          Spacer(),
                          StatefulBuilder(
                            builder:
                                (context, innerSetState) => Switch(
                                  value: themeNotifier.value == ThemeMode.dark,
                                  onChanged: (value) {
                                    innerSetState(() {});
                                    setState(() {
                                      themeNotifier.value =
                                          value
                                              ? ThemeMode.dark
                                              : ThemeMode.light;
                                    });
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'sound',
                      child: ValueListenableBuilder<bool>(
                        valueListenable: soundOnNotifier,
                        builder:
                            (context, soundOn, _) => Row(
                              children: [
                                Icon(
                                  soundOn ? Icons.volume_up : Icons.volume_off,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(soundOn ? 'Sound On' : 'Sound Off'),
                              ],
                            ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'subscription',
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, size: 20),
                          SizedBox(width: 8),
                          Text('Subscription'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 20),
                          SizedBox(width: 8),
                          Text('Training History'),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
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
