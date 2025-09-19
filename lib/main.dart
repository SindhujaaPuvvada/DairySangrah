import 'package:farm_expense_mangement_app/api/firebase_api.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/authentication.dart';
import 'package:farm_expense_mangement_app/screens/onboarding/onboard.dart';
import 'package:farm_expense_mangement_app/screens/onboarding/onboardUtils.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/language.dart';
import 'package:upgrader/upgrader.dart';
import 'logging.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppData with ChangeNotifier {
  static String _persistentVariable = "en";
  //static String _appMode = 'CGM';

  String get persistentVariable => _persistentVariable;
  //String get appMode => _appMode;

  set persistentVariable(String value) {
    _persistentVariable = value;
    notifyListeners(); // Notify listeners of the change
  }

  /*set appMode(String value) {
    _appMode = value;
    notifyListeners(); // Notify listeners of the change
  }*/
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(ChangeNotifierProvider(
    create: (context) => AppData(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final log = logger(MyApp);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UpgradeAlert(
          showIgnore: false,
          showLater: true,
          upgrader: Upgrader(
            countryCode: 'in',
            languageCode: 'en',
            //For testing
            /*debugDisplayAlways: true,
            debugDisplayOnce: false,
            minAppVersion: '1.0.0(9)', // Simulated minimum version
            debugLogging: true,*/
          ),
          child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user == null) {
                  return SignUpPage();
                  //Authenticate();
                } else {
                  log.i('Already logged in!!!');
                  return FutureBuilder(
                      future: checkForFirstLaunch(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          bool showOnboarding = snapshot.data!;
                          return showOnboarding
                              ? OnBoardingScreens()
                              : const WrapperHomePage();
                        } else {
                          return CircularProgressIndicator();
                        }
                      });
                }
              })),
    );
  }

  Future<bool> checkForFirstLaunch() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    bool showOnBoard = await OnboardUtils.checkFirstLaunch(uid);
    return showOnBoard;
  }
}
