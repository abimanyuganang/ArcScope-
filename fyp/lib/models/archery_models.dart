enum ArcheryDiscipline { outdoor, indoor, field, threeD }

class GearPreset {
  final String title;
  const GearPreset(this.title);
}

class ArcheryRound {
  final String id;
  final String name;
  final ArcheryDiscipline discipline;
  final List<double> distances;
  final int totalArrows;
  final int targetSize;
  final int ends;
  final int arrowsPerEnd;
  final String scoringType;

  ArcheryRound({
    required this.id,
    required this.name,
    required this.discipline,
    required this.distances,
    required this.totalArrows,
    required this.targetSize,
    required this.ends,
    required this.arrowsPerEnd,
    required this.scoringType,
  });
}

// Example rounds
final List<ArcheryRound> roundsData = [
  ArcheryRound(
    id: 'wa1440',
    name: 'WA 1440',
    discipline: ArcheryDiscipline.outdoor,
    distances: [90, 70, 50, 30],
    totalArrows: 144,
    targetSize: 122,
    ends: 24,
    arrowsPerEnd: 6,
    scoringType: '10-zone',
  ),
  ArcheryRound(
    id: 'indoor18',
    name: 'Indoor 18m',
    discipline: ArcheryDiscipline.indoor,
    distances: [18],
    totalArrows: 60,
    targetSize: 40,
    ends: 12,
    arrowsPerEnd: 5,
    scoringType: '10-zone',
  ),
  ArcheryRound(
    id: 'field',
    name: 'Field',
    discipline: ArcheryDiscipline.field,
    distances: [20, 30, 40, 50, 60],
    totalArrows: 72,
    targetSize: 40,
    ends: 24,
    arrowsPerEnd: 3,
    scoringType: 'field',
  ),
  ArcheryRound(
    id: '3d',
    name: '3D',
    discipline: ArcheryDiscipline.threeD,
    distances: [10, 20, 30, 40, 50, 60],
    totalArrows: 40,
    targetSize: 0,
    ends: 40,
    arrowsPerEnd: 1,
    scoringType: '3D',
  ),
];
