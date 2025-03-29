import 'package:flutter/material.dart';


class RoundProgressBar extends StatelessWidget {
  final int totalRounds;
  final int currentRound;

  const RoundProgressBar({
    Key? key,
    required this.totalRounds,
    required this.currentRound,
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

        if (roundNumber < currentRound) {
          color = Colors.green; // Completed
        } else if (roundNumber == currentRound) {
          color = Colors.orange; // Current round
        } else {
          color = Colors.grey; // Not yet started
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