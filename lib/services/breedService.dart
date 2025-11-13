import 'package:farm_expense_mangement_app/services/database/breedDatabase.dart';

import '../models/breed.dart';

class BreedService {
  //Singleton Instance
  static final BreedService _instance = BreedService._internal();

  factory BreedService() => _instance;
  BreedService._internal(); // private constructor

  final List<String> _cachedCowBreeds = [];
  final List<String> _cachedBuffaloBreeds = [];
  List<List<String>> totBreeds = [];
  DatabaseServicesForBreed dbBreed = DatabaseServicesForBreed();

  Future<List<List<String>>> getBreeds() async {
    if (_cachedCowBreeds.isEmpty || _cachedBuffaloBreeds.isEmpty) {
      // return from DB
      var snapshot = await dbBreed.infoFromServerAllBreeds();
      var allBreeds =
          snapshot.docs.map((doc) => Breed.fromFireStore(doc, null)).toList();
      for (Breed breed in allBreeds) {
        if (breed.type == 'Cow') {
          _cachedCowBreeds.add(breed.breedName);
        } else {
          _cachedBuffaloBreeds.add(breed.breedName);
        }
      }
    }
    totBreeds.add(_cachedCowBreeds);
    totBreeds.add(_cachedBuffaloBreeds);
    return totBreeds;
  }
}
