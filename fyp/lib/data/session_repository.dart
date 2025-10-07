import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';

class SessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Get a reference to the collection
  CollectionReference get _sessionsCollection => _firestore.collection('sessions');

  // Create a new session
  Future<Session> create({
    required DateTime date,
    required List<int> scores,
    String? remarks,
    String? sessionType,
    String? bowType,
    double? distance,
    String? roundId,
  }) async {
    final session = Session(
      id: _uuid.v4(),
      date: date,
      scores: scores,
      remarks: remarks,
      sessionType: sessionType,
      bowType: bowType,
      distance: distance,
      roundId: roundId,
    );

    // Add the session to Firestore
    await _sessionsCollection.doc(session.id).set(session.toMap());

    return session;
  }

  // Fetch all sessions
  Future<List<Session>> getAllSessions() async {
    final snapshot = await _sessionsCollection.get();
    return snapshot.docs
        .map((doc) => Session.fromFirestore(doc))
        .toList();
  }

  // Fetch filtered sessions (by date range or session type)
  Future<List<Session>> filter({
    DateTime? from,
    DateTime? to,
    String? sessionType,
  }) async {
    Query query = _sessionsCollection;

    // Apply filters based on provided parameters
    if (from != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }

    if (to != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }

    if (sessionType != null) {
      query = query.where('sessionType', isEqualTo: sessionType);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Session.fromFirestore(doc))
        .toList();
  }

  // Update a session
  Future<void> updateSession(Session session) async {
    await _sessionsCollection.doc(session.id).update(session.toMap());
  }

  // Delete a session by ID
  Future<void> deleteSession(String id) async {
    await FirebaseFirestore.instance.collection('sessions').doc(id).delete();
  }
}
