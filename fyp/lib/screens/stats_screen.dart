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

  static const _labels = ['X','10','9','8','7','6','5','4','3','2','1','M'];

  @override
  Widget build(BuildContext context) {
    final buckets = _buildHistogram(allScores);
    final maxBucket = buckets.values.fold<int>(0, (p, c) => c > p ? c : p);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(round.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, children: [
            _tag('End: ${round.ends}'),
            _tag('/ ${round.totalArrows}'),
            ...round.distances.map((d) => _tag('${d}m')),
          ]),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      const labelSpace = 28.0;
                      final barMaxHeight = constraints.maxHeight - labelSpace;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final key in _labels)
                            _Bar(
                              label: key,
                              value: buckets[key] ?? 0,
                              max: maxBucket,
                              maxBarHeight: barMaxHeight,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _metric('$totalScore', 'Score'),
              _metric('$average', 'Average'),
              _metric('$hits/${round.totalArrows}', 'Hits'),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, int> _buildHistogram(List<List<List<int?>>> s) {
    final map = {for (final l in _labels) l: 0};
    for (final d in s) {
      for (final e in d) {
        for (final a in e) {
          if (a == null) continue;
          switch (a) {
            case 11: map['X'] = (map['X'] ?? 0) + 1; break;
            case -1: map['M'] = (map['M'] ?? 0) + 1; break;
            default: map['$a'] = (map['$a'] ?? 0) + 1;
          }
        }
      }
    }
    return map;
  }

  Widget _tag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: Text(t, style: const TextStyle(fontSize: 12)),
      );

  Widget _metric(String big, String label) => Column(
        children: [
          Text(big, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      );
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final double maxBarHeight;
  const _Bar({required this.label, required this.value, required this.max, required this.maxBarHeight});

  @override
  Widget build(BuildContext context) {
    final h = max == 0 ? 0.0 : (value / max) * maxBarHeight;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: h,
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 2),
          child: value > 0
              ? Text('$value',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))
              : null,
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}
