import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import 'dbConstants.dart';

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

  Future<void> deleteUserFromServer(String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot docSnapshot = await db.collection('User').doc(uid).get();

    //await docSnapshot.reference.delete();
  }

  Future<void> deleteFarmDataFromServer(String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    for(String coll in userSubCollections) {
      QuerySnapshot querySnapshot = await db.collection('User')
          .doc(uid)
          .collection(coll)
          .get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        //print(doc.id);
      }
    }
  }
}