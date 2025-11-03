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

  // === Logic preserved ===
  List<Widget> _buildEndAverages(List<List<List<int?>>> allScores) {
    final averages = <Widget>[];
    if (allScores.isNotEmpty) {
      final ends = allScores.first;
      for (int i = 0; i < ends.length; i++) {
        final endScores = ends[i].whereType<int>().toList();
        final avg = endScores.isEmpty
            ? 0.0
            : endScores.reduce((a, b) => a + b) / endScores.length;
        averages.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.show_chart, size: 20, color: Colors.green),
                ),
                const SizedBox(width: 12),
                const Text(
                  'End',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  ' ${i + 1}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  avg.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      }
    }
    return averages;
  }

  Widget _buildDispersionPattern(List<List<List<int?>>> allScores) {
    if (allScores.isEmpty) return const Center(child: Text('No data'));
    final ends = allScores.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(ends.length, (endIdx) {
        final end = ends[endIdx];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  'End ${endIdx + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                )),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(end.length, (arrowIdx) {
                    final score = end[arrowIdx] ?? 0;

                    Color fill;
                    if (score >= 9) {
                      fill = Colors.amber.shade600;
                    } else if (score >= 7) {
                      fill = Colors.red.shade400;
                    } else if (score >= 5) {
                      fill = Colors.blue.shade400;
                    } else if (score >= 3) {
                      fill = Colors.black87;
                    } else {
                      fill = Colors.white;
                    }

                    final textColor =
                        score >= 5 ? Colors.black : Colors.grey.shade700;

                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: fill,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        score > 0 ? '$score' : '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
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
  // === End preserved logic ===

  @override
  Widget build(BuildContext context) {
    final dist = _scoreDistribution(allScores);

    // Create a green-accented feel without changing the app-wide theme.
    final primary = Colors.greenAccent;
    final primaryDark = Colors.green.shade700;
    final container = Colors.greenAccent.withOpacity(.15);
    final outline = Colors.green.shade200;

    final sortedEntries = dist.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final maxCount =
        sortedEntries.isEmpty ? 1 : sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Statistics'),
        elevation: 1,
        backgroundColor: primary,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Back to Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Round Summary
          Card(
            elevation: 0,
            color: container,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.architecture_rounded, color: Colors.white),
                    ),
                    title: Text(
                      round.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('Round', style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatPill(
                        label: 'Total',
                        value: '$totalScore',
                        icon: Icons.stacked_bar_chart_outlined,
                        primary: primary,
                        outline: outline,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Average',
                        value: average.toDouble().toStringAsFixed(2),
                        icon: Icons.equalizer_outlined,
                        primary: primary,
                        outline: outline,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Hits',
                        value: '$hits',
                        icon: Icons.sports_score_outlined,
                        primary: primary,
                        outline: outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Score Distribution
          _SectionCard(
            title: 'Score Distribution',
            accent: primary,
            outline: outline,
            trailing: Icon(Icons.bar_chart_rounded, color: primaryDark),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: sortedEntries.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: Text('No scores yet')),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: sortedEntries.map((e) {
                        final ratio = e.value / maxCount;
                        final height = (ratio * 120).clamp(8, 120).toDouble();
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                width: 20,
                                height: height,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(.5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: outline, width: .8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${e.value}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${e.key}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Average per End
          _SectionCard(
            title: 'Average Arrow Score Per End',
            accent: primary,
            outline: outline,
            trailing: Icon(Icons.trending_up_rounded, color: primaryDark),
            child: Column(children: _buildEndAverages(allScores)),
          ),

          const SizedBox(height: 16),

          // Dispersion Pattern
          _SectionCard(
            title: 'Dispersion Pattern',
            accent: primary,
            outline: outline,
            trailing: Icon(Icons.blur_circular_rounded, color: primaryDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _LegendDot(color: Colors.amber, label: '9-10'),
                    _LegendDot(color: Colors.red, label: '7-8'),
                    _LegendDot(color: Colors.blue, label: '5-6'),
                    _LegendDot(color: Colors.black87, label: '3-4'),
                    _LegendDot(color: Colors.white, border: true, label: '0-2'),
                  ],
                ),
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

// =====================
// Small UI helpers
// =====================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final Color accent;
  final Color outline;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.accent,
    required this.outline,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: accent.withOpacity(.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color primary;
  final Color outline;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.primary,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: primary.withOpacity(.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outline, width: .8),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primary.withOpacity(.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: Colors.green.shade800),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool border;

  const _LegendDot({
    required this.color,
    required this.label,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border ? Border.all(color: Colors.grey.shade400, width: 1) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}
