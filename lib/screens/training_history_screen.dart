import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/training_session.dart';
import '../services/training_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  List<TrainingSession>? _sessions; // null = still loading
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await TrainingStorage.getSessions();
    sessions.sort((a, b) => b.date.compareTo(a.date)); // newest first
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _expandedId = sessions.isEmpty ? null : sessions.first.id;
    });
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete session?'),
            content: const Text('This workout will be removed from history.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  Future<void> _delete(TrainingSession session) async {
    // Delete by id — always the session the user swiped.
    setState(() => _sessions!.removeWhere((s) => s.id == session.id));
    await TrainingStorage.deleteSession(session.id);
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;
    return Scaffold(
      appBar: AppBar(title: const Text('Training History')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child:
                sessions == null
                    ? const Center(child: CircularProgressIndicator())
                    : sessions.isEmpty
                    ? const _EmptyHistory()
                    : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _StatsHeader(sessions: sessions),
                        const SizedBox(height: 14),
                        for (final s in sessions) ...[
                          Dismissible(
                            key: ValueKey(s.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(),
                            onDismissed: (_) => _delete(s),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            child: _SessionCard(
                              session: s,
                              expanded: _expandedId == s.id,
                              onTap:
                                  () => setState(
                                    () =>
                                        _expandedId =
                                            _expandedId == s.id ? null : s.id,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          'Swipe left to delete a session',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.subtleTextColor),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_mma_rounded, size: 72, color: AppColors.red),
            const SizedBox(height: 16),
            const Text(
              'No workouts yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Finish your first workout and it will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.subtleTextColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// This week · total rounds · day streak.
class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final stats = HistoryStats.from(sessions, DateTime.now());
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          _Stat(
            value: '${stats.thisWeek}',
            label: 'This week',
            icon: Icons.calendar_today_rounded,
          ),
          _Stat(
            value: '${stats.totalRounds}',
            label: 'Total rounds',
            icon: Icons.layers_outlined,
          ),
          _Stat(
            value: '${stats.streak}',
            label: 'Day streak',
            icon: Icons.local_fire_department_rounded,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.red, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: context.subtleTextColor),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.expanded,
    required this.onTap,
  });

  final TrainingSession session;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM dd, yyyy – HH:mm').format(session.date);
    return AppCard(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.red,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!expanded)
                  Text(
                    '${session.completedRounds}/${session.setupRounds}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          session.isFullyCompleted
                              ? AppColors.green
                              : context.subtleTextColor,
                    ),
                  ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: context.subtleTextColor,
                  ),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _Detail(
                    icon: Icons.layers_outlined,
                    value:
                        '${session.completedRounds} of ${session.setupRounds}',
                    label: 'Rounds',
                  ),
                  _Detail(
                    icon: Icons.timer_outlined,
                    value: formatTime(session.roundLength),
                    label: 'Round',
                  ),
                  _Detail(
                    icon: Icons.coffee_outlined,
                    value: formatTime(session.restTime),
                    label: 'Rest',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: context.mutedColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Total Time: ${formatTime(session.totalTrainingTime)}'
                  '${session.isFullyCompleted ? '  ✅' : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.red, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.subtleTextColor),
          ),
        ],
      ),
    );
  }
}

/// Numbers for the history header. Kept separate so it can be tested.
class HistoryStats {
  final int thisWeek;
  final int totalRounds;
  final int streak;

  const HistoryStats(this.thisWeek, this.totalRounds, this.streak);

  factory HistoryStats.from(List<TrainingSession> sessions, DateTime now) {
    DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
    final today = day(now);
    final weekStart = DateTime(today.year, today.month, today.day - (today.weekday - 1));

    final thisWeek = sessions.where((s) => !s.date.isBefore(weekStart)).length;
    final totalRounds = sessions.fold<int>(
      0,
      (sum, s) => sum + s.completedRounds,
    );

    // Days in a row with at least one workout, ending today (or yesterday,
    // so the streak doesn't look broken before today's workout).
    final days = sessions.map((s) => day(s.date)).toSet();
    var cursor =
        days.contains(today)
            ? today
            : DateTime(today.year, today.month, today.day - 1);
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return HistoryStats(thisWeek, totalRounds, streak);
  }
}
