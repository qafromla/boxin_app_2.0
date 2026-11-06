/// One finished (or stopped) workout, as shown in Training History.
class TrainingSession {
  /// Unique id, used to delete exactly this session.
  final String id;
  final DateTime date;
  final int setupRounds;
  final int completedRounds;
  final int roundLength;
  final int restTime;

  /// Real time the timer was running (work + rest), in seconds.
  /// Null only for sessions saved by older app versions.
  final int? actualSeconds;

  TrainingSession({
    String? id,
    required this.date,
    required this.completedRounds,
    required this.setupRounds,
    required this.roundLength,
    required this.restTime,
    this.actualSeconds,
  }) : id = id ?? '${date.microsecondsSinceEpoch}';

  /// Total time of this workout in seconds.
  int get totalTrainingTime =>
      actualSeconds ??
      // Fallback for old sessions that didn't store the real time.
      (completedRounds * roundLength) +
          ((completedRounds > 0 ? completedRounds - 1 : 0) * restTime);

  bool get isFullyCompleted => completedRounds >= setupRounds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'setupRounds': setupRounds,
    'completedRounds': completedRounds,
    'roundLength': roundLength,
    'restTime': restTime,
    'actualSeconds': actualSeconds,
  };

  static TrainingSession fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    return TrainingSession(
      // Old sessions have no id — derive a stable one from the date.
      id: json['id'] as String? ?? date.toIso8601String(),
      date: date,
      setupRounds: (json['setupRounds'] as num?)?.toInt() ?? 0,
      completedRounds: (json['completedRounds'] as num?)?.toInt() ?? 0,
      roundLength: (json['roundLength'] as num?)?.toInt() ?? 0,
      restTime: (json['restTime'] as num?)?.toInt() ?? 0,
      actualSeconds: (json['actualSeconds'] as num?)?.toInt(),
    );
  }
}
