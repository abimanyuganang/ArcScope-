import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/session_repository.dart';
import '../models/session.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late Future<Session> _sessionFuture;
  late Future<List<Session>> _allSessionsFuture;

  @override
  void initState() {
    super.initState();
    final repo = SessionRepository();
    _allSessionsFuture = repo.getAllSessions();
    _sessionFuture = _allSessionsFuture.then((sessions) => sessions.firstWhere((e) => e.id == widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session>(
      future: _sessionFuture,
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Session Detail')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (sessionSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Session Detail')),
            body: Center(child: Text('Error: ${sessionSnapshot.error}')),
          );
        }

        if (!sessionSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Session Detail')),
            body: const Center(child: Text('Session not found')),
          );
        }

        final s = sessionSnapshot.data!;

        return FutureBuilder<List<Session>>(
          future: _allSessionsFuture,
          builder: (context, allSnapshot) {
            if (!allSnapshot.hasData) {
              return Scaffold(
                appBar: AppBar(title: const Text('Session Detail')),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final all = allSnapshot.data!;
            final idx = all.indexWhere((e) => e.id == s.id);
            final prev = (idx + 1 < all.length) ? all[idx + 1] : null;
            final improvement = prev == null ? null : (s.average - prev.average);

            final dist = s.valueDistribution;
            final barSpots = dist.entries.map((e) => BarChartGroupData(
              x: int.tryParse(e.key) ?? (e.key == 'X' ? 11 : -1),
              barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.deepPurple)],
            )).toList();

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFFB0CE88), // Gradient can be applied here
                elevation: 4,
                title: const Text('Session Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Session',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Session'),
                          content: const Text('Are you sure you want to delete this session?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await SessionRepository().deleteSession(s.id);
                        if (context.mounted) {
                          Navigator.of(context).pop('deleted');
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.ios_share, color: Colors.white),
                    onPressed: () async {
                      final rows = <List<dynamic>>[
                        ['Date', s.date.toIso8601String()],
                        ['Total', s.totalScore],
                        ['Average', s.average],
                        ['Arrows', s.arrowsShot],
                        ['Type', s.sessionType ?? ''],
                        ['Bow', s.bowType ?? ''],
                        ['Distance', s.distance?.toString() ?? ''],
                        [],
                        ['Scores'],
                        ...s.scores.map((v) => [v == 11 ? 'X' : v == -1 ? 'M' : v]),
                      ];
                      final csv = const ListToCsvConverter().convert(rows);
                      final xfile = XFile.fromData(
                        Uint8List.fromList(csv.codeUnits),
                        mimeType: 'text/csv',
                        name: 'session_${s.date.toIso8601String().substring(0,10)}.csv',
                      );
                      await Share.shareXFiles([xfile], text: 'Archery session export');
                    },
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('${s.date.toLocal()}'.split(' ').first, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8,runSpacing: 15, children: [
                    _tag('Total: ${s.totalScore}'),
                    _tag('Avg: ${s.average.toStringAsFixed(2)}'),
                    if (s.sessionType != null) _tag('Type: ${s.sessionType}'),
                    if (s.bowType != null) _tag('Bow: ${s.bowType}'),
                    if (s.distance != null) _tag('${s.distance}m'),
                  ]),
                  const SizedBox(height: 12),
                  if (improvement != null)
                    Text('Improvement vs previous: ${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  const Text('Distribution'),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        barGroups: barSpots,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true, 
                            getTitlesWidget: (value, meta) {
                              final label = value == 11 ? 'X' : value == -1 ? 'M' : value.toInt().toString();
                              return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
                            }
                          )),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black26, width: 1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (s.remarks != null && s.remarks!.isNotEmpty) ...[
                    const Text('Remarks', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(s.remarks!),
                  ],
                  const SizedBox(height: 24),
                  const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ...s.insights.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $i', style: const TextStyle(color: Color(0xFF4C763B))),
                  )),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _tag(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4C763B),
        ),
      ),
    );
  }
}
