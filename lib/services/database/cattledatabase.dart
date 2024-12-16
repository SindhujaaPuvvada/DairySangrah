//TODO: for Cattle database access
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/cattle.dart';

class DatabaseServicesForCattle {
  final String uid;
  DatabaseServicesForCattle(this.uid);

  Future<void> infoToServerSingleCattle(Cattle cattle) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(cattle.rfid)
        .set(cattle.toFireStore());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> infoFromServer(
      String rfid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllCattle(
      String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .orderBy('rfid')
        .get();
  }

  Future<void> deleteCattle(String rfid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid)
        .delete();
  }
}
