import 'package:farm_expense_mangement_app/services/database/breedDatabase.dart';
import '../models/breed.dart';

class BreedService {
  //Singleton Instance
  static final BreedService _instance = BreedService._internal();

  factory BreedService() => _instance;
  BreedService._internal(); // private constructor

  final List<String> cowBreeds = [];
  final List<String> buffaloBreeds = [];
  DbServicesForBreed dbBreed = DbServicesForBreed();

  Future<void> init() async {
    if (cowBreeds.isEmpty || buffaloBreeds.isEmpty) {
      // return from DB
      var snapshot = await dbBreed.infoFromServerAllBreeds();
      var allBreeds = snapshot.map((r) => Breed.fromDB(r)).toList();
      for (Breed breed in allBreeds) {
        if (breed.type == 'Cow') {
          cowBreeds.add(breed.breedName);
        } else {
          buffaloBreeds.add(breed.breedName);
        }
      }
    }
  }
}
