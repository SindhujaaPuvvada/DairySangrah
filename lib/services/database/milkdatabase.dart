import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/models/milk.dart';

class DatabaseForMilk {
  final String uid;
  DatabaseForMilk(this.uid);

  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllMilk(
      DateTime date) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Milk')
        .doc('D${date.day}M${date.month}Y${date.year}')
        .collection('Store')
        .get();
  }

  Future<void> infoToServerMilk(Milk milk) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Milk')
        .doc(
            'D${milk.dateOfMilk?.day}M${milk.dateOfMilk?.month}Y${milk.dateOfMilk?.year}')
        .collection('Store')
        .doc(milk.rfid)
        .set(milk.toFireStore());
  }

  Future<void> deleteAllMilkRecords(DateTime dateOfMilk) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Milk')
        .doc('D${dateOfMilk.day}M${dateOfMilk.month}Y${dateOfMilk.year}')
        .delete();
  }
}

class DatabaseForMilkByDate {
  final String uid;
  DatabaseForMilkByDate(this.uid);

  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllMilk() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Milk')
        .orderBy('dateOfMilk', descending: true)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> infoFromServerMilk(
      DateTime date) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Milk')
        .doc('D${date.day}M${date.month}Y${date.year}')
        .get();
  }

  Future<void> infoToServerMilk(MilkByDate milk) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Milk')
        .doc(
            'D${milk.dateOfMilk?.day}M${milk.dateOfMilk?.month}Y${milk.dateOfMilk?.year}')
        .set(milk.toFireStore());
  }
}
