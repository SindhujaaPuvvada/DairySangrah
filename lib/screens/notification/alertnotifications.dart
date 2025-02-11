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
  Map<String, bool> finishedAlerts = {};


  AlertNotifications() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    ntfDb = DatabaseServicesForNotification(uid);
  }

  Future<void> _updateSingleNotification(CattleNotification ntf) async {
    await ntfDb.infoToServerSingleNotification(ntf);
 }

   void createNotifications(Cattle cattle, CattleHistory newHistory) {

     switch (newHistory.name) {
       case "Insemination":
         _createPTA(cattle, newHistory);
         break;
       case "Pregnant":
         _createNUA(cattle, newHistory);
         _createDRA(cattle, newHistory);
         _createCVA(cattle, newHistory);
         break;
       case "Abortion":
         _createMKA(cattle, newHistory);
         _createHTA(cattle, newHistory);
         _createAIA(cattle, newHistory);
         break;
       case "Calved":
         _createMKA(cattle, newHistory); //
         _createHTA(cattle, newHistory);
         break;
     }
  }

  void _createPTA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "Pregnancy Test Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['PTA']}",
        ntShowDate: newHistory.date.add(
            const Duration(days: 15)) // scheduled after 15 days
    );
    _updateSingleNotification(ntf);
  }


  void _createNUA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "Nutritional Feed Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['NUA']}",
        ntShowDate: newHistory.date
    );
    _updateSingleNotification(ntf);
  }

  void _createDRA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    const int dryDuration = 220; // scheduled after (280-60) days for cow, (310-90) days for buffalo
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "Dry Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['DRA']}",
        ntShowDate: newHistory.date.add(const Duration(days: dryDuration))
    );
    _updateSingleNotification(ntf);
  }

  void _createCVA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    int calvingDuration = (cattle.type == "Cow")
        ? 280
        : 310; //cow -280 days and buffalo - 310 days
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "Calving Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['CVA']}",
        ntShowDate: newHistory.date.add(Duration(days: calvingDuration))
    );
    _updateSingleNotification(ntf);
  }

  void _createMKA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "Milking Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['MKA']}",
        ntShowDate: newHistory.date.add(const Duration(days: 3))
    );
    _updateSingleNotification(ntf);
  }

  void _createHTA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "Heat Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['HTA']}",
        ntShowDate: newHistory.date.add(const Duration(days: 60))
    );
    _updateSingleNotification(ntf);
  }

  void _createAIA(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> alerts = AlertsConstants.alertDesc;
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: "AI Alert",
        ntDetails: "${cattle.type} ${cattle.rfid} ${alerts['AIA']}",
        ntShowDate: newHistory.date.add(const Duration(days: 21))
    );
    _updateSingleNotification(ntf);
  }

}
