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
    final result = <String>[];
    final trend = scoreTrendPerEnd;
    if (trend.isNotEmpty && trend.first < trend.last) {
      result.add("Improving trend — keep it up!");
    } else if (trend.isNotEmpty && trend.first > trend.last) {
      result.add("Declining last session → fatigue → reduce volume or rest after 3 ends.");
    }
    if (meanRadialError > 5) {
      result.add("Cluster shifted left → check tiller/release weight/finger pressure.");
    }
    if (trend.isNotEmpty && trend.take(3).average < 5) {
      result.add("Early ends too low (elevation) — check anchor/sight.");
    }
    return result;
  }
}

extension ListAverage on Iterable<double> {
  double get average => isEmpty ? 0 : reduce((a, b) => a + b) / length;
}
