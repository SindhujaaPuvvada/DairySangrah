import 'package:farm_expense_mangement_app/services/database/breedDatabase.dart';

import '../models/breed.dart';

class BreedService {
  //Singleton Instance
  static final BreedService _instance = BreedService._internal();

  factory BreedService() => _instance;
  BreedService._internal(); // private constructor

  List<String> _cachedCowBreeds = [];
  List<String> _cachedBuffaloBreeds = [];
  DatabaseServicesForBreed dbBreed = DatabaseServicesForBreed();

  Future<List<String>> getCowBreeds() async {
    //return cached cow breeds if available
    if (_cachedCowBreeds.isNotEmpty) {
      return _cachedCowBreeds;
    } else {
      // return from DB
      var snapshot = await dbBreed.infoFromServerAllBreeds();
      var allBreeds =
          snapshot.docs.map((doc) => Breed.fromFireStore(doc, null)).toList();
      for(Breed breed in allBreeds){
        if(breed.type == 'Cow'){
          _cachedCowBreeds.add(breed.breedName);
        }
        else{
          _cachedBuffaloBreeds.add(breed.breedName);
        }
      }
     return _cachedCowBreeds;
    }
  }

  Future<List<String>> getBuffaloBreeds() async {
    //return cached cow breeds if available
    if (_cachedBuffaloBreeds.isNotEmpty) {
      return _cachedBuffaloBreeds;
    } else {
      // return from DB
      var snapshot = await dbBreed.infoFromServerAllBreeds();
      var allBreeds =
          snapshot.docs.map((doc) => Breed.fromFireStore(doc, null)).toList();
      for(Breed breed in allBreeds){
        if(breed.type == 'Cow'){
          _cachedCowBreeds.add(breed.breedName);
        }
        else{
          _cachedBuffaloBreeds.add(breed.breedName);
        }
      }
      return _cachedBuffaloBreeds;
    }
  }
}
