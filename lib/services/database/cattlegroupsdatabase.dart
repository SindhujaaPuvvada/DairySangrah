import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cattlegroups.dart';

class DatabaseServicesForCattleGroups {
  final String uid;

  DatabaseServicesForCattleGroups(this.uid);

  Future<bool> checkIfGrpIdExists(String grpId) async {
    final doc = await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('CattleGroups')
        .doc(grpId)
        .get();

    return doc.exists;
  }

  Future<void> infoToServerSingleCattleGrp(CattleGroup cattleGrp) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('CattleGroups')
        .doc(cattleGrp.grpId)
        .set(cattleGrp.toFireStore());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> infoFromServer(
      String grpId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('CattleGroups')
        .doc(grpId)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllCattleGrps(
      String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('CattleGroups')
        .orderBy('grpId')
        .get();
  }

  Future<void> deleteCattleGrp(String grpId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Reference to the specific group document
    final DocumentReference cattleGrpDocRef =
        db.collection('User').doc(uid).collection('CattleGroups').doc(grpId);

    // Now delete the group document
    await cattleGrpDocRef.delete();
  }

  Future<String> getLastUsedGrpId(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final QuerySnapshot<Map<String, dynamic>> cattleGrpDoc = await db
        .collection('User')
        .doc(uid)
        .collection('CattleGroups')
        .orderBy("grpId", descending: true)
        .limit(1)
        .get();

    if (cattleGrpDoc.docs.isNotEmpty) {
      var cattleGrp = CattleGroup.fromFireStore(cattleGrpDoc.docs[0], null);
      return cattleGrp.grpId;
    } else {
      return '0';
    }
  }

  Future<bool> grpCriteriaExists(
      String cattleType, String? breed, String status) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final QuerySnapshot<Map<String, dynamic>> cattleGrpDoc = await db
        .collection('User')
        .doc(uid)
        .collection('CattleGroups')
        .where('type', isEqualTo: cattleType)
        .where('breed', isEqualTo: breed)
        .where('state', isEqualTo: status)
        .limit(1)
        .get();

    if (cattleGrpDoc.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
