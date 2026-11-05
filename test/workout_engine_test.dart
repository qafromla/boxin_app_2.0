import 'package:boxing_app/logic/workout_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake clock we can move forward by hand.
class FakeClock {
  DateTime now = DateTime(2026, 1, 1, 10);
  void advance(int seconds) => now = now.add(Duration(seconds: seconds));
}

WorkoutEngine engine(
  FakeClock clock, {
  int rounds = 3,
  int roundLength = 180,
  int restTime = 60,
}) => WorkoutEngine(
  rounds: rounds,
  roundLength: roundLength,
  restTime: restTime,
  clock: () => clock.now,
);

void main() {
  test('stopping in the middle of round 2 counts 1 completed round', () {
    final clock = FakeClock();
    final e = engine(clock)..start();
    clock.advance(180 + 60 + 30); // round 1, rest, 30s into round 2
    e.update();
    expect(e.currentRound, 2);
    e.stop();
    expect(e.completedRounds, 1);
    expect(e.elapsed.inSeconds, 270);
  });

  test('a single-round workout finished counts 1 of 1', () {
    final clock = FakeClock();
    final e = engine(clock, rounds: 1)..start();
    clock.advance(180);
    final events = e.update();
    expect(events, contains(WorkoutEvent.finished));
    expect(e.completedRounds, 1);
    expect(e.elapsed.inSeconds, 180);
  });

  test('full workout counts all rounds and real total time', () {
    final clock = FakeClock();
    final e = engine(clock, rounds: 12)..start();
    clock.advance(12 * 180 + 11 * 60 + 500); // long after the end
    e.update();
    expect(e.isFinished, isTrue);
    expect(e.completedRounds, 12);
    expect(e.elapsed.inSeconds, 12 * 180 + 11 * 60); // 48:00
  });

  test('pauses are not counted in total time', () {
    final clock = FakeClock();
    final e = engine(clock)..start();
    clock.advance(60);
    e.pause();
    clock.advance(600); // long pause
    expect(e.remainingSeconds, 120);
    e.resume();
    clock.advance(30);
    e.update();
    expect(e.remainingSeconds, 90);
    e.stop();
    expect(e.elapsed.inSeconds, 90);
  });

  test('timer stays correct after time passes in the background', () {
    final clock = FakeClock();
    final e = engine(clock)..start();
    clock.advance(180 + 60 + 100); // nothing called update meanwhile
    e.update();
    expect(e.phase, WorkoutPhase.work);
    expect(e.currentRound, 2);
    expect(e.remainingSeconds, 80);
  });

  test('beeps exactly 5 times before a round ends', () {
    final clock = FakeClock();
    final e = engine(clock, roundLength: 30, restTime: 30)..start();
    var beeps = 0;
    for (var ms = 0; ms < 30000; ms += 200) {
      clock.now = clock.now.add(const Duration(milliseconds: 200));
      beeps += e.update().where((ev) => ev == WorkoutEvent.beep).length;
      if (e.phase == WorkoutPhase.rest) break;
    }
    expect(beeps, 5);
  });

  test('no rest time goes straight to the next round', () {
    final clock = FakeClock();
    final e = engine(clock, restTime: 0)..start();
    clock.advance(180);
    final events = e.update();
    expect(events, contains(WorkoutEvent.roundStart));
    expect(e.currentRound, 2);
    expect(e.completedRounds, 1);
  });

  test('-30s / +30s change the time left', () {
    final clock = FakeClock();
    final e = engine(clock)..start();
    e.adjust(const Duration(seconds: 30));
    expect(e.remainingSeconds, 210);
    e.adjust(const Duration(seconds: -60));
    expect(e.remainingSeconds, 150);
    e.restartPhase();
    expect(e.remainingSeconds, 180);
  });
}
