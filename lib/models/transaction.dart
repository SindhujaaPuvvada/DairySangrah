import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String name;
  double value;
  DateTime? saleOnMonth;
  double? quantity;

  Sale({
    required this.name,
    required this.value,
    required this.saleOnMonth,
    this.quantity,
  });

  factory Sale.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Sale(
      name: data?['name'],
      value: data?['value'],
      saleOnMonth:
          (data?['saleOnMonth'] != null) ? data!['saleOnMonth'].toDate() : null,
      quantity: data?['quantity'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'name': name,
      'value': value,
      'saleOnMonth':
          (saleOnMonth != null) ? Timestamp.fromDate(saleOnMonth!) : null,
      'quantity': quantity,
    };
  }
}

class Expense {
  String name;
  double value;
  DateTime? expenseOnMonth;
  //double? quantity;

  Expense({
    required this.name,
    required this.value,
    required this.expenseOnMonth /*this.quantity*/,
  });

  factory Expense.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Expense(
      name: data?['name'],
      value: data?['value'],
      expenseOnMonth:
          (data?['expenseOnMonth'] != null)
              ? data!['expenseOnMonth'].toDate()
              : null,
      //quantity: data?['quantity'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'name': name,
      'value': value,
      'expenseOnMonth':
          (expenseOnMonth != null) ? Timestamp.fromDate(expenseOnMonth!) : null,
      //'quantity': quantity,
    };
  }
}
