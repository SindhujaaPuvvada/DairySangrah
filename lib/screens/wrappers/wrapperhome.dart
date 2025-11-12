import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:farm_expense_mangement_app/screens/home/homepage.dart';
import 'package:farm_expense_mangement_app/screens/home/profilepage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../notification/alertnotificationpage.dart';
import '../reports/reportsPage.dart';

class WrapperHomePage extends StatefulWidget {
  const WrapperHomePage({super.key});

  @override
  State<WrapperHomePage> createState() => _WrapperHomePageState();
}

class LanguagePopup {
  static void showLanguageOptions(BuildContext context) {
    var languageCode =
        Provider.of<AppData>(context, listen: false).persistentVariable;
    Map<String, String> currentLocalization = {};

    currentLocalization = langFileMap[languageCode]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            currentLocalization['Select Language'] ?? 'Select Language',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                currentLocalization['English'] ?? 'English',
                'en',
              ),
              _buildLanguageOption(
                context,
                currentLocalization['Hindi'] ?? 'Hindi',
                'hi',
              ),
              _buildLanguageOption(
                context,
                currentLocalization['Punjabi'] ?? 'Punjabi',
                'pa',
              ),
              _buildLanguageOption(
                context,
                currentLocalization['Telugu'] ?? 'Telugu',
                'te',
              ),
            ],
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
        child: Text(language, style: const TextStyle(fontSize: 16)),
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
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? fcmToUpdate = prefs.getBool('fcm_to_update');
    if (fcmToUpdate == true) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DatabaseServicesForUser userDB = DatabaseServicesForUser(uid);
      String? fcmToken = prefs.getString('fcm_token');
      await userDB.updateFCMToken(uid, fcmToken);
      await prefs.setBool('fcm_to_update', false);
    }
    if (mounted) {
      int counter = Provider.of<AppData>(context, listen: false).counter;
      if (counter == 0) {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        DatabaseServicesForUser userDB = DatabaseServicesForUser(uid);
        var langCode = await userDB.getChosenLanguage(uid);
        if (mounted) {
          Provider.of<AppData>(context, listen: false).persistentVariable =
              langCode;
          Provider.of<AppData>(context, listen: false).counter = 1;
        }
      }
    }
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _appBar = const HomeAppBar();
        _bodyScreen = const HomePage();
      } else if (_selectedIndex == 1) {
        _appBar = ProfileAppBar();
        _bodyScreen = const ProfilePage();
      } else if (_selectedIndex == 2) {
        LanguagePopup.showLanguageOptions(context);
      } else if (_selectedIndex == 3) {
        _appBar = const NotificationAppBar();
        _bodyScreen = const AlertNotificationsPage();
      } else if (_selectedIndex == 4) {
        _appBar = const ReportsAppBar();
        _bodyScreen = const ReportsPage();
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

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
        ),
      ),
    );
  }
}
