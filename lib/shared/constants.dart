import 'package:flutter/material.dart';
import '../screens/home/localisations_en.dart';
import '../screens/home/localisations_hindi.dart';
import '../screens/home/localisations_punjabi.dart';
import '../screens/home/localisations_telugu.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  ),
);

const textInputDecorationReg = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
  ),
);

const fdCategoryId = ['GreenFodder', 'DryFodder', 'Concentrate'];

const langCodeMap = {
  'en': 'English',
  'hi': 'Hindi',
  'pa': 'Punjabi',
  'te': 'Telugu'
};

const langFileMap = {
  'en': LocalizationEn.translations,
  'hi': LocalizationHi.translations,
  'pa': LocalizationPun.translations,
  'te': LocalizationTe.translations
};

/*const cowBreed = [
  'select',
  'jersey',
  'holstein',
  'crossbred jersey',
  'crossbred HF',
  'sahiwal',
  'amritmahal',
  'hariana',
  'ongole',
  'tharparkar',
  'red sindhi',
  'red kandhari',
  'rathi',
  'kankrej',
  'krishna valley',
  'nagori',
  'gir',
];

const buffaloBreed = [
  'select',
  'murrah',
  'nili ravi',
  'bhadawari',
  'surti',
  'jaffarabadi',
  'mehsana',
  'pandharpuri',
  'banni',
];
*/

const milkEntryTypes = ['whole farm', 'group wise', 'cattle wise'];

const reportTypes = ['transactions','milk production', 'milk sale'];