import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/models/history.dart';

class DatabaseServiceForCattleHistory {
  final String uid;

  DatabaseServiceForCattleHistory({required this.uid});

  Future<void> historyToServerSingleCattle(
      Cattle cattle, CattleHistory cattleHistory) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(cattle.rfid)
        .collection('History')
        .doc()
        .set(cattleHistory.toFireStore());
    // .doc('${cattleHistory.date.year}-${cattleHistory.date.month}-${cattleHistory.date.day}')
    // .set(cattleHistory.toFireStore());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> historyFromServer(
      String rfid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid)
        .collection('History')
        .get();
  }

  Future<void> deleteHistoryOfCattle(String rfid, String historyId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid)
        .collection('History')
        .doc(historyId)
        .delete();
  }

  Future<String> getLastAISireDetails(String rfid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    final QuerySnapshot<Map<String, dynamic>> historySnapshot= await db
        .collection('User')
        .doc(uid)
        .collection('Cattle')
        .doc(rfid)
        .collection('History')
        .where('name', isEqualTo: 'Insemination')
        .get();

    if (historySnapshot.docs.isNotEmpty) {
      var allAIEvents =
      historySnapshot.docs.map((doc) => CattleHistory.fromFireStore(doc, null)).toList();
      allAIEvents.sort((a, b) {
        // Custom sorting logic here
        // Example: sort by a field called 'name'
        DateTime dateA = a.date;
        DateTime dateB = b.date;
        return dateB.compareTo(dateA); // descending order
      });
      return allAIEvents[0].notes??'';
    } else {
      return '';
    }
  }
}
