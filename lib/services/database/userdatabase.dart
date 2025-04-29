import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';


class DatabaseServicesForUser {
  final String uid;

  DatabaseServicesForUser(this.uid);

  Future<void> infoToServer(String uid, FarmUser userInfo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db.collection('User').doc(uid).set(userInfo.toFireStore());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> infoFromServer(
      String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db.collection('User').doc(uid).get();
  }

}