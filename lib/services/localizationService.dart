import 'dart:convert';

import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../logging.dart';

class Localization {
  //singleton class
  static final Localization _instance = Localization._internal();

  factory Localization() => _instance;

  Localization._internal(); // private constructor

  final Map<String, dynamic> translations = {};

  final log = logger(Localization);

  Future<void> init() async {
    try {
      // Fetch json file from Firebase Storage
      for (var lang in langCodes) {
        final transRef = FirebaseStorage.instance.ref().child(
          '/public/translations_$lang.json',
        );

        final bytes = await transRef.getData();
        if (bytes == null) {
          throw Exception(
            "Failed to download Json file for ${langCodeMap[lang]}",
          );
        } else {
          translations[lang] = json.decode(utf8.decode(bytes));
        }
      }
    } catch (e) {
      log.e("Error in fetch", time: DateTime.now(), error: e.toString());
      return;
    }
  }
}
