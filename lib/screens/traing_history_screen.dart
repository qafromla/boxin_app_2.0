import 'package:flutter/material.dart';
import 'package:boxing_app/models/training_session.dart';
import 'package:boxing_app/widgets/training_storage.dart';
import 'package:intl/intl.dart';

class TrainingHistoryScreen extends StatefulWidget {
  @override
  _TrainingHistoryScreenState createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  List<TrainingSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final sessions = await TrainingStorage.getSessions();
    setState(() {
      _sessions = sessions.reversed.toList(); // show latest first
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Training History')),
      body:
          _sessions.isEmpty
              ? Center(child: Text('No training sessions yet.'))
              : ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return Dismissible(
                    key: Key(session.date.toIso8601String()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('Delete  Session'),
                              content: Text(
                                'Are you sure you want to delete this session?',
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (_) async {
                      await TrainingStorage.deleteSessionAt(index);
                      setState(() {
                        _sessions.removeAt(index);
                      });
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          DateFormat(
                            'MMM dd, yyyy – HH:mm',
                          ).format(session.date),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Rounds: ${session.completedRounds} of ${session.setupRounds} | Round: ${_formatDuration(session.roundLength)} | Rest: ${_formatDuration(session.restTime)}\n'
                          'Total Time: ${_formatDuration(session.totalTrainingTime)}',
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
