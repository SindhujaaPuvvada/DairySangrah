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

const fdCategoryId = ['GreenFodder','DryFodder','Concentrate'];

const langCodeMap = {'en': 'English','hi': 'Hindi', 'pa': 'Punjabi','te': 'Telugu'};

const langFileMap = {
  'en': LocalizationEn.translations,
  'hi': LocalizationHi.translations,
  'pa': LocalizationPun.translations,
  'te': LocalizationTe.translations
};