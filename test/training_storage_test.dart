import 'dart:convert';

import 'package:boxing_app/models/training_session.dart';
import 'package:boxing_app/screens/training_history_screen.dart';
import 'package:boxing_app/services/training_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

TrainingSession session(DateTime date, {int rounds = 3}) => TrainingSession(
  date: date,
  setupRounds: 3,
  completedRounds: rounds,
  roundLength: 180,
  restTime: 60,
  actualSeconds: 660,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('deleting removes exactly the chosen session', () async {
    final a = session(DateTime(2026, 10, 1));
    final b = session(DateTime(2026, 10, 2));
    final c = session(DateTime(2026, 10, 3));
    for (final s in [a, b, c]) {
      await TrainingStorage.saveSession(s);
    }
    await TrainingStorage.deleteSession(c.id); // the newest one

    final left = await TrainingStorage.getSessions();
    expect(left.map((s) => s.id), [a.id, b.id]);
  });

  test('old sessions without id or real time still load', () async {
    SharedPreferences.setMockInitialValues({
      'training_history': [
        jsonEncode({
          'date': '2026-09-01T18:00:00.000',
          'setupRounds': 12,
          'completedRounds': 12,
          'roundLength': 180,
          'restTime': 60,
        }),
      ],
    });
    final sessions = await TrainingStorage.getSessions();
    expect(sessions, hasLength(1));
    expect(sessions.first.totalTrainingTime, 12 * 180 + 11 * 60);

    await TrainingStorage.deleteSession(sessions.first.id);
    expect(await TrainingStorage.getSessions(), isEmpty);
  });

  test('history stats: this week, total rounds, streak', () {
    final now = DateTime(2026, 11, 4, 20); // Wednesday
    final stats = HistoryStats.from([
      session(DateTime(2026, 11, 4, 9)),
      session(DateTime(2026, 11, 3, 9)),
      session(DateTime(2026, 11, 2, 9), rounds: 2),
      session(DateTime(2026, 10, 30, 9)),
    ], now);
    expect(stats.thisWeek, 3);
    expect(stats.totalRounds, 11);
    expect(stats.streak, 3);
  });
}
