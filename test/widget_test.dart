import 'package:boxing_app/main.dart';
import 'package:boxing_app/screens/workout_screen.dart';
import 'package:boxing_app/services/app_settings.dart';
import 'package:boxing_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home screen shows start button and menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.load();
    await tester.pumpWidget(const BoxingTimerApp());

    expect(find.text('Start Workout'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.text('Training History'), findsNothing);
    expect(find.text('12 rounds · 03:00 · rest 01:00'), findsOneWidget);
  });

  testWidgets('gear icon opens settings with dark mode and history', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.load();
    await AppSettings.setDarkMode(false);
    await tester.pumpWidget(const BoxingTimerApp());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Training History'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(AppSettings.themeMode.value, ThemeMode.dark);
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

  group('workout screen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'sound_on': false});
      await AppSettings.load();
      // The screen-awake plugin isn't available in tests.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
            'dev.flutter.pigeon.wakelock_plus_platform_interface.'
            'WakelockPlusApi.toggle',
            (_) async =>
                const StandardMessageCodec().encodeMessage(<Object?>[null]),
          );
    });

    Future<void> pumpWorkout(
      WidgetTester tester, {
      int rounds = 8,
      int roundLength = 180,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WorkoutScreen(
            rounds: rounds,
            roundLength: roundLength,
            restTime: 60,
            countdownSeconds: 0,
          ),
        ),
      );
    }

    /// Leave the screen so its periodic timers are cancelled.
    Future<void> leave(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    Color? wordColor(WidgetTester tester, String word) =>
        tester.widget<Text>(find.text(word)).style?.color;

    Finder roundTitle(String text) => find.text(text, findRichText: true);

    testWidgets('FIGHT is red and the round shows as 1/8', (tester) async {
      await pumpWorkout(tester);

      expect(roundTitle('Round 1/8'), findsOneWidget);
      expect(wordColor(tester, 'FIGHT'), AppColors.red);
      await leave(tester);
    });

    testWidgets('PAUSED is grey', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpWorkout(tester);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();

      expect(
        wordColor(tester, 'PAUSED'),
        tester.element(find.text('PAUSED')).subtleTextColor,
      );
      await leave(tester);
    });

    testWidgets('REST is green and shows the next round', (tester) async {
      // A zero-length round moves to rest on the first tick.
      await pumpWorkout(tester, roundLength: 0);
      await tester.pump(const Duration(milliseconds: 250));

      expect(roundTitle('Next: Round 2/8'), findsOneWidget);
      expect(wordColor(tester, 'REST'), AppColors.restText);
      await leave(tester);
    });

    testWidgets('background stays the normal theme color', (tester) async {
      await pumpWorkout(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNull);
      await leave(tester);
    });

    testWidgets('words use the original timer screen sizes', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpWorkout(tester);

      expect(tester.widget<Text>(find.text('FIGHT')).style?.fontSize, 48);
      expect(
        tester.widget<Text>(find.text('03:00')).style?.fontSize,
        closeTo(844 * 0.12, 0.01),
      );
      final title = tester.widget<Text>(
        find.ancestor(
          of: roundTitle('Round 1/8'),
          matching: find.byType(Text),
        ),
      );
      expect(title.textSpan?.style?.fontSize, 30);
      await leave(tester);
    });

    for (final size in const [Size(320, 568), Size(568, 320), Size(844, 390)]) {
      testWidgets('30 rounds fit without overflow at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await pumpWorkout(tester, rounds: 30);

        expect(tester.takeException(), isNull);
        expect(roundTitle('Round 1/30'), findsOneWidget);
        await leave(tester);
      });
    }
  });
}
