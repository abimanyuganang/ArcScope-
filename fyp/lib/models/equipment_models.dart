import 'package:cloud_firestore/cloud_firestore.dart';

class ArcherProfile {
  final String id;
  final String name;
  final String clubName;
  final String gender;
  final String ageGroup;
  final String userId;

  ArcherProfile({
    required this.id,
    required this.name,
    required this.clubName,
    required this.gender,
    required this.ageGroup,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'clubName': clubName,
    'gender': gender,
    'ageGroup': ageGroup,
    'userId': userId,
  };

  factory ArcherProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArcherProfile(
      id: doc.id,
      name: data['name'] ?? '',
      clubName: data['clubName'] ?? '',
      gender: data['gender'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class Bow {
  final String id;
  final String type;
  final String name;
  final String description;
  final String sightSetting;
  final String userId;

  Bow({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.sightSetting,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'name': name,
    'description': description,
    'sightSetting': sightSetting,
    'userId': userId,
  };

  factory Bow.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bow(
      id: doc.id,
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      sightSetting: data['sightSetting'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class Arrow {
  final String id;
  final String name;
  final double length;
  final double spine;
  final double weight;
  final String material;
  final String nock;
  final double diameter;
  final String description;
  final String userId;

  Arrow({
    required this.id,
    required this.name,
    required this.length,
    required this.spine,
    required this.weight,
    required this.material,
    required this.nock,
    required this.diameter,
    required this.description,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'length': length,
    'spine': spine,
    'weight': weight,
    'material': material,
    'nock': nock,
    'diameter': diameter,
    'description': description,
    'userId': userId,
  };

  factory Arrow.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Arrow(
      id: doc.id,
      name: data['name'] ?? '',
      length: (data['length'] ?? 0).toDouble(),
      spine: (data['spine'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      material: data['material'] ?? '',
      nock: data['nock'] ?? '',
      diameter: (data['diameter'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class Location {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String userId;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'userId': userId,
  };

  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      name: data['name'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      userId: data['userId'] ?? '',
    );
  }
}