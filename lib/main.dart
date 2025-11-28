import 'package:farm_expense_mangement_app/api/notifications_api.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/authentication.dart';
import 'package:farm_expense_mangement_app/screens/onboarding/onboard.dart';
import 'package:farm_expense_mangement_app/screens/onboarding/onboardUtils.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/services/breedService.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/language.dart';
import 'package:upgrader/upgrader.dart';
import 'logging.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppData with ChangeNotifier {
  static String _persistentVariable = "en";
  static int _counter = 0;

  String get persistentVariable => _persistentVariable;
  int get counter => _counter;

  set persistentVariable(String value) {
    _persistentVariable = value;
    notifyListeners(); // Notify listeners of the change
  }

  set counter(int value) {
    _counter = value;
    notifyListeners(); // Notify listeners of the change
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  List<Future<void>> futures = [];
  futures.add(Localization().init());
  /*if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidDebugProvider(
        debugToken: '3C62A0C0-28DB-4D51-8E8F-71DDC4A7D89E',
      ), // for development
      //providerAndroid: AndroidPlayIntegrityProvider(), // for production
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      //providerAndroid: AndroidDebugProvider(debugToken: '3C62A0C0-28DB-4D51-8E8F-71DDC4A7D89E') // for development
      providerAndroid: AndroidPlayIntegrityProvider(), // for production
    );
  }
  final t = await FirebaseAppCheck.instance.getToken();
  print("DEBUG TOKEN: ${t}");*/

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    ChangeNotifierProvider(create: (context) => AppData(), child: MyApp()),
  );

  futures.add(NotificationsApi().initNotifications());
  futures.add(BreedService().init());
  await Future.wait(futures);

}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final log = logger(MyApp);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
                    return Container(
                      color: Colors.white,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> checkForFirstLaunch() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    bool showOnBoard = await OnboardUtils.checkFirstLaunch(uid);
    return showOnBoard;
  }
}
