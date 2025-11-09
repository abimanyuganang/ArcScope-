import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';  // Imported for subtle animations
import '../models/archery_models.dart';
import '../models/session.dart';
import '../data/session_repository.dart';
import 'play_screen.dart';

class SessionSetupScreen extends StatefulWidget {
  final Session? session;
  const SessionSetupScreen({super.key, this.session});

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  late DateTime _dateTime;
  String _locationType = 'Indoor';
  String _locationText = '';
  late double _distance;
  late String _targetType;
  late String _bowType;
  int _ends = 6;
  int _arrowsPerEnd = 6;
  late String _notes;

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      _dateTime = widget.session!.date;
      _distance = widget.session!.distance ?? 18;
      _targetType = widget.session!.sessionType ?? 'FITA';
      _bowType = widget.session!.bowType ?? 'Recurve';
      _notes = widget.session!.remarks ?? '';
    } else {
      _dateTime = DateTime.now();
      _distance = 18;
      _targetType = 'FITA';
      _bowType = 'Recurve';
      _notes = '';
    }
  }

  final List<String> _locationTypes = ['Indoor', 'Outdoor', 'Club', 'Other'];
  final List<double> _distances = [18.0, 30.0, 50.0];
  final List<String> _targetTypes = ['FITA', 'Field', '3D'];
  final List<String> _bowTypes = ['Recurve', 'Compound', 'Barebow', 'Traditional'];

  bool get _detailsValid =>
      _dateTime != null &&
      _distance > 0 &&
      _targetType.isNotEmpty &&
      _bowType.isNotEmpty &&
      _ends > 0 &&
      _arrowsPerEnd > 0;

  void _updateArrowsPerEnd(String targetType) {
    setState(() {
      _targetType = targetType;
      if (targetType == 'FITA') {
        _arrowsPerEnd = 6;
      } else if (targetType == 'Field') {
        _arrowsPerEnd = 3;
      } else if (targetType == '3D') {
        _arrowsPerEnd = 1;
      }
    });
  }

  ArcheryRound get selectedRound => ArcheryRound(
    id: 'custom',
    name: 'Custom Session',
    discipline: ArcheryDiscipline.outdoor,
    distances: [_distance],
    totalArrows: _ends * _arrowsPerEnd,
    targetSize: _targetType == 'FITA' ? 122 : 40,
    ends: _ends,
    arrowsPerEnd: _arrowsPerEnd,
    scoringType: _targetType == 'FITA'
        ? '10-zone'
        : _targetType == 'Field'
            ? 'field'
            : '3D',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.session != null ? 'Edit Session' : 'Session Setup', style: const TextStyle(color: Color(0xFF4C763B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB0CE88), const Color(0xFFFFFD8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: _buildDetailsForm(context),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFF4C763B),
                    foregroundColor: Colors.white,
                    elevation: 4,
                  ),
                  onPressed: widget.session != null
                      ? () async {
                          final updatedSession = Session(
                            id: widget.session!.id,
                            date: _dateTime,
                            scores: widget.session!.scores,
                            remarks: _notes,
                            sessionType: _targetType,
                            bowType: _bowType,
                            distance: _distance,
                            roundId: widget.session!.roundId,
                          );
                          await SessionRepository().updateSession(updatedSession);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      : _detailsValid
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayScreen(round: selectedRound, bowType: _bowType),
                                ),
                              );
                            }
                          : null,
                  child: Text(widget.session != null ? 'Save Changes' : 'Start Scoring'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: const Color(0xFF4C763B), fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card for Date & Time
        Card(
          elevation: 4,  // Subtle shadow for depth
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.green),
              title: const Text('Date & Time*', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              subtitle: Text('${_dateTime.month}/${_dateTime.day}/${_dateTime.year}, ${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: const Color(0xFFB0CE88)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dateTime),
                    );
                    setState(() {
                      _dateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time?.hour ?? _dateTime.hour,
                        time?.minute ?? _dateTime.minute,
                      );
                    });
                  }
                },
              ),
            ),
          ),
        ),
        
        // Card for Location Settings
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Location Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _locationType,
                        items: _locationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.black)))).toList(),
                        onChanged: (v) => setState(() => _locationType = v ?? 'Indoor'),
                        decoration: const InputDecoration(
                          labelText: 'Location Type',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Location (e.g., Local Range)',
                    prefixIcon: Icon(Icons.map, color: Colors.green),
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                  ),
                  onChanged: (v) => setState(() => _locationText = v),
                ),
              ],
            ),
          ),
        ),
        
        // Card for Shooting Details
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shooting Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: _distance,
                        items: _distances.map((d) => DropdownMenuItem(value: d, child: Text('${d.toInt()}m', style: const TextStyle(color: Colors.black)))).toList(),
                        onChanged: (v) => setState(() => _distance = v ?? 18),
                        decoration: const InputDecoration(
                          labelText: 'Distance*',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.adjust, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _targetType,
                        items: _targetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.black)))).toList(),
                        onChanged: (v) => _updateArrowsPerEnd(v ?? 'FITA'),
                        decoration: const InputDecoration(
                          labelText: 'Target Type*',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.architecture, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _bowType,
                        items: _bowTypes.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(color: Colors.black)))).toList(),
                        onChanged: (v) => setState(() => _bowType = v ?? 'Recurve'),
                        decoration: const InputDecoration(
                          labelText: 'Bow Type*',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Card for Additional Settings
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Additional Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.confirmation_num_outlined, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _ends.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Number of Ends',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _ends = int.tryParse(v) ?? 6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes (e.g., Windy conditions, 10mph)',
                    prefixIcon: Icon(Icons.note, color: Colors.green),
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                  ),
                  maxLines: 2,
                  onChanged: (v) => setState(() => _notes = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
