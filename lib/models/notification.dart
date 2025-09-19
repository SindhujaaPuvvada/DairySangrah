import 'package:cloud_firestore/cloud_firestore.dart';

class CattleNotification {
  final String ntId;
  final String ntTitle;
  final String ntDetails;
  final DateTime ntShowDate;
  final bool ntClosed;

  CattleNotification(
      {required this.ntId,
      required this.ntTitle,
      required this.ntDetails,
      required this.ntShowDate,
      this.ntClosed = false});

  factory CattleNotification.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return CattleNotification(
        ntId: data?['ntId'],
        ntTitle: data?['ntTitle'],
        ntDetails: data?['ntDetails'],
        ntShowDate: data!['ntShowDate'].toDate(),
        ntClosed: data['ntClosed']);
  }

  Map<String, dynamic> toFireStore() {
    return {
      'ntId': ntId,
      'ntTitle': ntTitle,
      'ntDetails': ntDetails,
      'ntShowDate': Timestamp.fromDate(ntShowDate),
      'ntClosed': ntClosed
    };
  }
}
