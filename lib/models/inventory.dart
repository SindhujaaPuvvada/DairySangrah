class Inventory {
  String invId;
  final DateTime invDate;
  final String farmId;
  final String feedCategory;
  final String feedName;
  final double quantityStocked;
  final double ratePerKg;
  final String source;
  double currentStockLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  Inventory({
    required this.invId,
    required this.invDate,
    required this.farmId,
    required this.feedCategory,
    required this.feedName,
    required this.quantityStocked,
    required this.ratePerKg,
    required this.source,
    required this.currentStockLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDB() {
    return {
      'invDate': invDate.toString().split('.')[0],
      'farmId': farmId,
      'feedCategory': feedCategory,
      'feedName': feedName,
      'quantityStocked': quantityStocked,
      'ratePerKg': ratePerKg,
      'source': source,
      'currentStockLevel': currentStockLevel,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': createdAt.toIso8601String().split('.')[0],
    };
  }

  // Updated fromDB to require only one argument
  factory Inventory.fromDB(Map<String, dynamic> data) {
    return Inventory(
      invId: data['invId'].toString(),
      invDate: DateTime.parse(data['invDate']),
      farmId: data['farmId'].toString(),
      feedCategory: data['feedCategory'],
      feedName: data['feedName'],
      quantityStocked: data['quantityStocked'].toDouble() ?? 0,
      ratePerKg: data['ratePerKg'].toDouble() ?? 0,
      source: data['source'],
      currentStockLevel: data['currentStockLevel'].toDouble() ?? 0,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }
}
