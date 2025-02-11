//TODO: for Cattle database access
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/notification.dart';

class DatabaseServicesForNotification {
  final String uid;
  DatabaseServicesForNotification(this.uid);

  Future<void> infoToServerSingleNotification(CattleNotification ntf) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Notification')
        .doc(ntf.ntId)
        .set(ntf.toFireStore());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> infoFromServer(
      String ntId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Notification')
        .doc('ntId')
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllNotifications() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Notification')
        .orderBy('ntId')
        .get();
  }

  Future<void> deleteNotification(String ntId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Notification')
        .doc('ntId')
        .delete();
  }
}