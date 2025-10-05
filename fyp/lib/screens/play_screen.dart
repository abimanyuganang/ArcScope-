import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/archery_models.dart';
import '../widgets/score_keypad.dart';
import 'stats_screen.dart';
import '../data/session_repository.dart'; // Add this import

class PlayScreen extends StatefulWidget {
  final ArcheryRound round;
  final GearPreset? bow;
  final GearPreset? arrow;

  const PlayScreen({super.key, required this.round, this.bow, this.arrow});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late List<List<List<int?>>> scores;
  int distIndex = 0;
  int endIndex = 0;
  final _repo = SessionRepository(); // Firestore Repository

  @override
  void initState() {
    super.initState();
    scores = List.generate(
      widget.round.distances.length,
      (_) => List.generate(
        widget.round.ends,
        (_) => List.filled(widget.round.arrowsPerEnd, null),
      ),
    );
  }

  int get totalScore {
    int sum = 0;
    for (final d in scores) {
      for (final e in d) {
        for (final a in e) {
          if (a == null) continue;
          if (a == 11) sum += 10;
          else if (a == -1) sum += 0;
          else sum += a;
        }
      }
    }
    return sum;
  }

  double get average {
    int count = 0, sum = 0;
    for (final d in scores) {
      for (final e in d) {
        for (final a in e) {
          if (a == null) continue;
          count++;
          sum += (a == 11 ? 10 : a);
        }
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  int get hits {
    int h = 0;
    for (final d in scores) {
      for (final e in d) {
        for (final a in e) {
          if (a != null && a != -1) h++;
        }
      }
    }
    return h;
  }

  void _inputScore(int value) {
    final arr = scores[distIndex][endIndex];
    final i = arr.indexWhere((e) => e == null);
    if (i == -1) return;
    setState(() => arr[i] = value);
  }

  void _deleteLast() {
    final arr = scores[distIndex][endIndex];
    final i = arr.lastIndexWhere((e) => e != null);
    if (i == -1) return;
    setState(() => arr[i] = null);
  }

  void _nextEnd() {
    setState(() {
      if (endIndex < widget.round.ends - 1) {
        endIndex++;
      } else if (distIndex < widget.round.distances.length - 1) {
        distIndex++;
        endIndex = 0;
      }
    });
  }

  Future<void> _saveSession() async {
    final session = await _repo.create(
      date: DateTime.now(),
      scores: scores.expand((e) => e).whereType<int>().toList(),
      remarks: 'Session completed with ${hits} hits',
      sessionType: 'Practice',
      bowType: widget.bow?.title,
      distance: widget.round.distances[distIndex],
      roundId: widget.round.id,
    );

    // Optionally show a success message after saving
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session saved with total score: ${session.totalScore}')));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final title = r.name;
    final sub = 'Mode: Standar, Single, ${r.outdoor ? "Outdoor" : "Indoor"}';
    final phase = 'ROUND ${distIndex + 1} (END ${endIndex + 1}) - ${r.distances[distIndex]}m';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('${totalScore}/${r.maxScore}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: [
            _chip('End: ${r.ends}'),
            _chip('/ ${r.totalArrows}'),
            ...r.distances.map((d) => _chip('${d}m')),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() {
                if (endIndex > 0) endIndex--;
              })),
              Expanded(child: Center(child: Text(phase, style: const TextStyle(fontWeight: FontWeight.w600)))),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextEnd),
            ],
          ),
          const SizedBox(height: 12),
          _ScoreGrid(ends: scores[distIndex], arrowsPerEnd: r.arrowsPerEnd),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('TOTAL = $totalScore    AVG = ${average.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScoreKeypad(onTap: _inputScore, onDelete: _deleteLast),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  _saveSession();  // Save the session data to Firestore
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatsScreen(
                        round: r,
                        totalScore: totalScore,
                        average: average,
                        hits: hits,
                        allScores: scores,
                      ),
                    ),
                  );
                },
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Text(t),
      );
}

class _ScoreGrid extends StatelessWidget {
  final List<List<int?>> ends; // [end][arrow]
  final int arrowsPerEnd;
  const _ScoreGrid({required this.ends, required this.arrowsPerEnd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int e = 0; e < ends.length; e++) ...[
            Row(
              children: [
                SizedBox(width: 56, child: Text('END${e + 1}', style: const TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 6),
                Expanded(
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [for (int a = 0; a < arrowsPerEnd; a++) _scoreCircle(ends[e][a])],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }

  Widget _scoreCircle(int? value) {
    String label = '•';
    if (value != null) {
      if (value == 11) label = 'X';
      else if (value == -1) label = 'M';
      else label = '$value';
    }
    return Container(
      width: 34, height: 34, alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
