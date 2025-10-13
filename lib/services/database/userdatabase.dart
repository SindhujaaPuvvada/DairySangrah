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

  Future<void> updateAppMode(String uid, String modePref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference docRef = db.collection('User').doc(uid);

    await docRef.update({
      'appMode': modePref,
    });
    return;
  }

  Future<String> getAppMode(String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await db.collection('User').doc(uid).get();

    return snapshot.data()?['appMode'];
  }

  Future<void> updateIsFirstLaunch(String uid, bool firstLaunch) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference docRef = db.collection('User').doc(uid);

    await docRef.update({
      'isFirstLaunch': firstLaunch,
    });
    return;
  }

  Future<bool> getIsFirstLaunch(String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await db.collection('User').doc(uid).get();

    return snapshot.data()?['isFirstLaunch'] ?? true;
  }

  Future<String> getChosenLanguage(String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await db.collection('User').doc(uid).get();

    return snapshot.data()?['chosenLanguage'] ?? 'en';
  }

  Future<void> updateFCMToken(String uid, String? fcmToken) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference docRef = db.collection('User').doc(uid);

    await docRef.update({
      'fcmToken': fcmToken,
    });
    return;
  }
}
