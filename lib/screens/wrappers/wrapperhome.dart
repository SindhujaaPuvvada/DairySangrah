import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:farm_expense_mangement_app/screens/home/homepage.dart';
import 'package:farm_expense_mangement_app/screens/home/profilepage.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../shared/constants.dart';
import '../analytics/analyticsPage.dart';
import '../notification/alertnotificationpage.dart';
import '../reports/reportsPage.dart';

class WrapperHomePage extends StatefulWidget {
  const WrapperHomePage({super.key});

  @override
  State<WrapperHomePage> createState() => _WrapperHomePageState();
}

class LanguagePopup {
  static void showLanguageOptions(BuildContext context) {
    var languageCode = Provider.of<AppData>(
      context,
      listen: false,
    ).persistentVariable;
    Map<String, dynamic> currentLocalization = {};

    currentLocalization = Localization().translations[languageCode] ?? {};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            currentLocalization['Select Language'] ?? 'Select Language',
          ),
          content: SizedBox(
            height: 230,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: langCodes.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Center(
                    child: _buildLanguageOption(
                      context,
                      langCodeMap[langCodes[index]] ??
                          currentLocalization[langCodes[index]],
                      langCodes[index],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Widget _buildLanguageOption(
    BuildContext context,
    String language,
    String languageCode,
  ) {
    return InkWell(
      onTap: () {
        Provider.of<AppData>(context, listen: false).persistentVariable =
            languageCode;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(language, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _WrapperHomePageState extends State<WrapperHomePage> {
  late StreamController<int> _streamControllerScreen;
  final int _screenFromNumber = 0;
  int _selectedIndex = 0;

  late PreferredSizeWidget _appBar;
  late Widget _bodyScreen;
  late String farmId;

  @override
  void dispose() {
    _streamControllerScreen.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _streamControllerScreen = StreamController<int>.broadcast();
    _streamControllerScreen.add(_screenFromNumber);
    _appBar = const HomeAppBar();
    _bodyScreen = const HomePage();
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _appBar = const HomeAppBar();
        _bodyScreen = const HomePage();
      } else if (_selectedIndex == 1) {
        _appBar = ProfileAppBar();
        _bodyScreen = ProfilePage(farmId: farmId);
      } else if (_selectedIndex == 2) {
        LanguagePopup.showLanguageOptions(context);
      } else if (_selectedIndex == 3) {
        _appBar = const NotificationAppBar();
        _bodyScreen = AlertNotificationsPage(farmId: farmId);
      } else if (_selectedIndex == 4) {
        _appBar = const ReportsAppBar();
        _bodyScreen = ReportsPage(farmId: farmId);
      } else if (_selectedIndex == 5){
        _appBar = const AnalyticsAppBar();
        _bodyScreen = AnalyticsPage(farmId: farmId);
      }
    });
  }

  void home(BuildContext context) {
    setState(() {
      _updateIndex(0);
    });
  }

  void profile(BuildContext context) {
    setState(() {
      _updateIndex(1);
    });
  }

  void language(BuildContext context) {
    setState(() {
      _updateIndex(2);
    });
  }

  void notifications(BuildContext context) {
    setState(() {
      _updateIndex(3);
    });
  }

  void reports(BuildContext context) {
    setState(() {
      _updateIndex(4);
    });
  }

  void analytics(BuildContext context) {
    setState(() {
      _updateIndex(5);
    });
  }

  @override
  Widget build(BuildContext context) {
    farmId = Provider.of<AppData>(context).farmId;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: _appBar,
      body: _bodyScreen,
      bottomNavigationBar: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        child: BottomAppBar(
          shadowColor: Colors.white70,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'profile_tag',
                onPressed: () {
                  profile(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                heroTag: 'language_tag',
                onPressed: () {
                  LanguagePopup.showLanguageOptions(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.language,
                  size: 36,
                  color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                heroTag: 'home_tag',
                onPressed: () {
                  home(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.home,
                  size: 36,
                  color: _selectedIndex == 0 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                heroTag: 'notifications_tag',
                onPressed: () {
                  notifications(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.notifications,
                  size: 36,
                  color: _selectedIndex == 3 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                heroTag: 'analytics_tag',
                onPressed: () {
                  analytics(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.analytics_rounded,
                  size: 36,
                  color: _selectedIndex == 5 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                heroTag: 'reports_tag',
                onPressed: () {
                  reports(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.file_download_rounded,
                  size: 36,
                  color: _selectedIndex == 4 ? Colors.black : Colors.grey,
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
