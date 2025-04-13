import 'package:flutter/material.dart';

class RoundProgressBar extends StatelessWidget {
  final int totalRounds;
  final int currentRound;
  final bool isResting;

  const RoundProgressBar({
    Key? key,
    required this.totalRounds,
    required this.currentRound,
    required this.isResting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, // horizontal spacing between items
      runSpacing: 8, // vertical spacing between rows
      alignment: WrapAlignment.center,
      children: List.generate(totalRounds, (index) {
        final roundNumber = index + 1;
        Color color;

        if (roundNumber < currentRound ||
            (roundNumber == currentRound && isResting)) {
          color = Colors.green; // ✅ Mark current round as complete during rest
        } else if (roundNumber == currentRound && !isResting) {
          color = Colors.orange; // 🟧 Active round
        } else if (roundNumber == currentRound + 1 && isResting) {
          color = Colors.yellow; // 🟨 Next round during rest
        } else {
          color = Colors.grey; // 🔘 Not started
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
