import 'package:farm_expense_mangement_app/models/user.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/showfarms.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logging.dart';
import '../../main.dart';
import '../../models/dairyfarm.dart';
import '../../services/database/dairyfarmDatabase.dart';
import '../../services/database/dairyfarmuserDatabase.dart';
import '../../services/database/userdatabase.dart';
import '../../services/localizationService.dart';
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
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  final _formKey = GlobalKey<FormState>();

  final uid = SupabaseService.client.auth.currentUser!.id;
  late DbServicesForUser userDB;

  final log = logger(RegisterFarm);

  String ownerName = '';
  String ownerNameDB = '';
  String farmName = '';
  String address = '';
  String phoneNo = '';
  bool isNewUser = false;

  @override
  void initState() {
    super.initState();
    userDB = DbServicesForUser();
    _fetchUserDetails(uid);
    _fetchPhoneNumber();
  }

  Future<void> _fetchUserDetails(String uid) async {
    final snapshot = await userDB.infoFromServer(uid);
    if (snapshot == null) {
      isNewUser = true;
    } else {
      ownerNameDB = snapshot['userName'];
      ownerName = snapshot['userName'];
    }
    setState(() {
      isNewUser;
      ownerNameDB;
      ownerName;
    });
  }

  Future<void> _fetchPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNo = prefs.getString('phoneNumber') ?? "";
    setState(() {
      phoneNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
        appBar: AppBar(
          leading: BackButton(
            color: Colors.black,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowFarmsPage()),
            ),
          ),
          backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
          centerTitle: true,
          title: Text(
            currentLocalization['Register a New Farm'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
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
                    labelText: currentLocalization['Phone No.'],
                  ),
                ),
                const SizedBox(height: 20.0),
                if (ownerNameDB.isNotEmpty || ownerNameDB != '') ...[
                  TextFormField(
                    controller: TextEditingController(text: ownerName),
                    decoration: textInputDecorationReg.copyWith(
                      labelText: currentLocalization['Owner Name'],
                    ),
                    readOnly: true,
                  ),
                ] else ...[
                  TextFormField(
                    decoration: textInputDecorationReg.copyWith(
                      labelText: currentLocalization['Owner Name'],
                    ),
                    onChanged: (val) {
                      setState(() => ownerName = val);
                    },
                  ),
                ],
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
                    labelText: currentLocalization['Farm Address'],
                  ),
                  onChanged: (val) {
                    setState(() => address = val);
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
                  ),
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    if (_formKey.currentState!.validate()) {
                      try {
                        if (isNewUser) {
                          final newUser = User(
                            userId: uid,
                            userName: ownerName,
                            phoneNumber: phoneNo,
                            chosenLanguage: languageCode,
                            createdAt: now,
                            updatedAt: now,
                          );

                          await DbServicesForUser().infoToServer(newUser);
                        }
                        final farm = DairyFarm(
                          ownerId: uid,
                          farmName: farmName,
                          address: address,
                          createdAt: now,
                          updatedAt: now,
                        );

                        final String farmId = await DbServicesForDairyFarm()
                            .infoToServer(uid, farm);

                        if (context.mounted) {
                          Provider.of<AppData>(context, listen: false).farmId =
                              farmId;

                          final dairyFarmUser = DairyFarmUser(
                            userId: uid,
                            farmId: farmId,
                            userRole: 'Owner',
                            createdAt: now,
                            updatedAt: now,
                          );
                          await DbServicesForDairyFarmUser().infoToServer(
                            dairyFarmUser,
                          );
                        }
                        if (context.mounted) {
                          final bool showOnBoard =
                              await OnboardUtils.checkFirstLaunch(farmId);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return showOnBoard
                                      ? OnBoardingScreens()
                                      : WrapperHomePage();
                                },
                              ),
                            );
                          }
                        }
                      } catch (error) {
                        log.e(
                          'Encountered error',
                          time: DateTime.now(),
                          error: error.toString(),
                        );
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
        ),
      ),
    );
  }
}
