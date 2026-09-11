import 'package:farm_expense_mangement_app/api/notifications_api.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/privacypolicy.dart';
import 'package:farm_expense_mangement_app/services/breedService.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:farm_expense_mangement_app/supabase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppData with ChangeNotifier {
  static String _persistentVariable = "en";
  static int _counter = 0;
  static String _farmId = '';

  String get persistentVariable => _persistentVariable;
  int get counter => _counter;
  String get farmId => _farmId;

  set persistentVariable(String value) {
    _persistentVariable = value;
    notifyListeners(); // Notify listeners of the change
  }

  set counter(int value) {
    _counter = value;
    notifyListeners(); // Notify listeners of the change
  }

  set farmId(String value) {
    _farmId = value;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: '.env.dev');
  await dotenv.load(fileName: '.env.prod');
  await SupabaseDB.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  List<Future<void>> futures = [];
  futures.add(Localization().init());

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const PrivacyPolicyController()
    );
  }
}
