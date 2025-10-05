import 'package:flutter/material.dart';
import '../models/archery_models.dart';

class SingleModeScreen extends StatelessWidget {
  final ArcheryRound round;
  const SingleModeScreen({required this.round, super.key});

  @override
  Widget build(BuildContext context) {
    Widget targetWidget;
    switch (round.scoringType) {
      case "10-zone":
        targetWidget = _buildFitaTarget();
        break;
      case "field":
        targetWidget = _buildFieldTarget();
        break;
      case "3D":
        targetWidget = _build3DTarget();
        break;
      default:
        targetWidget = const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(title: Text(round.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Distance(s): ${round.distances.join(', ')}m',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            targetWidget,
            const SizedBox(height: 16),
            // Add scoring controls here
            ElevatedButton(
              onPressed: () {
                // TODO: Save score and advance end
              },
              child: const Text('Log Arrow'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitaTarget() {
    // Placeholder for a radial target (SVG/circles recommended for real UI)
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.yellow,
            Colors.red,
            Colors.blue,
            Colors.black,
            Colors.white,
          ],
          stops: [0.2, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
      child: Center(child: Text('FITA', style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildFieldTarget() {
    // Placeholder for a field target
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green[700],
      ),
      child: Center(child: Text('Field', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _build3DTarget() {
    // Placeholder for a 3D animal target
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.brown[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text('3D', style: TextStyle(color: Colors.white))),
    );
  }
}
