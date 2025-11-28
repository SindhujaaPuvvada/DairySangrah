import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/breed.dart';

class DatabaseServicesForBreed {
  DatabaseServicesForBreed();

  Future<void> infoToServerSingleBreed(Breed breed) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return await db
        .collection('CommonData')
        .doc('breedsDoc')
        .collection('Breeds')
        .doc()
        .set(breed.toFireStore());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllBreeds() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return await db
        .collection('CommonData')
        .doc('breedsDoc')
        .collection('Breeds')
        .orderBy('type')
        .get();
  }
}
