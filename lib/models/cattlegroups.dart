import 'package:cloud_firestore/cloud_firestore.dart';

class CattleGroup {
  final String grpId;
  final String type;
  final String? breed;
  final String state;

  CattleGroup({
    required this.grpId,
    required this.type,
    required this.breed,
    required this.state,
  });

  factory CattleGroup.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return CattleGroup(
      grpId: data?['grpId'],
      type: data?['type'],
      breed: data?['breed'],
      state: data?['state'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'grpId': grpId,
      'type': type,
      'breed': breed,
      'state': state,
    };
  }
}
