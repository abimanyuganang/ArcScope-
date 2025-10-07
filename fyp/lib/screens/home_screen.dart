import 'package:flutter/material.dart';
import '../data/session_repository.dart';
import '../models/session.dart';
import 'session_setup_screen.dart';
import 'session_detail_screen.dart'; 

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
      // AppBar section
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.architecture, color: Colors.black), // Icon similar to ARCHERZONE logo
            SizedBox(width: 8),
            Text(
              'ArcScope',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.group, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Show More",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Challenge Card
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1506744038136-46273834b3fb'), // Replace with your image
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.darken),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // End In badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[600]?.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "End In 25 Days",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Srikandi Challenge Masters",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "20,352 participants",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Statistics Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Statistics",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Show More",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Score Distribution Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Score Distribution",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<String>(
                        value: "WA 1440",
                        items: <String>['WA 1440', 'Other Value']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {},
                        underline: SizedBox(),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Tabs for 1D, 1W, 1M, 1Y
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTimeTab(label: '1D', isSelected: false),
                      SizedBox(width: 8),
                      CustomTimeTab(label: '1W', isSelected: true),
                      SizedBox(width: 8),
                      CustomTimeTab(label: '1M', isSelected: false),
                      SizedBox(width: 8),
                      CustomTimeTab(label: '1Y', isSelected: false),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Sample Score Distribution placeholder graph
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        "Score Distribution Graph Here",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // X-axis labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                        11,
                        (index) => Text(
                              '${10 - index}',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                            )),
                  ),

                  SizedBox(height: 8),

                  // Bottom labels N/A placeholders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                        11,
                        (_) => Text(
                              'N/A',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                            )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Sessions Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Sessions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Show More",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Sessions List
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

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home - Active
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 16),

            // Other icons
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.build_outlined, color: Colors.grey),
              tooltip: "Tools",
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.group_outlined, color: Colors.grey),
              tooltip: "Community",
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz, color: Colors.grey),
              tooltip: "More",
            ),
          ],
        ),
      ),

      // Floating Target Button
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blue[800],
      child: const Icon(Icons.track_changes),
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
    );
  }

  Widget _sessionCard(Session session) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.track_changes, color: Colors.blue[800]),
        title: Text(
          session.sessionType ?? "Session",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

// Widget for Time tab with selection highlighting
class CustomTimeTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CustomTimeTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[800] : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.blue[800]! : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}