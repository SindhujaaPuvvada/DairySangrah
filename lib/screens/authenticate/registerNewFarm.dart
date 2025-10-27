import 'package:farm_expense_mangement_app/models/user.dart' as appUser;
import 'package:farm_expense_mangement_app/screens/authenticate/phoneno.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logging.dart';
import '../../main.dart';
import '../../services/database/userdatabase.dart';
import '../../shared/constants.dart';
import '../onboarding/onboard.dart';
import '../onboarding/onboardUtils.dart';
import '../wrappers/wrapperhome.dart';

class RegisterFarm extends StatefulWidget {
  const RegisterFarm({super.key});

  @override
  State<RegisterFarm> createState() => _RegisterFarmState();
}

class _RegisterFarmState extends State<RegisterFarm> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';
  final _formKey = GlobalKey<FormState>();

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final log = logger(RegisterFarm);

  String ownerName = '';
  String farmName = '';
  String location = '';
  int phoneNo = int.parse(SignUpPage.phoneNumber.replaceFirst("+91", ""));

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return MaterialApp(
      home: Scaffold(
          backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
            title: Center(
              child: Text(
                currentLocalization['Register a New Farm'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: TextEditingController(text: phoneNo.toString()),
                    readOnly: true,
                    decoration: textInputDecorationReg.copyWith(
                        labelText: currentLocalization['Phone No.']),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecorationReg.copyWith(
                        labelText: currentLocalization['Owner Name']),
                    onChanged: (val) {
                      setState(() => ownerName = val);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecorationReg.copyWith(
                      labelText: currentLocalization['Farm Name'],
                    ),
                    onChanged: (val) {
                      setState(() => farmName = val);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecorationReg.copyWith(
                        labelText: currentLocalization['Farm Address']),
                    onChanged: (val) {
                      setState(() => location = val);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final farmUser = appUser.FarmUser(
                              ownerName: ownerName,
                              farmName: farmName,
                              location: location,
                              phoneNo: phoneNo,
                              chosenLanguage: languageCode);

                          await DatabaseServicesForUser(user!.uid)
                              .infoToServer(user!.uid, farmUser);

                          bool showOnboarding = await checkForFirstLaunch();
                          if(context.mounted) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                                  return showOnboarding
                                      ? OnBoardingScreens()
                                      : const WrapperHomePage();
                                }));
                          }
                        } catch (error) {
                          log.e('Encountered error',
                              time: DateTime.now(), error: error.toString());
                        }
                      }
                    },
                    child: Text(
                      currentLocalization['register'] ?? '',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          )),
    );
  }

  Future<bool> checkForFirstLaunch() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    bool showOnBoard = await OnboardUtils.checkFirstLaunch(uid);
    return showOnBoard;
  }
}
