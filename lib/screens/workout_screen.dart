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
  late int? _countdown =
      widget.countdownSeconds > 0 ? widget.countdownSeconds : null;
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

  /// Red = fight, green = rest, grey = paused or over.
  Color get _phaseColor {
    if (_engine.isPaused || _engine.isOver) return context.subtleTextColor;
    if (_engine.phase == WorkoutPhase.rest) return AppColors.restText;
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

  /// Word sizes and positions match the original timer screen; colors and
  /// text style come from the app theme.
  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final base = isPortrait ? size.height : size.width;
    final color = _phaseColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              minHeight: constraints.maxHeight,
            ),
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _RoundTitle(
                        current: _engine.currentRound,
                        total: widget.rounds,
                        isRest: _engine.phase == WorkoutPhase.rest,
                      ),
                      const Spacer(),
                      _TimerText(
                        seconds: _engine.remainingSeconds,
                        size: base * 0.12,
                        glow: color,
                        color:
                            _engine.remainingSeconds <= 10 &&
                                    _engine.phase == WorkoutPhase.work &&
                                    !_engine.isOver &&
                                    !_engine.isPaused
                                ? AppColors.orange
                                : context.textColor,
                      ),
                      SizedBox(height: base * 0.03),
                      Text(
                        _phaseText,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: color,
                        ),
                      ),
                      SizedBox(height: base * 0.03),
                      RoundSegments(
                        total: widget.rounds,
                        current: _engine.currentRound,
                        isDone: _engine.isRoundDone,
                        activeColor:
                            _engine.phase == WorkoutPhase.rest
                                ? AppColors.green
                                : AppColors.red,
                      ),
                      SizedBox(height: base * 0.09),
                      _buildControls(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
              () =>
                  setState(() => _engine.adjust(const Duration(seconds: -30))),
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

/// "Round 1/8", or "Next: Round 2/8" during rest.
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
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: context.textColor,
        ),
        children: [
          TextSpan(text: isRest ? 'Next: Round ' : 'Round '),
          TextSpan(
            text: '${isRest ? current + 1 : current}',
            style: const TextStyle(color: AppColors.red, fontSize: 44),
          ),
          TextSpan(text: '/$total', style: const TextStyle(fontSize: 44)),
        ],
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
    );
  }
}

const _bigTextStyle = TextStyle(
  fontSize: 200,
  height: 1.1,
  fontWeight: FontWeight.w900,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// Text scaled to fill whatever space it is given, so it is as large as the
/// screen allows on any phone, in either orientation.
class _BigText extends StatelessWidget {
  const _BigText(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        child: Text(
          text,
          maxLines: 1,
          style: _bigTextStyle.copyWith(color: color),
        ),
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
        child: SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  go
                      ? const _BigText('GO!', color: Colors.white)
                      : Column(
                        children: [
                          const Expanded(
                            child: _BigText('GET READY', color: Colors.white),
                          ),
                          Expanded(
                            flex: 3,
                            child: _BigText('$value', color: Colors.white),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
