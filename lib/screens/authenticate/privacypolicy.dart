import 'package:farm_expense_mangement_app/screens/authenticate/showfarms.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../logging.dart';
import '../../services/supabaseService.dart';
import 'language.dart';

class PrivacyPolicyController extends StatefulWidget {
  const PrivacyPolicyController({super.key});

  @override
  State<PrivacyPolicyController> createState() =>
      _PrivacyPolicyControllerState();
}

class _PrivacyPolicyControllerState extends State<PrivacyPolicyController> {
  final log = logger(PrivacyPolicyController);
  bool hasConsent = true;
  final String consentKey = "accepted_privacy_policy";
  final String policyUrl =
      "https://sites.google.com/view/dairysangrah-privacy-policy/home?authuser=1";
  bool isLaunched = false;

  @override
  void initState() {
    checkConsent();
    super.initState();
  }

  Future<void> saveConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(consentKey, true);
  }

  Future<void> checkConsent() async {
    final prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(consentKey) ?? false;
    setState(() {
      hasConsent = value;
    });
  }

  Future<void> launchTheUrl() async {
    try {
      if (!await launchUrl(
        Uri.parse(policyUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $policyUrl');
      }
      setState(() {
        isLaunched = true;
      });
    } catch (e) {
      log.e(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: hasConsent
          ? navigateToApp()
          : AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Privacy Policy & Terms',
                style: TextStyle(
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text(
                      'We value your privacy. Please review our Privacy Policy to understand how we collect and use your data.',
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        launchTheUrl();
                      },
                      child: const Text(
                        'Read Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: isLaunched
                      ? () async {
                          await saveConsent();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => navigateToApp(),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Accept & Continue'),
                ),
              ],
            ),
    );
  }

  Widget navigateToApp() {
    return UpgradeAlert(
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
      child: StreamBuilder<AuthState?>(
        stream: SupabaseService.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = SupabaseService.client.auth.currentSession;
          final user = session?.user;
          if (user == null) {
            return SignUpPage();
          } else {
            log.i('Already logged in!!!');
            return const ShowFarmsPage();
          }
        },
      ),
    );
  }
}
