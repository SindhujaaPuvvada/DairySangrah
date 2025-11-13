import 'package:cloud_firestore/cloud_firestore.dart';

class Breed {
  final String type;
  final String breedName;

  Breed({required this.type, required this.breedName});

  factory Breed.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Breed(type: data?['type'], breedName: data?['breedName']);
  }

  Map<String, dynamic> toFireStore() {
    return {'type': type, 'breedName': breedName};
  }
}
