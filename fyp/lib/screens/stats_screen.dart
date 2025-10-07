import 'package:flutter/material.dart';
import '../models/archery_models.dart';

class StatsScreen extends StatelessWidget {
  final ArcheryRound round;
  final int totalScore;
  final int average;
  final int hits;
  final List<List<List<int?>>> allScores;

  const StatsScreen({
    super.key,
    required this.round,
    required this.totalScore,
    required this.average,
    required this.hits,
    required this.allScores,
  });

  List<Widget> _buildEndAverages(List<List<List<int?>>> allScores) {
    final averages = <Widget>[];
    if (allScores.isNotEmpty) {
      final ends = allScores.first;
      for (int i = 0; i < ends.length; i++) {
        final endScores = ends[i].whereType<int>().toList();
        final avg = endScores.isEmpty ? 0.0 : endScores.reduce((a, b) => a + b) / endScores.length;
        averages.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('End ${i + 1}: ${avg.toStringAsFixed(2)}'),
          ),
        );
      }
    }
    return averages;
  }

  Widget _buildDispersionPattern(List<List<List<int?>>> allScores) {
    if (allScores.isEmpty) return const Text('No data');
    final ends = allScores.first;
    return Column(
      children: List.generate(ends.length, (endIdx) {
        final end = ends[endIdx];
        return Row(
          children: List.generate(end.length, (arrowIdx) {
            final score = end[arrowIdx] ?? 0;
            Color color;
            if (score >= 9) {
              color = Colors.yellow[700]!;
            } else if (score >= 7) {
              color = Colors.red[400]!;
            } else if (score >= 5) {
              color = Colors.blue[400]!;
            } else if (score >= 3) {
              color = Colors.black;
            } else {
              color = Colors.white;
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  score > 0 ? '$score' : '',
                  style: TextStyle(
                    color: score >= 5 ? Colors.black : Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Map<int, int> _scoreDistribution(List<List<List<int?>>> allScores) {
    final dist = <int, int>{};
    if (allScores.isNotEmpty) {
      final ends = allScores.first;
      for (final end in ends) {
        for (final score in end) {
          if (score != null) {
            dist[score] = (dist[score] ?? 0) + 1;
          }
        }
      }
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final dist = _scoreDistribution(allScores);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Back to Home',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Round: ${round.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Total Score: $totalScore'),
                  Text('Average: ${average.toStringAsFixed(2)}'),
                  Text('Hits: $hits'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: () {
                    final sortedEntries = dist.entries.toList()
                      ..sort((a, b) => b.key.compareTo(a.key));
                    return sortedEntries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Text('${e.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                width: 18,
                                height: (e.value * 8).toDouble().clamp(8, 80),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              Text('${e.value}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        )).toList();
                  }(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Average Arrow Score Per End', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ..._buildEndAverages(allScores),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dispersion Pattern', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildDispersionPattern(allScores),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
