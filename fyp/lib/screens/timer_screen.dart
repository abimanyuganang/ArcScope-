import 'package:flutter/material.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _timeLeft = 120; // 2 minutes default
  bool _isRunning = false;
  int _walkTime = 10; // 10 seconds to walk to line
  int _shootTime = 120; // 2 minutes to shoot
  int _warningTime = 30; // 30 seconds warning
  String _currentStage = "Get Ready"; // Default stage is "Get Ready"

  // Variable to store the time left when paused
  int _pausedTime = 0;

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        // If we're starting from paused state, continue from the saved time
        if (_pausedTime == 0) {
          _timeLeft = _walkTime; // Start with walk time if not paused
          _currentStage = "Get Ready";
        } else {
          // Continue from where it was paused
          _timeLeft = _pausedTime;
        }
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() {
            _timeLeft--;
          });

          // Change stage when walk time ends
          if (_timeLeft == 0 && _currentStage == "Get Ready") {
            setState(() {
              _currentStage = "Shooting";
              _timeLeft = _shootTime; // Set time to shoot
            });
          }

          // Start warning when time is equal to warning time
          if (_timeLeft == _warningTime && _currentStage == "Shooting") {
            setState(() {
              _currentStage = "Warning";
            });
          }
        } else {
          _stopTimer();
          setState(() {
            _currentStage = "Stop"; // Show "Stop" when the time ends
          });
          // TODO: Add end of time sound
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _pausedTime = _timeLeft; // Save the current time when paused
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _timeLeft = _walkTime; // Reset time to walk time
      _currentStage = "Get Ready"; // Reset to "Get Ready"
      _pausedTime = 0; // Clear the paused time
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Walk to line time (seconds)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _walkTime = int.tryParse(value) ?? 10;
                });
              },
              controller: TextEditingController(text: _walkTime.toString()),
            ),
            SizedBox(height: 10,),
            TextField(
              decoration: const InputDecoration(labelText: 'Shooting time (seconds)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _shootTime = int.tryParse(value) ?? 120;
                });
              },
              controller: TextEditingController(text: _shootTime.toString()),
            ),
            SizedBox(height: 10,),
            TextField(
              decoration: const InputDecoration(labelText: 'Warning time (seconds)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _warningTime = int.tryParse(value) ?? 30;
                });
              },
              controller: TextEditingController(text: _warningTime.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background color based on the current stage
    Color backgroundColor;
    String stageText;

    switch (_currentStage) {
      case "Get Ready":
        backgroundColor = Colors.red;
        stageText = "Get Ready";
        break;
      case "Shooting":
        backgroundColor = Colors.green;
        stageText = "Shooting";
        break;
      case "Warning":
        backgroundColor = Colors.orange;
        stageText = "Warning";
        break;
      case "Stop":
        backgroundColor = Colors.red;
        stageText = "Stop";
        break;
      default:
        backgroundColor = Colors.transparent;
        stageText = "";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[100],
        title: const Text('Archery Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _startTimer,
        child: Container(
          color: backgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: _currentStage == "Warning" ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? _stopTimer : _startTimer,
                      child: Text(_isRunning ? 'Pause' : 'Start'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _resetTimer,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  stageText, // Display current stage
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap anywhere to start timer',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
