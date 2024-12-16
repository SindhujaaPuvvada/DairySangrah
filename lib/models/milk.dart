import 'package:cloud_firestore/cloud_firestore.dart';

class Milk {
  double morning;
  double evening;
  DateTime? dateOfMilk;
  String rfid;
  Milk(
      {required this.rfid,
      this.morning = 0,
      this.evening = 0,
      required this.dateOfMilk});

  factory Milk.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Milk(
        morning: data?['morning'],
        evening: data?['evening'],
        dateOfMilk:
            (data?['dateOfMilk'] != null) ? data!['dateOfMilk'].toDate() : null,
        rfid: data?['rfid']);
  }

  Map<String, dynamic> toFireStore() {
    return {
      'morning': morning,
      'evening': evening,
      'dateOfMilk':
          (dateOfMilk != null) ? Timestamp.fromDate(dateOfMilk!) : null,
      'rfid': rfid
    };
  }
}

class MilkByDate {
  DateTime? dateOfMilk;
  double totalMilk;
  MilkByDate({required this.dateOfMilk, this.totalMilk = 0});

  factory MilkByDate.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return MilkByDate(
        dateOfMilk:
            (data?['dateOfMilk'] != null) ? data!['dateOfMilk'].toDate() : null,
        totalMilk: data?['totalMilk']);
  }

  Map<String, dynamic> toFireStore() {
    return {'dateOfMilk': dateOfMilk, 'totalMilk': totalMilk};
  }
}
