import 'package:flutter/material.dart';
import 'single_mode_screen.dart';
import '../models/archery_models.dart';

class SessionSetupScreen extends StatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
   int _step = 0;

   DateTime _dateTime = DateTime.now();
   String _locationType = 'Indoor';
   String _locationText = '';
   double _distance = 18;
   String _targetType = 'FITA';
   String _bowType = 'Recurve';
   int _ends = 6;
   String _notes = '';

   ArcheryRound get selectedRound => ArcheryRound(
         id: 'custom',
         name: 'Custom Session',
         discipline: _locationType == 'Indoor'
             ? ArcheryDiscipline.indoor
             : ArcheryDiscipline.outdoor,
         distances: [_distance],
         totalArrows: _ends * 3, // Assuming 3 arrows per end
         targetSize: 40,
         ends: _ends,
         arrowsPerEnd: 3,
         scoringType: _targetType == 'FITA'
             ? '10-zone'
             : _targetType.toLowerCase(),
       );

  final _locationTypes = ['Indoor', 'Outdoor', 'Club', 'Other'];
  final _distances = [18.0, 30.0, 50.0];
  final _targetTypes = ['FITA', 'Field', '3D'];
  final _bowTypes = ['Recurve', 'Compound', 'Traditional'];

  bool get _detailsValid =>
      _dateTime != null &&
      _distance > 0 &&
      _targetType.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Session Setup', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          /*image: DecorationImage(
            image: AssetImage('assets/archery_bg.png'), // Add a subtle target pattern image here
            fit: BoxFit.cover,
            opacity: 0.08,
          /),*/
          color: Color(0xFFF5F6FA),
        ),
        child: SafeArea(
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _step,
            controlsBuilder: (context, details) => const SizedBox.shrink(),
            steps: [
              Step(
                title: const Text('Details'),
                isActive: _step == 0,
                content: _buildDetailsForm(context),
              ),
              Step(
                title: const Text('Logging'),
                isActive: _step == 1,
                content: _buildLoggingForm(context),
              ),
            ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _detailsValid
                      ? () {
                          if (_step == 0) {
                            setState(() => _step = 1);
                          } else {
                            // TODO: Save session and navigate to logging screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SingleModeScreen(round: selectedRound),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text(_step == 0 ? 'Next: Start Logging' : 'Save & Start'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
        // Date & Time
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text('Date & Time*'),
          subtitle: Text('${_dateTime.month}/${_dateTime.day}/${_dateTime.year}, ${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
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
        const SizedBox(height: 16),

        // Location Type Dropdown
        Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _locationType,
                items: _locationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _locationType = v ?? 'Indoor'),
                decoration: const InputDecoration(labelText: 'Location Type'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Location Free Text
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Location (e.g., Local Range)',
            prefixIcon: Icon(Icons.map),
          ),
          onChanged: (v) => setState(() => _locationText = v),
        ),
        const SizedBox(height: 16),

        // Distance Slider
        Row(
          children: [
            const Icon(Icons.straighten),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<double>(
                value: _distance,
                items: _distances.map((d) => DropdownMenuItem(value: d, child: Text('${d.toInt()}m'))).toList(),
                onChanged: (v) => setState(() => _distance = v ?? 18),
                decoration: const InputDecoration(labelText: 'Distance*'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Target Type
        Row(
          children: [
            const Icon(Icons.adjust),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _targetType,
                items: _targetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _targetType = v ?? 'FITA'),
                decoration: const InputDecoration(labelText: 'Target Type*'),
              ),
            ),
            const SizedBox(width: 8),
            // Target preview (placeholder)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: const Icon(Icons.adjust, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bow Type
        Row(
          children: [
            const Icon(Icons.architecture),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _bowType,
                items: _bowTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _bowType = v ?? 'Recurve'),
                decoration: const InputDecoration(labelText: 'Bow Type'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Number of Ends
        Row(
          children: [
            const Icon(Icons.confirmation_num_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: _ends.toString(),
                decoration: const InputDecoration(labelText: 'Number of Ends'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _ends = int.tryParse(v) ?? 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Notes (e.g., Windy conditions, 10mph)',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 2,
          onChanged: (v) => setState(() => _notes = v),
        ),
      ],
    );
  }

  Widget _buildLoggingForm(BuildContext context) {
    // Placeholder for logging step
    return Center(
      child: Text(
        'Logging step goes here.',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}