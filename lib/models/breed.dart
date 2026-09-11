class Breed {
  final int breedId;
  final String type;
  final String breedName;

  Breed({this.breedId = 0, required this.type, required this.breedName});

  factory Breed.fromDB(Map<String, dynamic> data) {
    return Breed(
      breedId: data['breedId'],
      type: data['type'],
      breedName: data['breedName'],
    );
  }

  Map<String, dynamic> toDB() {
    return {'type': type, 'breedName': breedName};
  }
}
