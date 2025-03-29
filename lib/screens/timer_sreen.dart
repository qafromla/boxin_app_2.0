import 'package:flutter/material.dart';
import 'dart:async';
import 'package:boxing_app/widgets/timer_body.dart';
import 'package:boxing_app/utilities/time_formatter.dart';
import 'package:boxing_app/widgets/round_progress_bar.dart';
import 'package:boxing_app/utilities/sound_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerScreen extends StatefulWidget {
  final int roundLength;
  final int restTime;
  final int rounds;

  const TimerScreen({
    super.key,
    required this.restTime,
    required this.roundLength,
    required this.rounds,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int timeLeft;
  late int currentRound;
  bool isRunning = false;
  bool isResting = false;
  bool isPaused = false;
  Timer? timer;
  bool justBeeped = false;

  @override
  void initState() {
    super.initState();
    currentRound = 1;
    timeLeft = widget.roundLength;
    Future.delayed(Duration(milliseconds: 500), () {
      startTimer();
      WakelockPlus.enable();
    });
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(Duration(seconds: 1), (_) => tick());
  }

  void tick() {
    if (isPaused) return;

    setState(() {
      // 🎯 Play end-round sound 4 seconds before timer ends (only during fight phase)
      if (timeLeft == 4 && !isResting) {
        SoundPlayer.playEndRoundSound();
      }

      if (timeLeft > 0) {
        timeLeft--;
      } else {
        nextRoundOrEnd();
      }
    });
  }

  void nextRoundOrEnd() {
    if (isResting) {
      isResting = false;
      if (currentRound < widget.rounds) {
        currentRound++;
        timeLeft = widget.roundLength;
        SoundPlayer.playRoundStartSound();
      } else {
        stopTimer();
      }
    } else {
      isResting = true;
      timeLeft = widget.restTime;
    }
  }

  void stopTimer() {
    timer?.cancel();
    isRunning = false;
    isResting = false;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Workout Complete!'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed:
                    () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
    );
  }

  void pauseTimer() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeTimer() {
    setState(() {
      isPaused = false;
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RoundDisplay(current: currentRound, total: widget.rounds),
            SizedBox(height: 150),
            TimerDisplay(
              timeLeft: timeLeft,
              formatTime: formatTime,
              textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 120,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 40),
            PhaseLabel(isResting: isResting),
            SizedBox(height: 40),
            RoundProgressBar(
              totalRounds: widget.rounds,
              currentRound: currentRound,
            ),
            SizedBox(height: 20),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    final ButtonStyle mainButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.red[700],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    final ButtonStyle continueButtonStyle = mainButtonStyle.copyWith(
      backgroundColor: MaterialStateProperty.all(Colors.green[700]),
    );

    final ButtonStyle stopButtonStyle = mainButtonStyle.copyWith(
      backgroundColor: MaterialStateProperty.all(
        Colors.grey[600],
      ), // darker gray
      foregroundColor: MaterialStateProperty.all(Colors.white),
    );

    if (isPaused) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: resumeTimer,
            style: continueButtonStyle,
            child: const Text('Continue'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: stopTimer,
            style: stopButtonStyle,
            child: const Text('Stop'),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: pauseTimer,
        style: mainButtonStyle,
        child: const Text('Pause'),
      );
    }
  }
}
