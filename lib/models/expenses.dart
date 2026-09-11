class Expense {
  String expenseId;
  final String farmId;
  final String expenseType;
  final DateTime expenseDate;
  double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.expenseId,
    required this.farmId,
    required this.expenseType,
    required this.expenseDate,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromDB(Map<String, dynamic> data) {
    return Expense(
      expenseId: data['expenseId'].toString(),
      farmId: data['farmId'].toString(),
      expenseType: data['expenseType'],
      expenseDate: DateTime.parse(data['expenseDate']),
      amount: data['amount'].toDouble(),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'farmId': farmId,
      'expenseType': expenseType,
      'expenseDate': expenseDate.toString().split('.')[0],
      'amount': amount,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}

class FeedExpense {
  String id;
  final String expenseId;
  final String invId;
  final double quantityConsumed;

  FeedExpense({
    required this.id,
    required this.expenseId,
    required this.invId,
    required this.quantityConsumed,
  });

  factory FeedExpense.fromDB(Map<String, dynamic> data) {
    return FeedExpense(
      id: data['id'].toString(),
      expenseId: data['expenseId'].toString(),
      invId: data['invId'].toString(),
      quantityConsumed: data['quantityConsumed'].toDouble(),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'expenseId': expenseId,
      'invId': invId,
      'quantityConsumed': quantityConsumed,
    };
  }
}
