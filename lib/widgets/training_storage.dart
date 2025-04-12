import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_session.dart';

class TrainingStorage {
  static const _key = 'training_history';

  static Future<void> saveSession(TrainingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getSessions();
    sessions.add(session);

    final jsonList =
        sessions.map((session) => jsonEncode(session.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<TrainingSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map((jsonStr) => TrainingSession.fromJson(jsonDecode(jsonStr)))
        .toList();
  }
}
