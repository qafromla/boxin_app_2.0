import 'package:flutter/material.dart';

class RoundDisplay extends StatelessWidget {
  final int current;
  final int total;

  const RoundDisplay({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Round: $current / $total',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,),
    );
  }
}


class PhaseLabel extends StatelessWidget {
  final bool isResting;

  const PhaseLabel({super.key, required this.isResting});

  @override
  Widget build(BuildContext context) {
    return Text(
      isResting ? 'REST' : 'FIGHT',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: isResting ? Colors.blue[700] : Colors.red[800],
        letterSpacing: 2,
      ),
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final int timeLeft;
  final String Function(int) formatTime;

  const TimerDisplay({
    super.key,
    required this.timeLeft,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(timeLeft),
      style: const TextStyle(
        fontSize: 120,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        letterSpacing: 2,
      ),
    );
  }
}