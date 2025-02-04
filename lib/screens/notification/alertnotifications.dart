import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/models/notification.dart';
import 'package:farm_expense_mangement_app/models/history.dart';
import 'package:farm_expense_mangement_app/screens/notification/alertypes.dart';
import 'package:farm_expense_mangement_app/services/database/notificationdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';




class AlertNotifications {
  late String uid;
  late DatabaseServicesForNotification ntfDb;
  List<Map<String, String>> notifications = [];
  Map<String,bool> finishedAlerts ={};

  //List<Cattle> allCattle  = [];
  //var eventsList = [];

  AlertNotifications() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    ntfDb = DatabaseServicesForNotification(uid);
  }



  Future<void> _updateSingleNotification(CattleNotification ntf) async {
    await ntfDb.infoToServerSingleNotification(ntf);

    final snapshot = await ntfDb.infoFromServerAllNotifications(uid);
    List<CattleNotification> ntfs = snapshot.docs.map((doc) => CattleNotification.fromFireStore(doc, null)).toList();
    print(ntfs);

  }

  Future<List<Map<String, String>>> getNotifications() async {

   return (notifications);

    /*notifications = [
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
    ];*/

  }


  void createNotifications(Cattle cattle, CattleHistory newHistory) {
    switch (newHistory.name) {
      case "Insemination":
      /*AlertsConstants.alertsForEvents["Insemination"]?.forEach((val){
            var func = "create$val()";
            func;
         });*/
        _createPTA(cattle, newHistory);

        break;
    /*case "Pregnant":
      case "Abortion":
      case "Calved":*/
    }
  }

    void _createPTA(Cattle cattle, CattleHistory newHistory) {
     Map<String, String> alerts = AlertsConstants.alertDesc;
     CattleNotification ntf = CattleNotification(
         ntId: DateTime.now().microsecondsSinceEpoch.toString(),
         ntTitle: "Pregnancy Test Alert",
         ntDetails: "${cattle.type} with ${cattle.rfid} is ${alerts['PTA']}",
         ntShowDate: newHistory.date.add(const Duration(days:15))
     );
     _updateSingleNotification(ntf);
    }


}
