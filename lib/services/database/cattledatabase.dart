import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cattle.dart';

class DatabaseServicesForCattle {
  final String uid;
  DatabaseServicesForCattle(this.uid);
  Future<bool> checkIfRFIDExists(String rfid) async {
    final doc = await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid)
        .get();

    return doc.exists;
  }

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
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Reference to the specific cattle document
    final DocumentReference cattleDocRef = db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid);

    // Delete all documents in the 'History' subcollection
    final QuerySnapshot historyDocs = await cattleDocRef.collection('History').get();
    // print(historyDocs);
    for (QueryDocumentSnapshot doc in historyDocs.docs) {
      await doc.reference.delete();
    }


    // Now delete the main cattle document
    await cattleDocRef.delete();
  }




}
