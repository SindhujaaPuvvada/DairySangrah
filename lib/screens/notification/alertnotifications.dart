import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/models/notification.dart';
import 'package:farm_expense_mangement_app/models/event.dart';
import 'package:farm_expense_mangement_app/screens/notification/alertypes.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:farm_expense_mangement_app/services/database/notificationdatabase.dart';

class AlertNotifications {
  late DbServicesForNotification ntfDb;
  late DbServicesForCattle cattleDb;

  AlertNotifications() {
    ntfDb = DbServicesForNotification();
    cattleDb = DbServicesForCattle();
  }

  Future<void> _addNotification(CattleNotification ntf) async {
    await ntfDb.infoToServerSingleNotification(ntf);
  }

  Future<void> _updateCattleState(String cattleId, String state) async {
    await cattleDb.updateCattleState(cattleId, state);
  }

  Future<void> _updateCattleRepStatus(String cattleId, String repStatus) async {
    await cattleDb.updateCattleRepStatus(cattleId, repStatus);
  }

  Future<void> _updateCattleStateRepStatus(
    String cattleId,
    String state,
    String repStatus,
  ) async {
    await cattleDb.updateCattleStateRepStatus(cattleId, state, repStatus);
  }

  void createNotifications(Cattle cattle, CattleEvent newEvent) {
    Map<String, String> altTitle = AlertsConstants.alertTitle;
    Map<String, String> altDesc = AlertsConstants.alertDesc;
    Map<String, List<String>> altEvents = AlertsConstants.alertsForEvents;
    DateTime nDate;
    int dDays;
    String ntType = 'System-generated';

    switch (newEvent.eventName) {
      case "Insemination":
        //creating PTA
        nDate = newEvent.eventDate.add(
          const Duration(days: 15),
        ); // Scheduled after 15 days
        _createNTF(cattle, altTitle['PTA']!, altDesc['PTA']!, nDate, ntType);

        //mark cattle as inseminated
        cattle.reproductiveStatus = 'Inseminated';

        //change calf to heifer on first insemination
        if (cattle.state == 'Calf') {
          cattle.state = 'Heifer';
          _updateCattleStateRepStatus(cattle.cattleId, cattle.state, cattle.reproductiveStatus);
        }
        else{
          _updateCattleRepStatus(cattle.cattleId, cattle.reproductiveStatus);
        }

        break;
      case "Pregnant":
        //Creating NUA
        _createNTF(
          cattle,
          altTitle['NUA']!,
          altDesc['NUA']!,
          newEvent.eventDate,
          ntType,
        );

        if (cattle.state == 'Milked') {
          // DRA scheduled for 368-60 days for cow and 428-120 days for buffalo
          nDate = newEvent.eventDate.add(const Duration(days: 308));
          _createNTF(cattle, altTitle['DRA']!, altDesc['DRA']!, nDate, ntType);
        }

        // CVA scheduled 368 for cow and 428 for buffalo
        dDays = (cattle.type == "Cow") ? 368 : 428;
        nDate = newEvent.eventDate.add(Duration(days: dDays));
        _createNTF(cattle, altTitle['CVA']!, altDesc['CVA']!, nDate, ntType);

        // Creating MTV - scheduled after 120 days of pregnant event
        nDate = newEvent.eventDate.add(const Duration(days: 120));
        _createNTF(cattle, altTitle['MTV']!, altDesc['MTV']!, nDate, ntType);

        // mark cattle as pregnant
        cattle.reproductiveStatus = 'Pregnant';
        _updateCattleRepStatus(cattle.cattleId, cattle.reproductiveStatus);

        // Close PTA alert
        ntfDb.closeNotificationByTitle(cattle.cattleId, altTitle['PTA']!);

        break;
      case "Dry":
        cattle.state = "Dry";
        _updateCattleState(cattle.cattleId, cattle.state);

        break;
      case "Abortion":
        nDate = newEvent.eventDate.add(const Duration(days: 30));

        if (cattle.state == 'Heifer') {
          _createNTF(cattle, altTitle['AIA']!, altDesc['AIA']!, nDate, ntType);
        } else {
          _createNTF(cattle, altTitle['HTA']!, altDesc['HTA']!, nDate, ntType);
        }

        if (cattle.state == 'Milked') {
          cattle.state = 'Dry';
        }

        // mark cattle as not pregnant here
        cattle.reproductiveStatus = 'Open';
        _updateCattleStateRepStatus(
          cattle.cattleId,
          cattle.state,
          cattle.reproductiveStatus,
        );

        //closing the pregnant related notifications
        for (String alt in altEvents['Pregnant']!) {
          ntfDb.closeNotificationByTitle(cattle.cattleId, altTitle[alt]!);
        }

        break;

      case "Calved":
        // Creating MKA
        nDate = newEvent.eventDate.add(const Duration(days: 3));
        _createNTF(cattle, altTitle['MKA']!, altDesc['MKA']!, nDate, ntType);

        // Creating HTA
        nDate = newEvent.eventDate.add(const Duration(days: 60));
        _createNTF(cattle, altTitle['HTA']!, altDesc['HTA']!, nDate, ntType);

        cattle.state = 'Milked';
        cattle.reproductiveStatus = 'Open';
        _updateCattleStateRepStatus(
          cattle.cattleId,
          cattle.state,
          cattle.reproductiveStatus,
        );

        //closing the pregnant related notifications
        for (String alt in altEvents['Pregnant']!) {
          ntfDb.closeNotificationByTitle(cattle.cattleId, altTitle[alt]!);
        }

        break;
    }
  }

  void _createNTF(
    Cattle cattle,
    String nTitle,
    String nDesc,
    DateTime nDate,
    String ntType,
  ) {
    CattleNotification ntf = CattleNotification(
      ntId: '',
      farmId: cattle.farmId,
      ntType: ntType,
      ntLevel: 'Cattle',
      ntRelatedTo: cattle.cattleId.toString(),
      ntTitle: nTitle,
      ntDetails: (cattle.nickName != null)
          ? "${cattle.type} ${cattle.cattleId}(${cattle.nickName ?? ''}) $nDesc"
          : "${cattle.type} ${cattle.cattleId} $nDesc",
      ntShowDate: nDate, // scheduled after 15 days
      createdAt: DateTime.now(),
    );
    _addNotification(ntf);
  }

  void createCalfNotifications(Cattle cattle) {
    Map<String, String> altTitle = AlertsConstants.alertTitle;
    Map<String, String> altDesc = AlertsConstants.alertDesc;
    DateTime nDate;
    String ntType = 'System-generated';
    if (cattle.dateOfBirth != null) {
      int age = DateTime.now().difference(cattle.dateOfBirth!).inDays;

      // Creating DWV if age is less than 180 days
      if (age <= 180) {
        nDate = cattle.dateOfBirth!.add(const Duration(days: 90));
        _createNTF(cattle, altTitle['DWV']!, altDesc['DWV']!, nDate, ntType);
      }

      // Creating BRV if age is less than 365 days
      if (age <= 365) {
        nDate = cattle.dateOfBirth!.add(const Duration(days: 240));
        _createNTF(cattle, altTitle['BRV']!, altDesc['BRV']!, nDate, ntType);
      }

      //creating AI notification when it is ready to be a Heifer
      switch (cattle.type) {
        case 'Cow':
          // 13 months
          nDate = cattle.dateOfBirth!.add(const Duration(days: 390));
          _createNTF(cattle, altTitle['AIA']!, altDesc['AIA']!, nDate, ntType);
          break;
        case 'Buffalo':
          //28 months
          nDate = cattle.dateOfBirth!.add(const Duration(days: 840));
          _createNTF(cattle, altTitle['AIA']!, altDesc['AIA']!, nDate, ntType);

          break;
      }
    }
  }
}
