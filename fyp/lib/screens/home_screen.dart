import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/session_repository.dart';
import '../models/session.dart';
import 'session_setup_screen.dart';
import 'session_detail_screen.dart';
import 'login_screen.dart';
import 'timer_screen.dart';
import 'equipment_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Session>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = SessionRepository().getAllSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar section with gradient background
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[100],
        elevation: 0,
        title: Row(
          children: [
            Icon(FontAwesomeIcons.bullseye, color: Color(0xFF043915)), // Archery-inspired icon
            SizedBox(width: 8),
            Text(
              'ArcScope',
              style: TextStyle(
                color: Color(0xFF043915),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [

          IconButton(
             onPressed: () async {
               await FirebaseAuth.instance.signOut();
               Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
             },
             icon: Icon(Icons.logout, color: Color(0xFF043915)),
             tooltip: 'Logout',
           ),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            // Feature Challenge Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Feature Challenge",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB0CE88),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Show More",
                    style: TextStyle(color: Color(0xFFB0CE88), fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Challenge Card with gradient and modern design
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1506744038136-46273834b3fb'), 
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "End In 25 Days",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Srikandi Challenge Masters",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "20,352 participants",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Sessions Section: Custom time tabs & clean design
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your Sessions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () {},
                  child: Text("Show More", style: TextStyle(color: Color(0xFFB0CE88), fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 12),
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No sessions found."));
                }
                final sessions = snapshot.data!;
                sessions.sort((a, b) => b.date.compareTo(a.date));
                return Column(
                  children: sessions.map((session) => _sessionCard(session)).toList(),
                );
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),

      // Bottom Navigation Bar with highlighted active state
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home - Active
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4C763B),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            // Other icons
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimerScreen()),
                );
              },
              icon: Icon(Icons.timer_outlined, color: Colors.grey)
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EquipmentScreen()),
                );
              },
              icon: Icon(Icons.arrow_right_alt, color: Colors.grey)
            ),
          ],
        ),
      ),

      // Floating Action Button (FAB) with gradient effect
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFB0CE88), Colors.blue[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12, spreadRadius: 2, offset: Offset(0, 6)),
            BoxShadow(color: Colors.white24, blurRadius: 6, offset: Offset(-2, -2)),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: Colors.white, size: 32),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SessionSetupScreen()),
            ).then((_) {
              setState(() {
                _sessionsFuture = SessionRepository().getAllSessions();
              });
            });
          },
        ),
      ),
    );
  }

  // Session Card with modern design and better styling
  Widget _sessionCard(Session session) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.track_changes, color: Color(0xFFB0CE88)),
        title: Text(session.sessionType ?? "Session", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${session.date.toLocal().toString().split(' ')[0]} • Score: ${session.totalScore} • Arrows: ${session.arrowsShot}",
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionDetailScreen(sessionId: session.id),
            ),
          );
          if (result == 'deleted') {
            setState(() {
              _sessionsFuture = SessionRepository().getAllSessions();
            });
          }
        },
      ),
    );
  }
}