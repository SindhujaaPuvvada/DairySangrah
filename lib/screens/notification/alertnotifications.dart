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
    DateTime nDate;
    int dDays;

    switch (newHistory.name) {
      case "Insemination":
      //creating PTA
        nDate = newHistory.date.add(
            const Duration(days: 15)); // Scheduled after 15 days
        _createNTF(cattle, altTitle['PTA']!, altDesc['PTA']!, nDate);

        // TODO: verify this part
        if (cattle.state == 'Calve') {
          cattle.state = 'Heifer';
          _updateSingleCattle(cattle);
        }

        break;
      case "Pregnant":
      //Creating NUA
        _createNTF(cattle, altTitle['NUA']!, altDesc['NUA']!, newHistory.date);

        if (cattle.state == 'Milked') {
          // MKA scheduled for 368-60 days for cow and 428-120 days for buffalo
          nDate = newHistory.date.add(const Duration(days: 308));
          _createNTF(cattle, altTitle['MKA']!, altDesc['MKA']!, nDate);
        }

        // CVA scheduled 368 for cow and 428 for buffalo
        dDays = (cattle.type == "Cow") ? 368 : 428;
        nDate = newHistory.date.add(Duration(days: dDays));
        _createNTF(cattle, altTitle['CVA']!, altDesc['CVA']!, nDate);

        // Creating MTV - scheduled after 120 days of pregnant event
        nDate = newHistory.date.add(const Duration(days: 120));
        _createNTF(cattle, altTitle['MTV']!, altDesc['MTV']!, nDate);

        // TODO: update cattle is pregnant here

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
          _updateSingleCattle(cattle);
        }

        // TODO: update cattle is not pregnant here

        break;

      case "Calved":
      // Creating MKA
        nDate = newHistory.date.add(const Duration(days: 3));
        _createNTF(cattle, altTitle['MKA']!, altDesc['MKA']!, nDate);

        // Creating HTA
        nDate = newHistory.date.add(const Duration(days: 60));
        _createNTF(cattle, altTitle['HTA']!, altDesc['HTA']!, nDate);

        cattle.state = 'Milked';
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


  void create_DWV_BRV_Notification(Cattle cattle) {
    Map<String, String> altTitle = AlertsConstants.alertTitle;
    Map<String, String> altDesc = AlertsConstants.alertDesc;
    DateTime nDate;
    DateTime now = DateTime(2024,5,1);

    // Creating DWV TODO: change to DOB and check if sch date is greater than current date
    nDate = /*cattle.dateOfBirth*/now.add(const Duration(days: 90));
    _createNTF(cattle, altTitle['DWV']!, altDesc['DWV']!, nDate);

    // Creating BRV TODO: Change to DOB and check if sch date is greater than current date
    nDate = /*cattle.dateOfBirth*/now.add(const Duration(days: 240));
    _createNTF(cattle, altTitle['BRV']!, altDesc['BRV']!, nDate);


  }

}
