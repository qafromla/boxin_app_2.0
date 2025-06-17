import 'package:flutter/material.dart';
import 'dart:async';
import 'package:boxing_app/widgets/timer_body.dart';
import 'package:boxing_app/utilities/time_formatter.dart';
import 'package:boxing_app/widgets/round_progress_bar.dart';
import 'package:boxing_app/utilities/sound_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:boxing_app/models/training_session.dart';
import 'package:boxing_app/widgets/training_storage.dart';

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
  int roundsCompleted = 0;

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
      // 🔊 Countdown beep at 5, 4, 3, 2, 1 seconds
      if (timeLeft <= 6 && timeLeft > 0) {
        SoundPlayer.playBeepSound();
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
      currentRound++;
      roundsCompleted = currentRound;
      if (currentRound <= widget.rounds) {
        timeLeft = widget.roundLength;
        SoundPlayer.playRoundStartSound();
      } else {
        stopTimer(userInitiated: false); // Automatically stop when workout ends
      }
    } else {
      if (currentRound < widget.rounds) {
        isResting = true;
        timeLeft = widget.restTime;
        SoundPlayer.playRestStartSound();
      } else {
        stopTimer(userInitiated: false); // Automatically stop when workout ends
      }
    }
  }

  void stopTimer({bool userInitiated = true}) async {
    if (userInitiated) {
      // If user pressed Stop while running — confirm first
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('End Workout?'),
              content: Text(
                'Are you sure you want to complete the workout early?',
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Yes, End Workout'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
      );

      if (confirm != true) return;
    }

    timer?.cancel();
    isRunning = false;
    isResting = false;

    final session = TrainingSession(
      date: DateTime.now(),
      setupRounds: widget.rounds,
      completedRounds: roundsCompleted,
      roundLength: widget.roundLength,
      restTime: widget.restTime,
    );
    await TrainingStorage.saveSession(session);

    _showCompletedDialog();
  }

  void _showCompletedDialog() {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double timerFontSize =
        isPortrait ? screenHeight * 0.12 : screenWidth * 0.12;

    return Scaffold(
      appBar: AppBar(title: Text('Timer')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500, // Limit width for tablet/desktop
                  minWidth: 0,
                  minHeight: constraints.maxHeight,
                ),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RoundDisplay(
                            current: currentRound,
                            total: widget.rounds,
                          ),
                          Spacer(),
                          TimerDisplay(
                            timeLeft: timeLeft,
                            formatTime: formatTime,
                            textStyle: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: timerFontSize,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(
                            height:
                                isPortrait
                                    ? screenHeight * 0.03
                                    : screenWidth * 0.03,
                          ),
                          PhaseLabel(isResting: isResting),
                          SizedBox(
                            height:
                                isPortrait
                                    ? screenHeight * 0.03
                                    : screenWidth * 0.03,
                          ),
                          RoundProgressBar(
                            totalRounds: widget.rounds,
                            currentRound: currentRound,
                            isResting: isResting,
                          ),
                          SizedBox(
                            height:
                                isPortrait
                                    ? screenHeight * 0.02
                                    : screenWidth * 0.02,
                          ),
                          _buildControlButtons(),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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
      backgroundColor: WidgetStatePropertyAll(Colors.green[700]),
    );

    final ButtonStyle stopButtonStyle = mainButtonStyle.copyWith(
      backgroundColor: WidgetStatePropertyAll(Colors.grey[600]), // darker gray
      foregroundColor: WidgetStatePropertyAll(Colors.white),
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
