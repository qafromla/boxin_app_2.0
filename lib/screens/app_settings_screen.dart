import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'training_history_screen.dart';

/// App-wide settings, opened from the gear icon on the home screen.
/// (Rounds and timing live in [SettingsScreen], "Workout Settings".)
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                AppCard(
                  onTap: () => AppSettings.setDarkMode(!isDark),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: context.subtleTextColor,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Switch(value: isDark, onChanged: AppSettings.setDarkMode),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                MenuTile(
                  icon: Icons.bar_chart_rounded,
                  title: 'Training History',
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TrainingHistoryScreen(),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
