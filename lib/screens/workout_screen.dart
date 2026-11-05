import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../logic/workout_engine.dart';
import '../models/training_session.dart';
import '../services/app_settings.dart';
import '../services/sound_player.dart';
import '../services/training_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    super.key,
    required this.rounds,
    required this.roundLength,
    required this.restTime,
    this.countdownSeconds = 5,
  });

  final int rounds;
  final int roundLength;
  final int restTime;

  /// "5, 4, 3, 2, 1, GO!" before the first round. 0 = start right away.
  final int countdownSeconds;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutEngine _engine = WorkoutEngine(
    rounds: widget.rounds,
    roundLength: widget.roundLength,
    restTime: widget.restTime,
  );

  Timer? _ticker;
  Timer? _countdownTimer;
  late int? _countdown = widget.countdownSeconds > 0
      ? widget.countdownSeconds
      : null;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    if (_countdown != null) {
      SoundPlayer.playBeep();
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _countdownTick(),
      );
    } else {
      _begin();
    }
  }

  void _countdownTick() {
    if (!mounted) return;
    final next = (_countdown ?? 0) - 1;
    if (next > 0) {
      SoundPlayer.playBeep();
      setState(() => _countdown = next);
    } else if (next == 0) {
      // Show "GO!" for a moment.
      SoundPlayer.playRoundStart();
      setState(() => _countdown = 0);
    } else {
      _countdownTimer?.cancel();
      setState(() => _countdown = null);
      _begin();
    }
  }

  void _begin() {
    _engine.start();
    // Ticks often only to refresh the screen; the time itself comes from
    // the real clock inside WorkoutEngine.
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final events = _engine.update();
    if (events.isNotEmpty) _playSoundFor(events.last);
    if (events.contains(WorkoutEvent.finished)) {
      _finishWorkout();
    }
    setState(() {});
  }

  void _playSoundFor(WorkoutEvent event) {
    switch (event) {
      case WorkoutEvent.beep:
        SoundPlayer.playBeep();
      case WorkoutEvent.roundStart:
        SoundPlayer.playRoundStart();
      case WorkoutEvent.restStart:
        SoundPlayer.playRestStart();
      case WorkoutEvent.finished:
        SoundPlayer.playWorkoutEnd();
    }
  }

  Future<void> _saveSession() async {
    if (_saved) return;
    _saved = true;
    _ticker?.cancel();
    final seconds = _engine.elapsed.inSeconds;
    if (seconds <= 0) return; // nothing to save
    await TrainingStorage.saveSession(
      TrainingSession(
        date: DateTime.now(),
        setupRounds: widget.rounds,
        completedRounds: _engine.completedRounds,
        roundLength: widget.roundLength,
        restTime: widget.restTime,
        actualSeconds: seconds,
      ),
    );
  }

  Future<void> _finishWorkout() async {
    await _saveSession();
    if (!mounted) return;
    setState(() {});
    await _showSummary(title: 'Workout Complete! 🥊');
  }

  /// Stop button and the Back button both come here.
  Future<void> _askToStop() async {
    if (_engine.isOver) {
      Navigator.of(context).pop();
      return;
    }
    if (_countdown != null) {
      // Workout hasn't started yet — nothing to save.
      _countdownTimer?.cancel();
      Navigator.of(context).pop();
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End workout?'),
            content: const Text(
              'Your progress so far will be saved to Training History.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep going'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('End workout'),
              ),
            ],
          ),
    );
    if (confirm != true || !mounted) return;
    _engine.stop();
    await _saveSession();
    if (!mounted) return;
    setState(() {});
    if (_engine.elapsed.inSeconds > 0) {
      await _showSummary(title: 'Workout Saved');
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showSummary({required String title}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(
              'Rounds: ${_engine.completedRounds} of ${widget.rounds}\n'
              'Total time: ${formatTime(_engine.elapsed.inSeconds)}',
              style: const TextStyle(fontSize: 17),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // Fix: the timer used to keep running after leaving the screen.
    _ticker?.cancel();
    _countdownTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // ---------------------------------------------------------------- UI

  Color get _phaseColor {
    if (_engine.isPaused) return AppColors.orange;
    if (_engine.phase == WorkoutPhase.rest) return AppColors.green;
    if (_engine.remainingSeconds <= 10) return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _engine.isOver && _saved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _askToStop();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Workout'),
              actions: [
                ValueListenableBuilder<bool>(
                  valueListenable: AppSettings.soundOn,
                  builder:
                      (context, soundOn, _) => IconButton(
                        tooltip: soundOn ? 'Mute' : 'Unmute',
                        icon: Icon(
                          soundOn
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                        ),
                        onPressed: () => AppSettings.setSoundOn(!soundOn),
                      ),
                ),
              ],
            ),
            body: SafeArea(child: _buildBody(context)),
          ),
          if (_countdown != null) _CountdownOverlay(value: _countdown!),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final timerSize = (size.shortestSide * 0.28).clamp(64.0, 150.0);
    final color = _phaseColor;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 8),
                      _RoundTitle(
                        current: _engine.currentRound,
                        total: widget.rounds,
                        isRest: _engine.phase == WorkoutPhase.rest,
                      ),
                      const SizedBox(height: 16),
                      _PhaseChip(
                        text: _phaseText,
                        color:
                            _engine.isPaused || _engine.isOver
                                ? context.subtleTextColor
                                : color,
                      ),
                      SizedBox(
                        height: timerSize * 1.6,
                        child: Center(
                          child:
                              _engine.isPaused
                                  ? _PausedView(
                                    remaining: _engine.remainingSeconds,
                                  )
                                  : _TimerText(
                                    seconds: _engine.remainingSeconds,
                                    size: timerSize,
                                    glow: color,
                                    color:
                                        _engine.remainingSeconds <= 10 &&
                                                _engine.phase ==
                                                    WorkoutPhase.work &&
                                                !_engine.isOver
                                            ? AppColors.orange
                                            : context.textColor,
                                  ),
                        ),
                      ),
                      RoundSegments(
                        total: widget.rounds,
                        current: _engine.currentRound,
                        isDone: _engine.isRoundDone,
                        activeColor:
                            _engine.phase == WorkoutPhase.rest
                                ? AppColors.green
                                : AppColors.red,
                      ),
                      const SizedBox(height: 36),
                      _buildControls(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  String get _phaseText {
    if (_engine.isFinished) return 'DONE';
    if (_engine.isOver) return 'STOPPED';
    if (_engine.isPaused) return 'PAUSED';
    if (_engine.phase == WorkoutPhase.rest) return 'REST';
    return 'FIGHT';
  }

  Widget _buildControls() {
    if (_engine.isOver) return const SizedBox(height: 100);

    if (_engine.isPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleControl(
            icon: Icons.replay_rounded,
            label: 'Restart',
            onPressed: () => setState(_engine.restartPhase),
          ),
          CircleControl(
            icon: Icons.play_arrow_rounded,
            label: 'Continue',
            color: AppColors.green,
            size: 80,
            onPressed: () => setState(_engine.resume),
          ),
          CircleControl(
            icon: Icons.stop_rounded,
            label: 'Stop',
            onPressed: _askToStop,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleControl(
          icon: Icons.chevron_left_rounded,
          label: '−30s',
          onPressed:
              () => setState(() => _engine.adjust(const Duration(seconds: -30))),
        ),
        CircleControl(
          icon: Icons.pause_rounded,
          label: 'Pause',
          color: AppColors.red,
          size: 80,
          onPressed: () => setState(_engine.pause),
        ),
        CircleControl(
          icon: Icons.chevron_right_rounded,
          label: '+30s',
          onPressed:
              () => setState(() => _engine.adjust(const Duration(seconds: 30))),
        ),
      ],
    );
  }
}

class _RoundTitle extends StatelessWidget {
  const _RoundTitle({
    required this.current,
    required this.total,
    required this.isRest,
  });

  final int current;
  final int total;
  final bool isRest;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 28, fontWeight: FontWeight.w800);
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: style.copyWith(color: context.textColor),
            children: [
              TextSpan(text: isRest ? 'Next: Round ' : 'Round '),
              TextSpan(
                text: '${isRest ? current + 1 : current}',
                style: const TextStyle(color: AppColors.red),
              ),
              TextSpan(text: ' of $total'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 130,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _TimerText extends StatelessWidget {
  const _TimerText({
    required this.seconds,
    required this.size,
    required this.color,
    required this.glow,
  });

  final int seconds;
  final double size;
  final Color color;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: context.isDark ? 0.22 : 0.12),
            blurRadius: 80,
            spreadRadius: 10,
          ),
        ],
      ),
      child: FittedBox(
        child: Text(
          formatTime(seconds),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _PausedView extends StatelessWidget {
  const _PausedView({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.25),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pause_rounded, size: 84, color: AppColors.orange),
          const Text(
            'PAUSED',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
          ),
          Text(
            '${formatTime(remaining)} left',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.subtleTextColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen "5, 4, 3, 2, 1, GO!" before the first round.
class _CountdownOverlay extends StatelessWidget {
  const _CountdownOverlay({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final go = value == 0;
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: go ? AppColors.green : AppColors.red,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  go ? 'GO!' : 'GET READY',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                if (!go)
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 150,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
