import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/models/history.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/cattlehistorydatabase.dart';

class AlertNotifications {
  late String uid;
  late DatabaseServicesForCattle cattleDb;
  late DatabaseServiceForCattleHistory cattleHistory;
  List<Map<String, String>> notifications = [];
  //List<Cattle> allCattle  = [];
  //var eventsList = [];

  AlertNotifications() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    cattleDb = DatabaseServicesForCattle(uid);
    cattleHistory = DatabaseServiceForCattleHistory(uid: uid);

  }

  Future<List<Cattle>> _fetchAllCattle()  async {
    final snapshot = await cattleDb.infoFromServerAllCattle(uid);
    List<Cattle> allCattle =  snapshot.docs.map((doc) => Cattle.fromFireStore(doc, null)).toList();
    return allCattle;
  }

  Future<List<CattleHistory>> _fetchCattleHistory(String rfid) async {
    final snapshot = await cattleHistory.historyFromServer(rfid);
    List<CattleHistory> events =  snapshot.docs.map((doc) => CattleHistory.fromFireStore(doc, null)).toList();
    return events;
    }

  void _checkForDueAlerts(rfid, List<CattleHistory> events) {


  }

    List<Map<String, String>> getNotifications()  {

      _fetchAllCattle().then((allCattle){
        for(Cattle cattle in allCattle) {
          _fetchCattleHistory(cattle.rfid).then((events){
              _checkForDueAlerts(cattle.state, events);
          });
        }
      });


      notifications =[
        {
          "title": "Cattle Feed Low",
          "details": "Your cattle feed stock is running low. Please restock soon."
        },
        {
          "title": "Milk Production Updated",
          "details": "Morning milk production has been updated in your records."
        },
        {
          "title": "Expense Recorded",
          "details": "A new expense for medicine purchase has been recorded."
        },
      ];

      return notifications;
  }


}
