import 'dart:async';
import 'package:flutter/material.dart';
import 'package:boxing_app/screens/timer_sreen.dart';
import 'package:boxing_app/utilities/sound_player.dart';

Future<void> launchCountdownAndNavigate({
  required BuildContext context,
  required int roundLength,
  required int restTime,
  required int rounds,
}) async {
  int countdown = 5;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Timer.periodic(Duration(seconds: 1), (timer) {
            if (countdown > 1) {
              countdown--;
              setState(() {});
              SoundPlayer.playBeepSound();
            } else {
              timer.cancel();
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TimerScreen(
                        roundLength: roundLength,
                        restTime: restTime,
                        rounds: rounds,
                      ),
                ),
              );
              SoundPlayer.playRoundStartSound();
            }
          });

          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Starting in...', style: TextStyle(fontSize: 22)),
                SizedBox(height: 20),
                Text(
                  '$countdown',
                  style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
