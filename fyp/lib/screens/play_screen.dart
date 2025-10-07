import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/archery_models.dart';
import '../models/session.dart';
import 'stats_screen.dart'; 

class PlayScreen extends StatefulWidget {
  final ArcheryRound round;
  final String bowType; // Pass bow type from setup

  const PlayScreen({super.key, required this.round, required this.bowType});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late List<List<int>> scores; // scores[end][arrow]
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.round.name} - ${widget.bowType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'End ${currentEnd + 1} / ${widget.round.ends}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Arrow ${currentArrow + 1} / ${widget.round.arrowsPerEnd}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _scoreKeypad(),
            const SizedBox(height: 16),
            Expanded(child: _scoreGrid()),
            const SizedBox(height: 16),
            Text(
              'Total Score: $totalScore',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (currentEnd == widget.round.ends - 1 &&
                      currentArrow == widget.round.arrowsPerEnd - 1)
                  ? () async {
                      // Prepare stats data
                      final allScores = [
                        scores.map((endScores) => endScores.map((s) => s as int?).toList()).toList()
                      ]; // shape: List<List<List<int?>>>
                      final total = scores.expand((e) => e).fold(0, (a, b) => a + b);
                      final arrows = scores.expand((e) => e).length;
                      final int avg = arrows > 0 ? (total / arrows).round() : 0;
                      final hits = scores.expand((e) => e).where((s) => s > 0).length;
                      final user = FirebaseAuth.instance.currentUser;

                      // Save session to Firestore
                      final session = Session(
                        id: '', // Firestore will generate the ID
                        date: DateTime.now(),
                        scores: scores.expand((e) => e).toList(), // Flatten your 2D scores list
                        remarks: '', // Add remarks if you have
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
              child: const Text('Finish & Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreKeypad() {
    // Scoring logic can be adjusted based on bow type if needed
    List<int> scoreOptions;
    if (widget.round.scoringType == '10-zone') {
      scoreOptions = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    } else if (widget.round.scoringType == 'field') {
      scoreOptions = [5, 4, 3, 2, 1, 0];
    } else if (widget.round.scoringType == '3D') {
      scoreOptions = [10, 8, 5, 0];
    } else {
      scoreOptions = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    }

    // Example: Compound bow may use only inner 10 as X (advanced logic can be added)
    if (widget.bowType == 'Compound' && widget.round.scoringType == '10-zone') {
      scoreOptions = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]; // You can add 'X' logic here
    }

    return Wrap(
      spacing: 8,
      children: scoreOptions
          .map((score) => ElevatedButton(
                onPressed: () => _inputScore(score),
                child: Text(score == 0 ? 'M' : score.toString()),
              ))
          .toList(),
    );
  }

  Widget _scoreGrid() {
    return ListView.builder(
      itemCount: widget.round.ends,
      itemBuilder: (context, endIdx) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text('End ${endIdx + 1}'),
            subtitle: Row(
              children: List.generate(
                widget.round.arrowsPerEnd,
                (arrowIdx) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: endIdx == currentEnd && arrowIdx == currentArrow
                        ? Colors.blue[100]
                        : Colors.grey[200],
                    child: Text(
                      scores[endIdx][arrowIdx] == 0 ? '-' : scores[endIdx][arrowIdx].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
