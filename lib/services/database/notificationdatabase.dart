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

    QuerySnapshot querySnapshot = await db
        .collection('User')
        .doc(uid)
        .collection('Notification')
        .where('ntId', isEqualTo: ntId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> closeNotification(String ntId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db
        .collection('User')
        .doc(uid)
        .collection('Notification')
        .where('ntId', isEqualTo: ntId)
        .get();


    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.update({'ntClosed': true});
    }
  }

}