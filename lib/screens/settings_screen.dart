import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'workout_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showPresets = false});

  final bool showPresets;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _showPresets = widget.showPresets;
  late int _rounds = AppSettings.rounds.value;
  late int _roundLength = AppSettings.roundLength.value;
  late int _restTime = AppSettings.restTime.value;

  /// Every change is saved right away, so the app always remembers it.
  void _update({int? rounds, int? roundLength, int? restTime}) {
    setState(() {
      _rounds = (rounds ?? _rounds).clamp(1, AppSettings.maxRounds);
      _roundLength = (roundLength ?? _roundLength).clamp(
        AppSettings.minRoundLength,
        AppSettings.maxRoundLength,
      );
      _restTime = (restTime ?? _restTime).clamp(
        AppSettings.minRest,
        AppSettings.maxRest,
      );
    });
    AppSettings.setWorkout(
      rounds: _rounds,
      roundLength: _roundLength,
      restTime: _restTime,
    );
  }

  void _applyPreset(WorkoutPreset p) {
    _update(rounds: p.rounds, roundLength: p.roundLength, restTime: p.restTime);
    setState(() => _showPresets = false);
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => WorkoutScreen(
              rounds: _rounds,
              roundLength: _roundLength,
              restTime: _restTime,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: _TabSwitch(
                    showPresets: _showPresets,
                    onChanged: (v) => setState(() => _showPresets = v),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _showPresets ? _buildPresets() : _buildCustom(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: PrimaryButton(label: 'Save & Start', onPressed: _start),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustom() {
    return ListView(
      key: const ValueKey('custom'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        _StepperCard(
          icon: Icons.timer_outlined,
          label: 'Round Length',
          value: formatTime(_roundLength),
          onMinus:
              _roundLength > AppSettings.minRoundLength
                  ? () => _update(roundLength: _roundLength - 30)
                  : null,
          onPlus:
              _roundLength < AppSettings.maxRoundLength
                  ? () => _update(roundLength: _roundLength + 30)
                  : null,
        ),
        const SizedBox(height: 12),
        _StepperCard(
          icon: Icons.coffee_outlined,
          label: _restTime == 0 ? 'Rest Time (no rest)' : 'Rest Time',
          value: formatTime(_restTime),
          onMinus:
              _restTime > AppSettings.minRest
                  ? () => _update(restTime: _restTime - 15)
                  : null,
          onPlus:
              _restTime < AppSettings.maxRest
                  ? () => _update(restTime: _restTime + 15)
                  : null,
        ),
        const SizedBox(height: 12),
        _StepperCard(
          icon: Icons.layers_outlined,
          label: 'Rounds',
          value: '$_rounds',
          onMinus: _rounds > 1 ? () => _update(rounds: _rounds - 1) : null,
          onPlus:
              _rounds < AppSettings.maxRounds
                  ? () => _update(rounds: _rounds + 1)
                  : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Total: ${formatTime(_rounds * _roundLength + (_rounds - 1) * _restTime)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.subtleTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPresets() {
    return ListView.separated(
      key: const ValueKey('presets'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: kPresets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = kPresets[i];
        final selected =
            p.rounds == _rounds &&
            p.roundLength == _roundLength &&
            p.restTime == _restTime;
        return AppCard(
          onTap: () => _applyPreset(p),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.sports_mma,
                color: AppColors.red,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.rounds} × ${formatTime(p.roundLength)} · '
                      'rest ${formatTime(p.restTime)}',
                      style: TextStyle(color: context.subtleTextColor),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.subtleTextColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom | Presets pill switch.
class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.showPresets, required this.onChanged});

  final bool showPresets;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String text, bool active, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.red : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: active ? Colors.white : context.textColor,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          tab('Custom', !showPresets, () => onChanged(false)),
          tab('Presets', showPresets, () => onChanged(true)),
        ],
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.red, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.subtleTextColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          _SmallRoundButton(icon: Icons.remove_rounded, onPressed: onMinus),
          const SizedBox(width: 10),
          _SmallRoundButton(icon: Icons.add_rounded, onPressed: onPlus),
        ],
      ),
    );
  }
}

class _SmallRoundButton extends StatelessWidget {
  const _SmallRoundButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: context.mutedColor.withValues(alpha: context.isDark ? 1 : 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color:
                enabled
                    ? context.textColor
                    : context.textColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
