import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/models/transaction.dart';

class DatabaseForSale {
  String uid;
  DatabaseForSale({required this.uid});

  Future<QuerySnapshot<Map<String, dynamic>>>
      infoFromServerAllTransaction() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Sale')
        .orderBy('saleOnMonth', descending: true)
        .get();
  }

  Future<void> infoToServerSale(Sale sale) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Sale')
        .doc(
            "${sale.name.replaceAll(' ', '')}D${sale.saleOnMonth!.day}M${sale.saleOnMonth!.month}Y${sale.saleOnMonth!.year}")
        .set(sale.toFireStore());
  }

  Future<void> deleteSaleFromServer(Sale sale) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Sale')
        .doc(
            "${sale.name.replaceAll(' ', '')}D${sale.saleOnMonth!.day}M${sale.saleOnMonth!.month}Y${sale.saleOnMonth!.year}")
        .delete();
  }

  Future<DocumentSnapshot> infoFromServerSaleOnDate(
      String name, DateTime? saleOnMonth) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Sale')
        .doc(
            "${name.replaceAll(' ', '')}D${saleOnMonth!.day}M${saleOnMonth.month}Y${saleOnMonth.year}")
        .get();
  }
}

class DatabaseForExpense {
  String uid;
  DatabaseForExpense({required this.uid});

  Future<QuerySnapshot<Map<String, dynamic>>>
      infoFromServerAllTransaction() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Expense')
        .orderBy('expenseOnMonth', descending: true)
        .get();
  }

  Future<void> infoToServerExpense(Expense expense) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Expense')
        .doc(
            "${expense.name.replaceAll(' ', '')}D${expense.expenseOnMonth!.day}M${expense.expenseOnMonth!.month}Y${expense.expenseOnMonth!.year}")
        .set(expense.toFireStore());
  }

  Future<void> deleteExpenseFromServer(Expense expense) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Expense')
        .doc(
            "${expense.name.replaceAll(' ', '')}D${expense.expenseOnMonth!.day}M${expense.expenseOnMonth!.month}Y${expense.expenseOnMonth!.year}")
        .delete();
  }

  Future<DocumentSnapshot> infoFromServerExpenseOnDate(
      String name, DateTime? expenseOnMonth) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Expense')
        .doc(
            "${name.replaceAll(' ', '')}D${expenseOnMonth!.day}M${expenseOnMonth.month}Y${expenseOnMonth.year}")
        .get();
  }
}
