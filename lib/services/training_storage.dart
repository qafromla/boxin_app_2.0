import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_session.dart';

/// Saves and loads Training History on the device.
class TrainingStorage {
  static const _key = 'training_history';

  /// All sessions, oldest first. Broken entries are skipped instead of
  /// crashing the whole history screen.
  static Future<List<TrainingSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    final sessions = <TrainingSession>[];
    for (final jsonStr in jsonList) {
      try {
        sessions.add(
          TrainingSession.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore a corrupted entry.
      }
    }
    return sessions;
  }

  static Future<void> saveSession(TrainingSession session) async {
    final sessions = await getSessions();
    sessions.add(session);
    await _write(sessions);
  }

  /// Deletes exactly the session with this id (not "the n-th one"), so the
  /// order of the list on screen can never delete the wrong workout.
  static Future<void> deleteSession(String id) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _write(sessions);
  }

  static Future<void> clearTrainingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _write(List<TrainingSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      sessions.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
