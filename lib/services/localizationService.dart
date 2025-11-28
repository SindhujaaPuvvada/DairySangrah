import 'dart:convert';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging.dart';

class Localization {
  //singleton class
  static final Localization _instance = Localization._internal();

  factory Localization() => _instance;

  Localization._internal(); // private constructor

  Map<String, dynamic> translations = {};

  final log = logger(Localization);

  Future<void> init() async {
    List<Future<void>> futures = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Fetch json file from Firebase Storage
      for (var lang in langCodes) {
        String? jsonString = prefs.getString('translations_$lang');
        if(jsonString != null) {
          translations[lang] = json.decode(jsonString);
        }
        futures.add(loadDataFromFiles(lang));

        Future.wait(futures);
      }
    } catch (e) {
      log.e("Error in fetch", time: DateTime.now(), error: e.toString());
      return;
    }
  }

  Future<void> loadDataFromFiles(String lang) async {
    final transRef = FirebaseStorage.instance.ref().child(
      '/public/translations_$lang.json',
    );

    final bytes = await transRef.getData();
    if (bytes == null) {
      throw Exception("Failed to download Json file for ${langCodeMap[lang]}");
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = utf8.decode(bytes);
      translations[lang] = json.decode(jsonString);
      prefs.setString('translations_$lang', jsonString);
    }
  }
}
