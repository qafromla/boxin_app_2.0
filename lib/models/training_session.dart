class TrainingSession {
  final DateTime date;
  final int setupRounds;
  final int completedRounds;
  final int roundLength;
  final int restTime;

  TrainingSession({
    required this.date,
    required this.completedRounds,
    required this.setupRounds,
    required this.roundLength,
    required this.restTime,
  });

  int get totalTrainingTime =>
      (completedRounds * roundLength) +
      ((completedRounds > 0 ? completedRounds - 1 : 0) * restTime);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'setupRounds': setupRounds,
    'completedRounds': completedRounds,
    'roundLength': roundLength,
    'restTime': restTime,
  };

  static TrainingSession fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      date: DateTime.parse(json['date']),
      setupRounds: json['setupRounds'],
      completedRounds: json['completedRounds'],
      roundLength: json['roundLength'],
      restTime: json['restTime'],
    );
  }
}
