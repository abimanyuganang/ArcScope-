import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_models.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  // Archer Profile fields
  String _archerName = '';
  String _clubName = '';
  String _gender = 'Male';
  String _ageGroup = 'Senior';

  // Bow fields
  String _bowType = 'Recurve';
  String _bowName = '';
  String _bowDescription = '';
  String _sightSetting = 'Metric';

  // Arrow fields
  String _arrowName = '';
  double _arrowLength = 0;
  double _arrowSpine = 0;
  double _arrowWeight = 0;
  String _arrowMaterial = '';
  String _arrowNock = '';
  double _arrowDiameter = 0;
  String _arrowDescription = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (user == null) return;

    // Load archer profile
    final archerDoc = await FirebaseFirestore.instance
        .collection('archers')
        .where('userId', isEqualTo: user!.uid)
        .get();

    if (archerDoc.docs.isNotEmpty) {
      final archer = ArcherProfile.fromFirestore(archerDoc.docs.first);
      setState(() {
        _archerName = archer.name;
        _clubName = archer.clubName;
        _gender = archer.gender;
        _ageGroup = archer.ageGroup;
      });
    }

    // Load bow
    final bowDoc = await FirebaseFirestore.instance
        .collection('bows')
        .where('userId', isEqualTo: user!.uid)
        .get();

    if (bowDoc.docs.isNotEmpty) {
      final bow = Bow.fromFirestore(bowDoc.docs.first);
      setState(() {
        _bowType = bow.type;
        _bowName = bow.name;
        _bowDescription = bow.description;
        _sightSetting = bow.sightSetting;
      });
    }

    // Load arrow
    final arrowDoc = await FirebaseFirestore.instance
        .collection('arrows')
        .where('userId', isEqualTo: user!.uid)
        .get();

    if (arrowDoc.docs.isNotEmpty) {
      final arrow = Arrow.fromFirestore(arrowDoc.docs.first);
      setState(() {
        _arrowName = arrow.name;
        _arrowLength = arrow.length;
        _arrowSpine = arrow.spine;
        _arrowWeight = arrow.weight;
        _arrowMaterial = arrow.material;
        _arrowNock = arrow.nock;
        _arrowDiameter = arrow.diameter;
        _arrowDescription = arrow.description;
      });
    }

  }

  Future<void> _saveArcherProfile() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('archers').add({
      'name': _archerName,
      'clubName': _clubName,
      'gender': _gender,
      'ageGroup': _ageGroup,
      'userId': user!.uid,
    });
  }

  Future<void> _saveBow() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('bows').add({
      'type': _bowType,
      'name': _bowName,
      'description': _bowDescription,
      'sightSetting': _sightSetting,
      'userId': user!.uid,
    });
  }

  Future<void> _saveArrow() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('arrows').add({
      'name': _arrowName,
      'length': _arrowLength,
      'spine': _arrowSpine,
      'weight': _arrowWeight,
      'material': _arrowMaterial,
      'nock': _arrowNock,
      'diameter': _arrowDiameter,
      'description': _arrowDescription,
      'userId': user!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Setup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Archer'),
            Tab(text: 'Bow'),
            Tab(text: 'Arrow'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArcherForm(),
          _buildBowForm(),
          _buildArrowForm(),
        ],
      ),
    );
  }

  Widget _buildArcherForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Archer Name*'),
              initialValue: _archerName,
              onChanged: (value) => _archerName = value,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Club Name'),
              initialValue: _clubName,
              onChanged: (value) => _clubName = value,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender'),
              value: _gender,
              items: ['Male', 'Female', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value!),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Age Group'),
              value: _ageGroup,
              items: ['U13', 'U15', 'U18', 'U21', 'Senior', 'Master']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _ageGroup = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await _saveArcherProfile();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Archer profile saved')),
                    );
                  }
                }
              },
              child: const Text('Save Archer Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Bow Type*'),
              value: _bowType,
              items: ['Recurve', 'Compound', 'Longbow', 'Barebow', 'Instinctive']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _bowType = value!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Bow Name*'),
              initialValue: _bowName,
              onChanged: (value) => _bowName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              initialValue: _bowDescription,
              onChanged: (value) => _bowDescription = value,
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Sight Setting'),
              value: _sightSetting,
              items: ['Metric', 'Imperial']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _sightSetting = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _saveBow();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bow saved')),
                  );
                }
              },
              child: const Text('Save Bow'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Arrow Name*'),
              initialValue: _arrowName,
              onChanged: (value) => _arrowName = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Length (inches)'),
              initialValue: _arrowLength.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => _arrowLength = double.tryParse(value) ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Spine'),
              initialValue: _arrowSpine.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => _arrowSpine = double.tryParse(value) ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Weight (grains)'),
              initialValue: _arrowWeight.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => _arrowWeight = double.tryParse(value) ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Material'),
              initialValue: _arrowMaterial,
              onChanged: (value) => _arrowMaterial = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nock Type'),
              initialValue: _arrowNock,
              onChanged: (value) => _arrowNock = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Diameter (mm)'),
              initialValue: _arrowDiameter.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => _arrowDiameter = double.tryParse(value) ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              initialValue: _arrowDescription,
              onChanged: (value) => _arrowDescription = value,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _saveArrow();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arrow saved')),
                  );
                }
              },
              child: const Text('Save Arrow'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
