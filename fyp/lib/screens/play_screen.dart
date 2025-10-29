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
  late List<List<int>> scores;
  int currentEnd = 0;
  int currentArrow = 0;

  @override
  void initState() {
    super.initState();
    scores = List.generate(
      widget.round.ends,
      (_) => List.filled(widget.round.arrowsPerEnd, 0),
    );
  }

  void _inputScore(int value) {
    setState(() {
      scores[currentEnd][currentArrow] = value;
      if (currentArrow < widget.round.arrowsPerEnd - 1) {
        currentArrow++;
      } else if (currentEnd < widget.round.ends - 1) {
        currentEnd++;
        currentArrow = 0;
      }
    });
  }

  int get totalScore =>
      scores.expand((endScores) => endScores).fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              '${widget.round.name}',
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
                  color: Colors.white,
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
                            value: (totalScore / (widget.round.ends * widget.round.arrowsPerEnd * 10)).clamp(0, 1).toDouble(),
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
                            value: ((currentEnd + (currentArrow / widget.round.arrowsPerEnd)) / widget.round.ends).clamp(0.0, 1.0),
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
                      onPressed: (currentEnd == widget.round.ends - 1 &&
                              currentArrow == widget.round.arrowsPerEnd - 1)
                          ? () async {
                              final allScores = [
                                scores.map((endScores) => endScores.map((s) => s as int?).toList()).toList()
                              ];
                              final total = scores.expand((e) => e).fold(0, (a, b) => a + b);
                              final arrows = scores.expand((e) => e).length;
                              final int avg = arrows > 0 ? (total / arrows).round() : 0;
                              final hits = scores.expand((e) => e).where((s) => s > 0).length;
                              final user = FirebaseAuth.instance.currentUser;

                              final session = Session(
                                id: '',
                                date: DateTime.now(),
                                scores: scores.expand((e) => e).toList(),
                                remarks: '',
                                sessionType: widget.round.name,
                                bowType: widget.bowType,
                                distance: widget.round.distances.first,
                                roundId: widget.round.id,
                                userId: user?.uid,
                              );

                              await FirebaseFirestore.instance.collection('sessions').add(session.toMap());

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
  List<dynamic> scoreOptions;
  if (widget.round.scoringType == '10-zone') {
    scoreOptions = ['X', 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,]; // Add 'X' for 10-zone
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

  // Function to determine the background color based on score
  Color getButtonColor(score) {
    if (score == 'X') {
      return Colors.yellow;
    } else if (score == 10 || score == 9) {
      return Colors.yellow;
    } else if (score == 8 || score == 7) {
      return Colors.red;
    } else if (score == 6 || score == 5) {
      return Colors.blue;
    } else if (score == 4 || score == 3) {
      return Colors.black;
    } else if (score == 2 || score == 1) {
      return Colors.white;
    } else if (score == 0) {
      return Colors.green;
    }
    return Colors.white; // Default case
  }
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Score Keypad', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: scoreOptions.map((score) {
              final label = score == 0 ? 'M' : score.toString();
              Color buttonColor = getButtonColor(score);
              Color textColor = (score == 4 || score == 3) ? Colors.white : Colors.black;
              return ElevatedButton(
                onPressed: () {
                  final intValue = (score == 'X') ? 10 : (score as int);
                  _inputScore(intValue); // Call the function with the correctly typed value
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(6),
                  elevation: 2,
                  backgroundColor: getButtonColor(score), // Set the color dynamically
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor, 
                      ),
                    ),
                    if (score != 0)
                      Text('pts', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}


  Widget _scoreGridCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
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
                          final val = scores[endIdx][arrowIdx];
                          final isActive = endIdx == currentEnd && arrowIdx == currentArrow;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isActive ? Colors.blue.shade50 : Colors.grey[100],
                                  child: Text(
                                    val == 0 ? '-' : val.toString(),
                                    style: TextStyle(fontWeight: FontWeight.w700, color: isActive ? Colors.blue : Colors.black87),
                                  ),
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
