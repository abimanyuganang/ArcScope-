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
  final user = FirebaseAuth.instance.currentUser;

  // Data fields
  List<ArcherProfile> _archerProfiles = [];
  List<Bow> _bows = [];
  List<Arrow> _arrows = [];

  // Form fields for adding data
  String _archerName = '';
  String _clubName = '';
  String _gender = 'Male';
  String _ageGroup = 'Senior';

  String _bowType = 'Recurve';
  String _bowName = '';
  String _bowDescription = '';
  String _sightSetting = 'Metric';

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

  // Load existing data from Firestore
  Future<void> _loadExistingData() async {
    if (user == null) return;

    // Load Archer Profiles
    final archerDocs = await FirebaseFirestore.instance
        .collection('archers')
        .where('userId', isEqualTo: user!.uid)
        .get();
    setState(() {
      _archerProfiles = archerDocs.docs.map((doc) => ArcherProfile.fromFirestore(doc)).toList();
    });

    // Load Bows
    final bowDocs = await FirebaseFirestore.instance
        .collection('bows')
        .where('userId', isEqualTo: user!.uid)
        .get();
    setState(() {
      _bows = bowDocs.docs.map((doc) => Bow.fromFirestore(doc)).toList();
    });

    // Load Arrows
    final arrowDocs = await FirebaseFirestore.instance
        .collection('arrows')
        .where('userId', isEqualTo: user!.uid)
        .get();
    setState(() {
      _arrows = arrowDocs.docs.map((doc) => Arrow.fromFirestore(doc)).toList();
    });
  }

  // Show "No data" message if no records found
  Widget _buildNoDataMessage(String label) {
    return Center(
      child: Text('There is no $label available.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // Add Archer Profile to Firestore
  Future<void> _addArcherProfile() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('archers').add({
      'name': _archerName,
      'clubName': _clubName,
      'gender': _gender,
      'ageGroup': _ageGroup,
      'userId': user!.uid,
    });

    // Clear form fields
    setState(() {
      _archerName = '';
      _clubName = '';
      _gender = 'Male';
      _ageGroup = 'Senior';
    });
    _loadExistingData(); // Reload the data after adding
    Navigator.of(context).pop(); // Close the dialog after adding
  }

  // Update Archer Profile in Firestore
  Future<void> _updateArcherProfile(String id) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('archers').doc(id).update({
      'name': _archerName,
      'clubName': _clubName,
      'gender': _gender,
      'ageGroup': _ageGroup,
    });

    // Clear form fields
    setState(() {
      _archerName = '';
      _clubName = '';
      _gender = 'Male';
      _ageGroup = 'Senior';
    });
    _loadExistingData(); // Reload the data after updating
    Navigator.of(context).pop(); // Close the dialog after updating
  }

  // Add Bow to Firestore
  Future<void> _addBow() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('bows').add({
      'type': _bowType,
      'name': _bowName,
      'description': _bowDescription,
      'sightSetting': _sightSetting,
      'userId': user!.uid,
    });

    // Clear form fields
    setState(() {
      _bowType = 'Recurve';
      _bowName = '';
      _bowDescription = '';
      _sightSetting = 'Metric';
    });
    _loadExistingData(); // Reload the data after adding
    Navigator.of(context).pop(); // Close the dialog after adding
  }

  // Update Bow in Firestore
  Future<void> _updateBow(String id) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('bows').doc(id).update({
      'type': _bowType,
      'name': _bowName,
      'description': _bowDescription,
      'sightSetting': _sightSetting,
    });

    // Clear form fields
    setState(() {
      _bowType = 'Recurve';
      _bowName = '';
      _bowDescription = '';
      _sightSetting = 'Metric';
    });
    _loadExistingData(); // Reload the data after updating
    Navigator.of(context).pop(); // Close the dialog after updating
  }

  // Add Arrow to Firestore
  Future<void> _addArrow() async {
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

    // Clear form fields
    setState(() {
      _arrowName = '';
      _arrowLength = 0;
      _arrowSpine = 0;
      _arrowWeight = 0;
      _arrowMaterial = '';
      _arrowNock = '';
      _arrowDiameter = 0;
      _arrowDescription = '';
    });
    _loadExistingData(); // Reload the data after adding
    Navigator.of(context).pop(); // Close the dialog after adding
  }

  // Update Arrow in Firestore
  Future<void> _updateArrow(String id) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('arrows').doc(id).update({
      'name': _arrowName,
      'length': _arrowLength,
      'spine': _arrowSpine,
      'weight': _arrowWeight,
      'material': _arrowMaterial,
      'nock': _arrowNock,
      'diameter': _arrowDiameter,
      'description': _arrowDescription,
    });

    // Clear form fields
    setState(() {
      _arrowName = '';
      _arrowLength = 0;
      _arrowSpine = 0;
      _arrowWeight = 0;
      _arrowMaterial = '';
      _arrowNock = '';
      _arrowDiameter = 0;
      _arrowDescription = '';
    });
    _loadExistingData(); // Reload the data after updating
    Navigator.of(context).pop(); // Close the dialog after updating
  }

  // Build Archer Profile Form
  Widget _buildArcherForm({bool isEdit = false, ArcherProfile? archer}) {
  return Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Archer Name*'),
        initialValue: isEdit && archer != null ? archer.name : '',
        onChanged: (value) => _archerName = value,
      ),
      const SizedBox(height: 10),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Club Name'),
        initialValue: isEdit && archer != null ? archer.clubName : '',
        onChanged: (value) => _clubName = value,
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Gender'),
        value: isEdit && archer != null ? archer.gender : _gender,
        items: ['Male', 'Female', 'Other']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => setState(() => _gender = value!),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Age Group'),
        value: isEdit && archer != null ? archer.ageGroup : _ageGroup,
        items: ['U13', 'U15', 'U18', 'U21', 'Senior', 'Master']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => setState(() => _ageGroup = value!),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: isEdit && archer != null 
            ? () => _updateArcherProfile(archer.id)
            : _addArcherProfile,
        child: Text(isEdit ? 'Update Archer Profile' : 'Save Archer Profile'),
      ),
    ],
  );
}

  // Build Bow Form
  Widget _buildBowForm({bool isEdit = false, Bow? bow}) {
  return Column(
    children: [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Bow Type*'),
        value: isEdit && bow != null ? bow.type : _bowType,
        items: ['Recurve', 'Compound', 'Longbow', 'Barebow', 'Instinctive']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => setState(() => _bowType = value!),
      ),
      const SizedBox(height: 10),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Bow Name*'),
        initialValue: isEdit && bow != null ? bow.name : '',
        onChanged: (value) => _bowName = value,
      ),
      const SizedBox(height: 10),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Description'),
        initialValue: isEdit && bow != null ? bow.description : '',
        onChanged: (value) => _bowDescription = value,
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Sight Setting'),
        value: isEdit && bow != null ? bow.sightSetting : _sightSetting,
        items: ['Metric', 'Imperial']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => setState(() => _sightSetting = value!),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: isEdit && bow != null ? () => _updateBow(bow.id) : _addBow,
        child: Text(isEdit ? 'Update Bow' : 'Save Bow'),
      ),
    ],
  );
}

  // Build Arrow Form
  Widget _buildArrowForm({bool isEdit = false, Arrow? arrow}) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Arrow Name*'),
          initialValue: isEdit && arrow != null ? arrow.name : '',
          onChanged: (value) => _arrowName = value,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Length (inches)'),
          initialValue: isEdit && arrow != null ? arrow.length.toString() : '0.0',
          keyboardType: TextInputType.number,
          onChanged: (value) => _arrowLength = double.tryParse(value) ?? 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Spine'),
          initialValue: isEdit && arrow != null ? arrow.spine.toString() : '0.0',
          keyboardType: TextInputType.number,
          onChanged: (value) => _arrowSpine = double.tryParse(value) ?? 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Weight (grains)'),
          initialValue: isEdit && arrow != null ? arrow.weight.toString() : '0.0',
          keyboardType: TextInputType.number,
          onChanged: (value) => _arrowWeight = double.tryParse(value) ?? 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Material'),
          initialValue: isEdit && arrow != null ? arrow.material : '',
          onChanged: (value) => _arrowMaterial = value,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nock Type'),
          initialValue: isEdit && arrow != null ? arrow.nock : '',
          onChanged: (value) => _arrowNock = value,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Diameter (mm)'),
          initialValue: isEdit && arrow != null ? arrow.diameter.toString() : '0.0',
          keyboardType: TextInputType.number,
          onChanged: (value) => _arrowDiameter = double.tryParse(value) ?? 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description'),
          initialValue: isEdit && arrow != null ? arrow.description : '',
          onChanged: (value) => _arrowDescription = value,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isEdit && arrow != null ? () => _updateArrow(arrow.id) : _addArrow,
          child: Text(isEdit ? 'Update Arrow' : 'Save Arrow'),
        ),
      ],
    );
  }

  // Build Archer Profile List
  Widget _buildArcherProfileList() {
  return Column(
    children: [
      Expanded(
        child: _archerProfiles.isEmpty
            ? _buildNoDataMessage('Archer Profile')
            : ListView.builder(
                itemCount: _archerProfiles.length,
                itemBuilder: (context, index) {
                  final archer = _archerProfiles[index];
                  return ListTile(
                    title: Text(archer.name),
                    subtitle: Text('${archer.clubName} - ${archer.ageGroup}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(
                            'Archer Profile',
                            _buildArcherForm(isEdit: true, archer: archer),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteArcherProfile(archer.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _showAddDialog('Archer Profile', _buildArcherForm()),
          child: const Text('Add Archer Profile'),
        ),
      ),
    ],
  );
}

  // Build Bow List
  Widget _buildBowList() {
  return Column(
    children: [
      Expanded(
        child: _bows.isEmpty
            ? _buildNoDataMessage('Bow')
            : ListView.builder(
                itemCount: _bows.length,
                itemBuilder: (context, index) {
                  final bow = _bows[index];
                  return ListTile(
                    title: Text(bow.name),
                    subtitle: Text('${bow.type} - ${bow.sightSetting}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(
                            'Bow',
                            _buildBowForm(isEdit: true, bow: bow),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteBow(bow.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _showAddDialog('Bow', _buildBowForm()),
          child: const Text('Add Bow'),
        ),
      ),
    ],
  );
}

  // Build Arrow List
  Widget _buildArrowList() {
    return Column(
      children: [
        Expanded(
          child: _arrows.isEmpty
              ? _buildNoDataMessage('Arrow')
              : ListView.builder(
                  itemCount: _arrows.length,
                  itemBuilder: (context, index) {
                    final arrow = _arrows[index];
                    return ListTile(
                      title: Text(arrow.name),
                      subtitle: Text('${arrow.length} inches - ${arrow.material}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog('Arrow', _buildArrowForm(isEdit: true, arrow: arrow)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteArrow(arrow.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _showAddDialog('Arrow', _buildArrowForm()),
            child: const Text('Add Arrow'),
          ),
        ),
      ],
    );
  }

  // Show dialog for adding new items
  void _showAddDialog(String title, Widget form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: SingleChildScrollView(child: form),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show dialog for editing items
  void _showEditDialog(String title, Widget form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: SingleChildScrollView(child: form),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete methods
  Future<void> _deleteArcherProfile(String id) async {
    await FirebaseFirestore.instance.collection('archers').doc(id).delete();
    _loadExistingData();
  }

  Future<void> _deleteBow(String id) async {
    await FirebaseFirestore.instance.collection('bows').doc(id).delete();
    _loadExistingData();
  }

  Future<void> _deleteArrow(String id) async {
    await FirebaseFirestore.instance.collection('arrows').doc(id).delete();
    _loadExistingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[100],
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
          _buildArcherProfileList(),
          _buildBowList(),
          _buildArrowList(),
        ],
      ),
    );
  }
}
