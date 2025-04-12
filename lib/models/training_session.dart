class TrainingSession {
  final DateTime date;
  final int rounds;
  final int roundLength;
  final int restTime;

  TrainingSession({
    required this.date,
    required this.rounds,
    required this.roundLength,
    required this.restTime,
  });

  int get totalTrainingTime =>
      (rounds * roundLength) + ((rounds - 1) * restTime);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'rounds': rounds,
    'roundLength': roundLength,
    'restTime': restTime,
  };

  static TrainingSession fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      date: DateTime.parse(json['date']),
      rounds: json['rounds'],
      roundLength: json['roundLength'],
      restTime: json['restTime'],
    );
  }
}
