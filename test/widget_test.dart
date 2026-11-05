import 'package:boxing_app/main.dart';
import 'package:boxing_app/services/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home screen shows start button and menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.load();
    await tester.pumpWidget(const BoxingTimerApp());

    expect(find.text('Start Workout'), findsOneWidget);
    expect(find.text('Training History'), findsOneWidget);
    expect(find.text('12 rounds · 03:00 · rest 01:00'), findsOneWidget);
  });

  testWidgets('settings changes are remembered', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.load();
    await AppSettings.setWorkout(rounds: 5, roundLength: 120, restTime: 30);

    await AppSettings.load(); // like reopening the app
    expect(AppSettings.rounds.value, 5);
    expect(AppSettings.roundLength.value, 120);
    expect(AppSettings.restTime.value, 30);
  });
}
