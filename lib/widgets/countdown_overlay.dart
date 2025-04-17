import 'dart:async';
import 'package:flutter/material.dart';
import '../utilities/sound_player.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onCountdownComplete;

  const CountdownOverlay({required this.onCountdownComplete, super.key});

  @override
  _CountdownOverlayState createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _currentCount = 5;
  Color _bgColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 1) {
        SoundPlayer.playBeepSound();
        setState(() {
          _currentCount--;
        });
      } else {
        timer.cancel();
        setState(() {
          _bgColor = Colors.green;
          _currentCount = 0;
        });

        SoundPlayer.playRoundStartSound();

        Future.delayed(const Duration(milliseconds: 600), () {
          widget.onCountdownComplete();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: Center(
        child: Text(
          _currentCount > 0 ? '$_currentCount' : 'Go!',
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
