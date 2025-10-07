import 'package:flutter/material.dart';
import '../data/session_repository.dart';
import '../models/session.dart';
import '../models/archery_models.dart';
import 'session_detail_screen.dart'; 
import 'play_screen.dart'; 

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final _repo = SessionRepository();
  String _sort = 'date_desc';
  DateTime? _from, _to;
  String? _sessionType;

  // Async method to fetch and sort sessions
  Future<List<Session>> _query() async {
    final list = await _repo.filter(from: _from, to: _to, sessionType: _sessionType);
    switch (_sort) {
      case 'date_asc': 
        list.sort((a, b) => a.date.compareTo(b.date)); 
        break;
      case 'avg_desc': 
        list.sort((a, b) => b.average.compareTo(a.average)); 
        break;
      case 'total_desc': 
        list.sort((a, b) => b.totalScore.compareTo(a.totalScore)); 
        break;
      default: 
        list.sort((a, b) => b.date.compareTo(a.date));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'date_desc', child: Text('Sort: Date ↓')),
              PopupMenuItem(value: 'date_asc', child: Text('Sort: Date ↑')),
              PopupMenuItem(value: 'avg_desc', child: Text('Sort: Average ↓')),
              PopupMenuItem(value: 'total_desc', child: Text('Sort: Total ↓')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Session>>(
        future: _query(),  // Use _query() to get sessions
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sessions found.'));
          }

          final items = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    TextButton(
                      child: Text(_from == null ? 'From' : _from!.toLocal().toString().split(' ').first),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context, 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime(2100), 
                          initialDate: DateTime.now()
                        );
                        if (d != null) setState(() => _from = d);
                      },
                    ),
                    const Text('—'),
                    TextButton(
                      child: Text(_to == null ? 'To' : _to!.toLocal().toString().split(' ').first),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context, 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime(2100), 
                          initialDate: DateTime.now()
                        );
                        if (d != null) setState(() => _to = d);
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      hint: const Text('Type'),
                      value: _sessionType,
                      items: const ['Practice', 'Round']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _sessionType = v),
                    ),
                    const Spacer(),
                    if (_from != null || _to != null || _sessionType != null)
                      IconButton(onPressed: () => setState(() {_from = null; _to = null; _sessionType = null;}), icon: const Icon(Icons.clear)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = items[i];
                    return ListTile(
                      title: Text('${s.date.toLocal()}'.split(' ').first),
                      subtitle: Text('Total: ${s.totalScore}   Avg: ${s.average.toStringAsFixed(2)}   Shots: ${s.arrowsShot}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to SessionDetailScreen when implemented
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: s.id)),
                         );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final saved = await Navigator.push(context, MaterialPageRoute(builder: (_) => PlayScreen(round: roundsData.first, bowType: 'Recurve')));
          if (saved == true && mounted) setState(() {});
        },
      ),
    );
  }
}
