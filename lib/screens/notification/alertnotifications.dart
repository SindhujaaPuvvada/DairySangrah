import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/models/notification.dart';
import 'package:farm_expense_mangement_app/models/history.dart';
import 'package:farm_expense_mangement_app/screens/notification/alertypes.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:farm_expense_mangement_app/services/database/notificationdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertNotifications {
  late String uid;
  late DatabaseServicesForNotification ntfDb;
  late DatabaseServicesForCattle cattleDb;

  AlertNotifications() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    ntfDb = DatabaseServicesForNotification(uid);
    cattleDb = DatabaseServicesForCattle(uid);
  }

  Future<void> _updateSingleNotification(CattleNotification ntf) async {
    await ntfDb.infoToServerSingleNotification(ntf);
  }

  Future<void> _updateSingleCattle(Cattle cattle) async {
    await cattleDb.infoToServerSingleCattle(cattle);
  }

  void createNotifications(Cattle cattle, CattleHistory newHistory) {
    Map<String, String> altTitle = AlertsConstants.alertTitle;
    Map<String, String> altDesc = AlertsConstants.alertDesc;
    Map<String, List<String>> altEvents = AlertsConstants.alertsForEvents;
    DateTime nDate;
    int dDays;

    switch (newHistory.name) {
      case "Insemination":
      //creating PTA
        nDate = newHistory.date.add(
            const Duration(days: 15)); // Scheduled after 15 days
        _createNTF(cattle, altTitle['PTA']!, altDesc['PTA']!, nDate);

        // TODO: verify this part
        if (cattle.state == 'Calf') {
          cattle.state = 'Heifer';
          _updateSingleCattle(cattle);
        }

        break;
      case "Pregnant":
      //Creating NUA
        _createNTF(cattle, altTitle['NUA']!, altDesc['NUA']!, newHistory.date);

        if (cattle.state == 'Milked') {
          // DRA scheduled for 368-60 days for cow and 428-120 days for buffalo
          nDate = newHistory.date.add(const Duration(days: 308));
          _createNTF(cattle, altTitle['DRA']!, altDesc['DRA']!, nDate);
        }

        // CVA scheduled 368 for cow and 428 for buffalo
        dDays = (cattle.type == "Cow") ? 368 : 428;
        nDate = newHistory.date.add(Duration(days: dDays));
        _createNTF(cattle, altTitle['CVA']!, altDesc['CVA']!, nDate);

        // Creating MTV - scheduled after 120 days of pregnant event
        nDate = newHistory.date.add(const Duration(days: 120));
        _createNTF(cattle, altTitle['MTV']!, altDesc['MTV']!, nDate);

        // mark cattle as pregnant
        cattle.isPregnant = true;
        _updateSingleCattle(cattle);

        break;
      case "Dry":
        cattle.state = "Dry";
        _updateSingleCattle(cattle);

        break;
      case "Abortion":
        nDate = newHistory.date.add(const Duration(days: 30));

        if (cattle.state == 'Heifer') {
          _createNTF(cattle, altTitle['AIA']!, altDesc['AIA']!, nDate);
        } else {
          _createNTF(cattle, altTitle['HTA']!, altDesc['HTA']!, nDate);
        }

        if (cattle.state == 'Milked') {
          cattle.state = 'Dry';
        }

        // mark cattle as not pregnant here
        cattle.isPregnant = false;
        _updateSingleCattle(cattle);

        //closing the pregnant related notifications
        String rfidPhrase = '${cattle.type} ${cattle.rfid}';
        for(String alt in altEvents['Pregnant']!) {
          ntfDb.closeNotificationByPhrase("$rfidPhrase ${altDesc[alt]}");
        }

        break;

      case "Calved":
      // Creating MKA
        nDate = newHistory.date.add(const Duration(days: 3));
        _createNTF(cattle, altTitle['MKA']!, altDesc['MKA']!, nDate);

        // Creating HTA
        nDate = newHistory.date.add(const Duration(days: 60));
        _createNTF(cattle, altTitle['HTA']!, altDesc['HTA']!, nDate);

        cattle.state = 'Milked';
        cattle.isPregnant = false;
        _updateSingleCattle(cattle);


        break;
    }
  }


  void _createNTF(Cattle cattle, String nTitle, String nDesc, DateTime nDate) {
    CattleNotification ntf = CattleNotification(
        ntId: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        ntTitle: nTitle,
        ntDetails: "${cattle.type} ${cattle.rfid} $nDesc",
        ntShowDate: nDate // scheduled after 15 days
    );
    _updateSingleNotification(ntf);
  }


  void createCalfNotifications(Cattle cattle) {
    Map<String, String> altTitle = AlertsConstants.alertTitle;
    Map<String, String> altDesc = AlertsConstants.alertDesc;
    DateTime nDate;
    if(cattle.dateOfBirth != null) {
      int age = DateTime
          .now()
          .difference(cattle.dateOfBirth!)
          .inDays;

      // Creating DWV if age is less than 180 days
      if (age <= 180) {
        nDate = cattle.dateOfBirth!.add(const Duration(days: 90));
        _createNTF(cattle, altTitle['DWV']!, altDesc['DWV']!, nDate);
      }

      // Creating BRV if age is less than 365 days
      if (age <= 365) {
        nDate = cattle.dateOfBirth!.add(const Duration(days: 240));
        _createNTF(cattle, altTitle['BRV']!, altDesc['BRV']!, nDate);
      }

      //creating AI notification when it is ready to be a Heifer
      switch (cattle.type) {
        case 'Cow':
        // 13 months
          nDate = cattle.dateOfBirth!.add(const Duration(days: 390));
          _createNTF(cattle, altTitle['AIA']!, altDesc['AIA']!, nDate);
          break;
        case 'Buffalo':
        //28 months
          nDate = cattle.dateOfBirth!.add(const Duration(days: 840));
          _createNTF(cattle, altTitle['AIA']!, altDesc['AIA']!, nDate);

          break;
      }
    }
  }

}
