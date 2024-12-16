import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String name;
  double value;
  DateTime? saleOnMonth;

  Sale({required this.name, required this.value, required this.saleOnMonth});

  factory Sale.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Sale(
      name: data?['name'],
      value: data?['value'],
      saleOnMonth:
          (data?['saleOnMonth'] != null) ? data!['saleOnMonth'].toDate() : null,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'name': name,
      'value': value,
      'saleOnMonth':
          (saleOnMonth != null) ? Timestamp.fromDate(saleOnMonth!) : null
    };
  }
}

class Expense {
  String name;
  double value;
  DateTime? expenseOnMonth;

  Expense(
      {required this.name, required this.value, required this.expenseOnMonth});

  factory Expense.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Expense(
      name: data?['name'],
      value: data?['value'],
      expenseOnMonth: (data?['expenseOnMonth'] != null)
          ? data!['expenseOnMonth'].toDate()
          : null,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'name': name,
      'value': value,
      'expenseOnMonth':
          (expenseOnMonth != null) ? Timestamp.fromDate(expenseOnMonth!) : null
    };
  }
}
