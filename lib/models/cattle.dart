import 'package:cloud_firestore/cloud_firestore.dart';

// final cattle = Cattle(rfid:"5515154", sex: "male",age:  10,breed: "cow" ,lactationCycle:  2,weight:  120,/*dateOfBirth: DateTime.parse('2020-12-01')*/);

class Cattle {
  final String rfid;
  String? nickname;
  String? sex;
  //final int age;
  String? breed;
  final int weight;
  String state;
  final String? source;
  final String type;
  bool isPregnant;
  DateTime? dateOfBirth;

  Cattle(
      {required this.rfid,
      this.nickname,
      required this.sex,
      this.breed,
      this.weight = 0,
      this.state = 'Dry',
      this.source = 'Born on Farm',
      required this.type,
      this.isPregnant = false,
      this.dateOfBirth});

  factory Cattle.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Cattle(
      rfid: data?['rfid'],
      nickname: data?['nickname'],
      sex: data?['sex'],
      breed: data?['breed'],
      weight: data?['weight'],
      state: data?['state'],
      source: data?['source'],
      type: data?['type'],
      isPregnant: data?['isPregnant'],
      dateOfBirth:
          (data?['dateOfBirth'] != null) ? data!['dateOfBirth'].toDate() : null,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'rfid': rfid,
      'nickname': nickname,
      'sex': sex,
      'breed': breed,
      'weight': weight,
      'state': state,
      'source': source,
      'type': type,
      'isPregnant': isPregnant,
      'dateOfBirth': dateOfBirth
    };
  }
}
