import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedBow = 'Recurve';
  String? selectedRound = 'WA Indoor 18m';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Choose your Bow Type:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedBow,
              onChanged: (String? newValue) {
                setState(() {
                  selectedBow = newValue;
                });
              },
              items: <String>['Recurve', 'Compound', 'Barebow']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Choose your Round Type:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedRound,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRound = newValue;
                });
              },
              items: <String>['WA Indoor 18m', 'WA Outdoor 70m']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to HomeScreen after onboarding
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
