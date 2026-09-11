class Sale {
  String saleId;
  final String farmId;
  String saleType;
  final DateTime saleDate;
  double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sale({
    required this.saleId,
    required this.farmId,
    required this.saleType,
    required this.saleDate,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sale.fromDB(Map<String, dynamic> data) {
    return Sale(
      saleId: data['saleId'].toString(),
      farmId: data['farmId'].toString(),
      saleType: data['saleType'],
      saleDate: DateTime.parse(data['saleDate']),
      amount: data['amount'].toDouble(),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'farmId': farmId,
      'saleType': saleType,
      'saleDate': saleDate.toString().split('.')[0],
      'amount': amount,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}

class MilkSale {
  String id;
  final String saleId;
  final double? Fat;
  final double? SNF;
  double? temperature;
  final double quantity;

  MilkSale({
    required this.id,
    required this.saleId,
    this.Fat,
    this.SNF,
    this.temperature,
    required this.quantity,
  });

  factory MilkSale.fromDB(Map<String, dynamic> data) {
    return MilkSale(
      id: data['id'].toString(),
      saleId: data['saleId'].toString(),
      Fat: data['Fat'].toDouble(),
      SNF: data['SNF'].toDouble(),
      temperature: data['temperature']?.toDouble(),
      quantity: data['quantity']?.toDouble(),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'saleId': saleId,
      'Fat': Fat,
      'SNF': SNF,
      'temperature': temperature,
      'quantity': quantity,
    };
  }
}

class CattleSale {
  String id;
  final String saleId;
  final int cattleCount;
  final String? cattleIdsList;

  CattleSale({
    required this.id,
    required this.saleId,
    required this.cattleCount,
    this.cattleIdsList,
  });

  factory CattleSale.fromDB(Map<String, dynamic> data) {
    return CattleSale(
      id: data['id'].toString(),
      saleId: data['saleId'].toString(),
      cattleCount: data['cattleCount'],
      cattleIdsList: data['cattleIdsList'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'saleId': saleId,
      'cattleCount': cattleCount,
      'cattleIdsList': cattleIdsList,
    };
  }
}
