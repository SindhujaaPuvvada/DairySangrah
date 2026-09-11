class CattleGroup {
  String grpId;
  final String farmId;
  final String type;
  int? breedId;
  String? breed;
  final String state;
  final DateTime createdAt;

  CattleGroup({
    required this.grpId,
    required this.farmId,
    required this.type,
    this.breedId,
    this.breed,
    required this.state,
    required this.createdAt,
  });

  factory CattleGroup.fromDB(Map<String, dynamic> data) {
    return CattleGroup(
      grpId: data['grpId'].toString(),
      farmId: data['farmId'].toString(),
      type: data['type'],
      breedId: data['breedId'],
      breed: (data.keys.contains('Breeds')) && (data['Breeds'] != null)
          ? data['Breeds']['breedName']
          : null,
      state: data['state'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'farmId': farmId.toString(),
      'type': type,
      'breedId': breedId,
      'state': state,
      'createdAt': createdAt.toIso8601String().split('.')[0],
    };
  }
}
