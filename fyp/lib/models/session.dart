import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  String id;
  DateTime date;
  int arrowsShot;
  List<int> scores;
  String? remarks;
  String? sessionType;
  String? bowType;
  double? distance;
  String? roundId;
  String? userId;
  int? ends;
  int? arrowsPerEnd;
  

  Session({
    required this.id,
    required this.date,
    required this.scores,
    this.remarks,
    this.sessionType,
    this.bowType,
    this.distance,
    this.roundId,
    this.userId,
    this.ends,
    this.arrowsPerEnd,
  }) : arrowsShot = scores.length;

  int get totalScore => scores.fold<int>(0, (s, v) {
        if (v == 11) return s + 10;
        if (v == -1) return s;
        return s + v;
      });

  double get average => scores.isEmpty ? 0 : totalScore / scores.length;

  int get best => scores.where((v) => v >= 0).map((v) => v == 11 ? 10 : v).fold<int>(0, (p, c) => c > p ? c : p);

  // Convert a Session to a Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'scores': scores,
      'remarks': remarks,
      'sessionType': sessionType,
      'bowType': bowType,
      'distance': distance,
      'roundId': roundId,
      'userId': userId,
      'ends': ends,
      'arrowsPerEnd': arrowsPerEnd,
    };
  }

  // Convert Firestore document to Session
  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Session(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      scores: List<int>.from(data['scores']),
      remarks: data['remarks'],
      sessionType: data['sessionType'],
      bowType: data['bowType'],
      distance: data['distance'],
      roundId: data['roundId'],
      userId: data['userId'],
      ends: data['ends'],
      arrowsPerEnd: data['arrowsPerEnd'],
    );
  }
}

extension SessionAnalytics on Session {
  // Mean Radial Error (MRE) - example: average distance from center (simulate with scores)
  double get meanRadialError {
    // Simulate: lower score = higher error, X/10 = 0, 9 = 1, ..., M = max
    if (scores.isEmpty) return 0;
    return scores.map((v) => v == 11 || v == 10 ? 0 : v == -1 ? 10 : 10 - v).reduce((a, b) => a + b) / scores.length;
  }

  // CEP-50/CEP-95: percentage of arrows within 50%/95% of max score
  double get cep50 {
    if (scores.isEmpty) return 0;
    final threshold = 10 * 0.5;
    final count = scores.where((v) => v >= threshold).length;
    return count / scores.length * 100;
  }

  double get cep95 {
    if (scores.isEmpty) return 0;
    final threshold = 10 * 0.95;
    final count = scores.where((v) => v >= threshold).length;
    return count / scores.length * 100;
  }

  // Windage/Elevation trend per end (simulate: average score trend)
  List<double> get scoreTrendPerEnd {
    // Example: group scores by ends of 6 arrows
    final ends = <List<int>>[];
    for (var i = 0; i < scores.length; i += 6) {
      ends.add(scores.sublist(i, (i + 6).clamp(0, scores.length)));
    }
    return ends.map((end) => end.isEmpty ? 0.0 : end.reduce((a, b) => a + b) / end.length).toList();
  }

  // Value distribution for bar chart
  Map<String, int> get valueDistribution {
    final dist = <String, int>{};
    for (var v in scores) {
      final label = v == 11 ? 'X' : v == -1 ? 'M' : '$v';
      dist[label] = (dist[label] ?? 0) + 1;
    }
    return dist;
  }
}

extension SessionInsights on Session {
  List<String> get insights {
    if (scores.isEmpty) return [];
    final insights = <String>[];

    // Determine scoring type from sessionType
    final isField = sessionType?.toLowerCase() == 'field';
    final is3D = sessionType?.toLowerCase() == '3d';
    
    if (isField) {
      // Field archery insights (5-1 scoring)
      final fives = scores.where((s) => s == 5).length;
      final fivePercent = (fives / scores.length * 100).toStringAsFixed(1);
      insights.add('You hit $fives 5s ($fivePercent%)');

      final lowScores = scores.where((s) => s <= 2).length;
      if (lowScores > 0) {
        insights.add('$lowScores arrows scored 2 or less');
      }

    } else if (is3D) {
      // 3D archery insights (10,8,5,0 scoring)
      final tens = scores.where((s) => s == 10).length;
      if (tens > 0) {
        final tenPercent = (tens / scores.length * 100).toStringAsFixed(1);
        insights.add('You hit $tens 10s ($tenPercent%)');
      }

      final kills = scores.where((s) => s >= 8).length;
      final killPercent = (kills / scores.length * 100).toStringAsFixed(1);
      insights.add('Kill zone hits: $kills ($killPercent%)');

      final misses = scores.where((s) => s == 0).length;
      if (misses > 0) {
        insights.add('$misses complete misses');
      }

    } else {
      // FITA/Default 10-zone scoring
      final tens = scores.where((s) => s >= 10).length;
      if (tens > 0) {
        final tenPercent = (tens / scores.length * 100).toStringAsFixed(1);
        insights.add('You hit $tens 10s ($tenPercent%)');
      }

      final nines = scores.where((s) => s == 9).length;
      if (nines > 0) {
        insights.add('$nines arrows in the 9 ring');
      }

      final gold = scores.where((s) => s >= 9).length;
      final goldPercent = (gold / scores.length * 100).toStringAsFixed(1);
      insights.add('Gold zone hits: $gold ($goldPercent%)');

      final lowScores = scores.where((s) => s <= 6).length;
      if (lowScores > 0) {
        insights.add('$lowScores arrows scored 6 or less');
      }
    }

    // Common insights for all types
    final double avg = this.average;
    insights.add('Average per arrow: ${avg.toStringAsFixed(2)}');

    if (scores.length >= 2) {
      final last3 = scores.reversed.take(3).toList();
      final last3Avg = last3.map((e) => e.toDouble()).average;
      if (last3Avg > avg) {
        insights.add('Strong finish! Last 3 arrows above average');
      }
    }

    return insights;
  }
}

extension ListAverage on Iterable<num> {
  double get average => isEmpty ? 0.0 : map((e) => e.toDouble()).reduce((a, b) => a + b) / length;
}
