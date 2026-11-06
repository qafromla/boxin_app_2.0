import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'app_settings_screen.dart';
import 'settings_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => WorkoutScreen(
              rounds: AppSettings.rounds.value,
              roundLength: AppSettings.roundLength.value,
              restTime: AppSettings.restTime.value,
            ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TopBar(),
                        const SizedBox(height: 4),
                        const _Hero(),
                        const SizedBox(height: 8),
                        Text(
                          'Round Timer for Training',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: context.subtleTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const _CurrentSetup(),
                        const SizedBox(height: 22),
                        PrimaryButton(
                          label: 'Start Workout',
                          onPressed: () => _startWorkout(context),
                        ),
                        const SizedBox(height: 18),
                        MenuTile(
                          icon: Icons.tune_rounded,
                          title: 'Workout Settings',
                          onTap: () => _open(context, const SettingsScreen()),
                        ),
                        const SizedBox(height: 10),
                        MenuTile(
                          icon: Icons.layers_outlined,
                          title: 'Presets',
                          onTap:
                              () => _open(
                                context,
                                const SettingsScreen(showPresets: true),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: 26),
        const Spacer(),
        ValueListenableBuilder<bool>(
          valueListenable: AppSettings.soundOn,
          builder:
              (context, soundOn, _) => IconButton(
                tooltip: soundOn ? 'Sound on' : 'Sound off',
                icon: Icon(
                  soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                ),
                onPressed: () => AppSettings.setSoundOn(!soundOn),
              ),
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_rounded),
          onPressed:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
              ),
        ),
      ],
    );
  }
}

/// Glove with red speed streaks behind it.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _StreaksPainter())),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.red.withValues(alpha: context.isDark ? 0.35 : 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Icon(Icons.sports_mma_rounded, size: 120, color: AppColors.red),
        ],
      ),
    );
  }
}

class _StreaksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streaks = [
      (0.05, 0.75, 0.55, 0.30, 10.0, 0.9),
      (0.00, 0.88, 0.45, 0.50, 5.0, 0.6),
      (0.12, 0.95, 0.60, 0.55, 3.0, 0.4),
      (0.55, 0.20, 1.00, 0.02, 4.0, 0.35),
    ];
    for (final (x1, y1, x2, y2, width, alpha) in streaks) {
      final paint =
          Paint()
            ..color = AppColors.red.withValues(alpha: alpha)
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x1 * size.width, y1 * size.height),
        Offset(x2 * size.width, y2 * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "12 rounds · 03:00 · rest 01:00" — what Start Workout will run.
class _CurrentSetup extends StatelessWidget {
  const _CurrentSetup();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AppSettings.rounds,
        AppSettings.roundLength,
        AppSettings.restTime,
      ]),
      builder: (context, _) {
        final rounds = AppSettings.rounds.value;
        return Text(
          '$rounds ${rounds == 1 ? 'round' : 'rounds'} · '
          '${formatTime(AppSettings.roundLength.value)} · '
          'rest ${formatTime(AppSettings.restTime.value)}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.red,
          ),
        );
      },
    );
  }
}
