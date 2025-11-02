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
            appBar: AppBar(
              title: const Text('Session Detail'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB0CE88), Color(0xFF8FBF6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (sessionSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Session Detail'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB0CE88), Color(0xFF8FBF6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(child: Text('Error: ${sessionSnapshot.error}')),
            ),
          );
        }

        if (!sessionSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Session Detail'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB0CE88), Color(0xFF8FBF6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(child: Text('Session not found')),
            ),
          );
        }

        final s = sessionSnapshot.data!;

        return FutureBuilder<List<Session>>(
          future: _allSessionsFuture,
          builder: (context, allSnapshot) {
            if (!allSnapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Session Detail'),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB0CE88), Color(0xFF8FBF6B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F5F5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final all = allSnapshot.data!;
            final idx = all.indexWhere((e) => e.id == s.id);
            final prev = (idx + 1 < all.length) ? all[idx + 1] : null;
            final improvement = prev == null ? null : (s.average - prev.average);

            return Scaffold(
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB0CE88), Color(0xFF8FBF6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
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
                    icon: const Icon(Icons.ios_share),
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
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFF5F5F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s.date.toLocal()}'.split(' ').first, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4C763B))),
                            const SizedBox(height: 6),
                            Wrap(spacing: 8, runSpacing: 15, children: [
                              _tag('Total: ${s.totalScore}'),
                              _tag('Avg: ${s.average.toStringAsFixed(2)}'),
                              if (s.sessionType != null) _tag('Type: ${s.sessionType}'),
                              if (s.bowType != null) _tag('Bow: ${s.bowType}'),
                              if (s.distance != null) _tag('${s.distance}m'),
                            ]),
                            const SizedBox(height: 12),
                            if (improvement != null)
                              Text('Improvement vs previous: ${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4C763B))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Score Distribution', 
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                fontSize: 16, 
                                color: Color(0xFF4C763B)
                              )
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: Stack(
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sections: _buildPieSections(s),
                                      centerSpaceRadius: 60,
                                      sectionsSpace: 2,
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${s.arrowsShot}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4C763B),
                                          ),
                                        ),
                                        const Text(
                                          'Total Arrows',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _buildLegendItems(s),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (s.remarks != null && s.remarks!.isNotEmpty) ...[
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Remarks', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4C763B))),
                              const SizedBox(height: 4),
                              Text(s.remarks!),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4C763B))),
                            ...s.insights.map((i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('• $i', style: const TextStyle(color: Color(0xFF4C763B))),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
        color: const Color(0xFFB0CE88).withOpacity(0.2),
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4C763B),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Session s) {
  final dist = s.valueDistribution;
  
  // Different colors for different score ranges
  Color getScoreColor(String score) {
    final value = int.tryParse(score) ?? (score == 'X' ? 11 : -1);
    if (value == 11) return Colors.yellow[700]!;
    if (value >= 9) return Colors.yellow[600]!;
    if (value >= 7) return Colors.red[400]!;
    if (value >= 5) return Colors.blue[400]!;
    if (value >= 3) return Colors.black87;
    if (value >= 1) return Colors.grey[400]!;
    return Colors.green[300]!; // Miss
  }

  return dist.entries.map((e) {
    final value = e.value;
    final score = e.key;
    
    return PieChartSectionData(
      value: value.toDouble(),
      radius: 100,
      title: score,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      color: getScoreColor(e.key),
    );
  }).toList();
}
}

List<Widget> _buildLegendItems(Session s) {
  return s.valueDistribution.entries.map((e) {
    final count = e.value;
    final label = e.key == '-1' ? 'M' : e.key;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFB0CE88).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C763B),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }).toList();
}