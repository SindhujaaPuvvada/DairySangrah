class Milk {
  String milkId;
  final DateTime milkingDate;
  final String farmId;
  final String milkEntryType;
  final String milkEntryId;
  double morningMilk;
  double eveningMilk;
  final DateTime createdAt;
  DateTime updatedAt;

  Milk({
    required this.milkId,
    required this.milkingDate,
    required this.farmId,
    required this.milkEntryType,
    required this.milkEntryId,
    required this.morningMilk,
    required this.eveningMilk,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Milk.fromDB(Map<String, dynamic> data) {
    return Milk(
      milkId: data['milkId'].toString(),
      milkingDate: DateTime.parse(data['milkingDate']),
      farmId: data['farmId'].toString(),
      milkEntryType: data['milkEntryType'],
      milkEntryId: data['milkEntryId'].toString(),
      morningMilk: data['morningMilk'].toDouble(),
      eveningMilk: data['eveningMilk'].toDouble(),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'milkingDate': milkingDate.toString().split('.')[0],
      'farmId': farmId,
      'milkEntryType': milkEntryType,
      'milkEntryId': milkEntryId,
      'morningMilk': morningMilk,
      'eveningMilk': eveningMilk,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}
