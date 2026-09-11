class Cattle {
  String cattleId;
  String? nickName;
  final String farmId;
  String? sex;
  int? breedId;
  String? breed;
  final double weight;
  String state;
  final String source;
  final String type;
  DateTime? dateOfBirth;
  String? motherInfo;
  String? fatherInfo;
  String reproductiveStatus;
  final bool isActive;
  String? inactiveReason;
  String? ext_cattleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cattle({
    required this.cattleId,
    this.nickName,
    required this.farmId,
    required this.sex,
    this.breedId,
    this.breed,
    this.weight = 0,
    required this.state,
    this.source = 'Born on Farm',
    required this.type,
    this.dateOfBirth,
    this.motherInfo,
    this.fatherInfo,
    this.reproductiveStatus = 'Open',
    this.isActive = true,
    this.inactiveReason,
    this.ext_cattleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cattle.fromDB(Map<String, dynamic> data) {
    return Cattle(
      cattleId: data['cattleId'].toString(),
      nickName: data['nickName'],
      farmId: data['farmId'].toString(),
      sex: data['sex'],
      breedId: data['breedId'],
      breed: (data.keys.contains('Breeds')) && (data['Breeds'] != null)
          ? data['Breeds']['breedName']
          : null,
      weight: data['weight'].toDouble(),
      state: data['state'],
      source: data['source'],
      type: data['type'],
      dateOfBirth: (data['dateOfBirth'] != null)
          ? DateTime.parse(data['dateOfBirth'])
          : null,
      motherInfo: (data['motherInfo'] != null)
          ? data['motherInfo'].toString()
          : null,
      fatherInfo: data['fatherInfo'],
      reproductiveStatus: data['reproductiveStatus'],
      isActive: data['isActive'],
      inactiveReason: data['inactiveReason'],
      ext_cattleId: data['ext_cattleId'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'nickName': nickName,
      'farmId': farmId,
      'sex': sex,
      'breedId': breedId,
      'weight': weight,
      'state': state,
      'source': source,
      'type': type,
      'dateOfBirth': (dateOfBirth != null)
          ? dateOfBirth.toString().split(' ')[0]
          : null,
      'motherInfo': motherInfo,
      'fatherInfo': fatherInfo,
      'reproductiveStatus': reproductiveStatus,
      'isActive': isActive,
      'inactiveReason': inactiveReason,
      'ext_cattleId': ext_cattleId,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}
