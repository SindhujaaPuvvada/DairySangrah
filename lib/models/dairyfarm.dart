class DairyFarm {
  String? farmId;
  final String ownerId;
  final String? ownerName;
  final String farmName;
  final String address;
  String? farmMode;
  bool? isFirstLaunch;
  final int minStockLevel;
  String? ext_farmId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DairyFarm({
    this.farmId,
    required this.ownerId,
    this.ownerName,
    required this.farmName,
    required this.address,
    this.farmMode, //Group Breed Wise(GBW) or (Normal)
    this.isFirstLaunch,
    this.minStockLevel = 1000, //in Kg
    this.ext_farmId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DairyFarm.fromDB(Map<String, dynamic> data) {
    return DairyFarm(
      farmId: data['farmId'].toString(),
      ownerId: data['ownerId'],
      ownerName: data.keys.contains('ownerName') ? data['ownerName'] : null,
      farmName: data['farmName'],
      address: data['address'],
      farmMode: data['farmMode'] ?? 'GBW',
      isFirstLaunch: data['isFirstLaunch'] ?? true,
      minStockLevel: data['minStockLevel'],
      ext_farmId: data['ext_farmId'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'ownerId': ownerId,
      'farmName': farmName,
      'address': address,
      'farmMode': farmMode,
      'isFirstLaunch': isFirstLaunch,
      'minStockLevel': minStockLevel,
      'ext_farmId': ext_farmId,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}
