import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/archery_models.dart';
import '../models/session.dart';
import 'stats_screen.dart';

class PlayScreen extends StatefulWidget {
  final ArcheryRound round;
  final String bowType;

  const PlayScreen({super.key, required this.round, required this.bowType});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  static const int emptyCell = -1; // ← changed: sentinel for "no input yet"
  late List<List<int>> scores;
  int currentEnd = 0;
  int currentArrow = 0;

  @override
  void initState() {
    super.initState();
    scores = List.generate(
      widget.round.ends,
      (_) => List.filled(widget.round.arrowsPerEnd, emptyCell), // ← changed
    );
  }

  void _inputScore(int value) {
    final lastEnd = widget.round.ends - 1;
    final lastArrow = widget.round.arrowsPerEnd - 1;

    // guard: if we’re truly at the last slot and it already has a value, stop
    if (currentEnd == lastEnd && currentArrow == lastArrow && scores[currentEnd][currentArrow] != emptyCell) {
      return;
    }

    setState(() {
      scores[currentEnd][currentArrow] = value;
      if (currentArrow < lastArrow) {
        currentArrow++;
      } else if (currentEnd < lastEnd) {
        currentEnd++;
        currentArrow = 0;
      }
    });
  }

  int get totalScore {
    // Treat empty as 0; cap X(11) at 10 for totals/progress display
    return scores
        .expand((e) => e)
        .where((s) => s != emptyCell)
        .map((s) => s.clamp(0, 10)) // ← changed: X counts as 10 visually
        .fold(0, (a, b) => a + b);
  }

  bool get allFilled => scores.every((e) => e.every((s) => s != emptyCell)); // ← changed

  double get progressValue {
    final maxPoints = (widget.round.ends * widget.round.arrowsPerEnd * 10).toDouble();
    return (maxPoints == 0)
        ? 0
        : (totalScore / maxPoints).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.round.name, // minor clean-up
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              widget.bowType,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.greenAccent[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(
                            value: progressValue, // ← changed
                            strokeWidth: 8,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalScore',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'pts',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End ${currentEnd + 1} of ${widget.round.ends}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Arrow ${currentArrow + 1} of ${widget.round.arrowsPerEnd}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: ((currentEnd + (currentArrow / widget.round.arrowsPerEnd)) / widget.round.ends)
                                .clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _scoreGridCard()),
                    const SizedBox(height: 12),
                    _styledKeypad(),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: allFilled // ← changed: enable only when every cell has input
                          ? () async {
                              // Build stats safely using empties-as-zero and X=10 for averages/hits
                              final flat = scores.expand((e) => e).toList();
                              final effective = flat.map((s) => s == emptyCell ? 0 : s.clamp(0, 10)).toList();
                              final total = effective.fold(0, (a, b) => a + b);
                              final arrows = effective.length;
                              final int avg = arrows > 0 ? (total / arrows).round() : 0;
                              final hits = effective.where((s) => s > 0).length;

                              // Keep your original allScores structure if StatsScreen expects it
                              final allScores = [
                                scores
                                    .map((endScores) => endScores
                                        .map((s) => s == emptyCell ? 0 : s.clamp(0, 10)) // ← changed
                                        .toList())
                                    .toList()
                              ];

                              final user = FirebaseAuth.instance.currentUser;

                              final session = Session(
                                id: '',
                                date: DateTime.now(),
                                scores: effective, // ← changed: store flattened effective scores
                                remarks: '',
                                sessionType: widget.round.name,
                                bowType: widget.bowType,
                                distance: widget.round.distances.first,
                                roundId: widget.round.id,
                                userId: user?.uid,
                              );

                              await FirebaseFirestore.instance.collection('sessions').add(session.toMap());

                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StatsScreen(
                                    round: widget.round,
                                    totalScore: total,
                                    average: avg,
                                    hits: hits,
                                    allScores: allScores,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Finish & Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styledKeypad() {
    final bool isFinished = allFilled; // ← changed

    List<dynamic> scoreOptions;
    if (widget.round.scoringType == '10-zone') {
      scoreOptions = ['X', 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    } else if (widget.round.scoringType == 'field') {
      scoreOptions = [5, 4, 3, 2, 1, 0];
    } else if (widget.round.scoringType == '3D') {
      scoreOptions = [10, 8, 5, 0];
    } else {
      scoreOptions = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    }
    if (widget.bowType == 'Compound' && widget.round.scoringType == '10-zone') {
      scoreOptions = ['X', 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    }

    Color getButtonColor(dynamic score) {
      if (score == 'X') return Colors.yellow;
      if (score == 10 || score == 9) return Colors.yellow;
      if (score == 8 || score == 7) return Colors.red;
      if (score == 6 || score == 5) return Colors.blue;
      if (score == 4 || score == 3) return Colors.black;
      if (score == 2 || score == 1) return Colors.white;
      if (score == 0) return Colors.green;
      return Colors.white;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFinished ? Colors.grey[100] : Colors.greenAccent[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Score Keypad', style: TextStyle(fontWeight: FontWeight.w600)),
              if (isFinished)
                const Text('Session Complete', style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 1.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: scoreOptions.map((score) {
              final label = score == 0 ? 'M' : score.toString();
              final bg = getButtonColor(score);
              final textColor = (score == 4 || score == 3) ? Colors.white : Colors.black;

              return ElevatedButton(
                onPressed: isFinished
                    ? null
                    : () {
                        final intValue = (score == 'X') ? 11 : (score as int);
                        _inputScore(intValue);
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(6),
                  elevation: 2,
                  backgroundColor: bg,
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    if (score != 0)
                      Text('pts', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _scoreGridCard() {
    Color bgFor(int s) {
      if (s == 10 || s == 9) return Colors.yellow;
      if (s == 8 || s == 7) return Colors.red;
      if (s == 6 || s == 5) return Colors.blue;
      if (s == 4 || s == 3) return Colors.black;
      if (s == 2 || s == 1) return Colors.white;
      if (s == 0) return Colors.green;
      return Colors.white;
    }

    Color fgFor(Color bg) => bg.computeLuminance() < 0.5 ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.greenAccent[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))
        ],
      ),
      child: ListView.builder(
        itemCount: widget.round.ends,
        itemBuilder: (context, endIdx) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: Text('End ${endIdx + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        widget.round.arrowsPerEnd,
                        (arrowIdx) {
                          final raw = scores[endIdx][arrowIdx];

                          final bool hasValue = raw != emptyCell; // ← changed
                          final int numeric = hasValue ? (raw == 11 ? 10 : raw) : 0; // ← changed
                          final Color bg = hasValue ? bgFor(numeric) : (Colors.grey[100]!); // ← changed
                          final Color fg = fgFor(bg);
                          final String label = hasValue
                              ? (raw == 11 ? 'X' : (numeric == 0 ? 'M' : numeric.toString()))
                              : '-'; // ← changed

                          final bool isActive = (endIdx == currentEnd && arrowIdx == currentArrow);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bg,
                                    border: Border.all(
                                      color: isActive ? Colors.blue : (bg == Colors.white ? Colors.grey.shade300 : Colors.transparent),
                                      width: isActive ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
                                ),
                                const SizedBox(height: 6),
                                Text('${arrowIdx + 1}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
