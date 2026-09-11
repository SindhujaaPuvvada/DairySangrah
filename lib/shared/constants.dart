import 'package:flutter/material.dart';

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
  'hi': 'हिंदी',
  'pa': 'ਪੰਜਾਬੀ',
  'te': 'తెలుగు',
};

const langCodes = ['en', 'hi', 'pa', 'te'];

const milkReportLevels = ['Whole-farm', 'Group-wise', 'Cattle-wise'];

const reportTypes = ['transactions', 'milk production', 'milk sale'];

const dateRangesList = ['7D', '1M', '3M', '1Y', 'Custom'];

const dateRangeIntervalMap = {'7D': 7, '1M': 30, '3M': 90, '1Y': 365};
