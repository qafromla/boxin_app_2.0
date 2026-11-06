import 'dart:math' as math;

enum WorkoutPhase { work, rest, finished }

/// Things that happened during [WorkoutEngine.update] — the screen turns them
/// into sounds.
enum WorkoutEvent { beep, roundStart, restStart, finished }

/// The workout timer logic, with no UI in it (so it can be tested).
///
/// Time is measured against the real clock: we remember *when* the current
/// phase ends instead of counting timer ticks. If the phone locks or the app
/// goes to the background, the timer is still correct when you come back.
class WorkoutEngine {
  WorkoutEngine({
    required this.rounds,
    required this.roundLength,
    required this.restTime,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _remainingWhenStopped = Duration(seconds: roundLength);

  final int rounds;
  final int roundLength; // seconds
  final int restTime; // seconds
  final DateTime Function() _clock;

  WorkoutPhase phase = WorkoutPhase.work;
  int currentRound = 1;

  /// Rounds the user really finished (the whole round, not just started).
  int completedRounds = 0;

  bool _running = false;
  bool _stopped = false;
  DateTime? _phaseEnd;
  Duration _remainingWhenStopped;

  Duration _activeBefore = Duration.zero;
  DateTime? _runningSince;
  Duration? _finalElapsed;

  int? _lastBeepSecond;

  bool get isRunning => _running;
  bool get isPaused => !_running && !isOver && _runningSince != null;
  bool get isFinished => phase == WorkoutPhase.finished;

  /// Finished normally or stopped by the user.
  bool get isOver => isFinished || _stopped;

  Duration get remaining {
    if (isOver) return Duration.zero;
    if (_running) {
      final left = _phaseEnd!.difference(_clock());
      return left.isNegative ? Duration.zero : left;
    }
    return _remainingWhenStopped;
  }

  /// Seconds shown on screen (rounded up: 2:59.4 shows as 3:00).
  int get remainingSeconds => (remaining.inMilliseconds / 1000).ceil();

  /// Real time the timer has been running (pauses not counted).
  Duration get elapsed {
    if (_finalElapsed != null) return _finalElapsed!;
    if (_running) return _activeBefore + _clock().difference(_runningSince!);
    return _activeBefore;
  }

  Duration get _currentPhaseLength => Duration(
    seconds: phase == WorkoutPhase.rest ? restTime : roundLength,
  );

  /// Is round [round] (1-based) already done?
  bool isRoundDone(int round) => round <= completedRounds;

  void start() {
    if (_running || isOver) return;
    final now = _clock();
    _phaseEnd = now.add(_remainingWhenStopped);
    _runningSince = now;
    _running = true;
  }

  void pause() {
    if (!_running) return;
    update();
    if (!_running) return; // finished while catching up
    final now = _clock();
    final left = _phaseEnd!.difference(now);
    _remainingWhenStopped = left.isNegative ? Duration.zero : left;
    _activeBefore += now.difference(_runningSince!);
    _running = false;
  }

  void resume() => start();

  /// User ends the workout early.
  void stop() {
    if (isOver) return;
    if (_running) {
      update();
      if (isFinished) return;
      _activeBefore += _clock().difference(_runningSince!);
      _running = false;
    }
    _finalElapsed = _activeBefore;
    _stopped = true;
  }

  /// Add or remove time from the current phase (the -30s / +30s buttons).
  void adjust(Duration delta) {
    if (isOver) return;
    if (_running) {
      final now = _clock();
      var end = _phaseEnd!.add(delta);
      if (end.isBefore(now)) end = now;
      _phaseEnd = end;
    } else {
      final value = _remainingWhenStopped + delta;
      _remainingWhenStopped = value.isNegative ? Duration.zero : value;
    }
    _lastBeepSecond = null;
  }

  /// Start the current round (or rest) again from the beginning.
  void restartPhase() {
    if (isOver) return;
    if (_running) {
      _phaseEnd = _clock().add(_currentPhaseLength);
    } else {
      _remainingWhenStopped = _currentPhaseLength;
    }
    _lastBeepSecond = null;
  }

  /// Call often (a few times per second). Moves to the next round/rest when
  /// time is up and reports what happened.
  List<WorkoutEvent> update() {
    final events = <WorkoutEvent>[];
    if (!_running) return events;

    final now = _clock();
    // A while-loop, so even after a long time in the background we land in
    // the right round.
    while (_running && !now.isBefore(_phaseEnd!)) {
      _advance(events);
    }

    if (_running) {
      final secs = remainingSeconds;
      // Exactly five beeps: at 5, 4, 3, 2, 1.
      if (secs >= 1 && secs <= 5 && secs != _lastBeepSecond) {
        _lastBeepSecond = secs;
        events.add(WorkoutEvent.beep);
      }
    }
    return events;
  }

  void _advance(List<WorkoutEvent> events) {
    final end = _phaseEnd!;
    _lastBeepSecond = null;

    if (phase == WorkoutPhase.work) {
      completedRounds++;
      if (currentRound >= rounds) {
        _finish(end, events);
      } else if (restTime > 0) {
        phase = WorkoutPhase.rest;
        _phaseEnd = end.add(Duration(seconds: restTime));
        events.add(WorkoutEvent.restStart);
      } else {
        currentRound++;
        _phaseEnd = end.add(Duration(seconds: roundLength));
        events.add(WorkoutEvent.roundStart);
      }
    } else if (phase == WorkoutPhase.rest) {
      currentRound++;
      phase = WorkoutPhase.work;
      _phaseEnd = end.add(Duration(seconds: roundLength));
      events.add(WorkoutEvent.roundStart);
    }
  }

  void _finish(DateTime end, List<WorkoutEvent> events) {
    phase = WorkoutPhase.finished;
    _running = false;
    // Count time only up to the real end of the last round.
    _finalElapsed = _activeBefore + end.difference(_runningSince!);
    completedRounds = math.min(completedRounds, rounds);
    events.add(WorkoutEvent.finished);
  }
}
