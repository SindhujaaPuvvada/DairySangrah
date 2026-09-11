import 'package:farm_expense_mangement_app/models/dairyfarm.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/registerNewFarm.dart';
import 'package:farm_expense_mangement_app/screens/onboarding/onboard.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/services/database/dairyfarmDatabase.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:provider/provider.dart';
import 'package:farm_expense_mangement_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database/userdatabase.dart';
import '../onboarding/onboardUtils.dart';

class ShowFarmsPage extends StatefulWidget {
  const ShowFarmsPage({super.key});

  @override
  State<ShowFarmsPage> createState() => _ShowFarmsPageState();
}

class _ShowFarmsPageState extends State<ShowFarmsPage> {
  String? selectedOption;
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  late List<DairyFarm> userFarms = [];
  late DbServicesForDairyFarm farmDb;
   late Future<void> _futureController;

  @override
  void initState() {
    super.initState();
    farmDb = DbServicesForDairyFarm();
    String uid = SupabaseService.client.auth.currentUser!.id;
    _loadData();
    setState(() {
      _futureController = _fetchFarmsForUser(uid);
    });
  }

  Future<void> _fetchFarmsForUser(uid) async {
    final data = await farmDb.infoFromServerAllFarms(uid);
    setState(() {
      userFarms = data;
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? fcmToUpdate = prefs.getBool('fcm_to_update');
    if (fcmToUpdate == true) {
      String uid = SupabaseService.client.auth.currentUser!.id;
      DbServicesForUser userDB = DbServicesForUser();
      String? fcmToken = prefs.getString('fcm_token');
      await userDB.updateFCMToken(uid, fcmToken);
      await prefs.setBool('fcm_to_update', false);
    }
    if (mounted) {
      int counter = Provider.of<AppData>(context, listen: false).counter;
      if (counter == 0) {
        String uid = SupabaseService.client.auth.currentUser!.id;
        DbServicesForUser userDB = DbServicesForUser();
        var langCode = await userDB.getChosenLanguage(uid);
        if (mounted) {
          Provider.of<AppData>(context, listen: false).persistentVariable =
              langCode;
          Provider.of<AppData>(context, listen: false).counter = 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    return FutureBuilder(
        future: _futureController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (userFarms.isEmpty) {
              return const RegisterFarm();
            } else {
              return Scaffold(
                backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
                  title: Text(
                    currentLocalization['My Farms'] ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  // Center the title
                  actions: [
                    IconButton(
                      tooltip: currentLocalization['Add new farm'] ?? "",
                      icon: const Icon(
                        Icons.add_home,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              RegisterFarm()),
                        );
                      },
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20), // Spacing from the top
                      // Subtitle text
                      Text(
                        currentLocalization['Select a farm to proceed'] ??
                            "Select a Farm",
                        style: TextStyle(
                          color: Color.fromRGBO(165, 42, 42, 0.9),
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: userFarms.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                Provider
                                    .of<AppData>(context, listen: false)
                                    .farmId =
                                userFarms[index].farmId!;
                                final bool showOnBoard =
                                await OnboardUtils.checkFirstLaunch(
                                  userFarms[index].farmId!,
                                );
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
                              },
                              child: Card(
                                margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                                color: Colors.white,
                                elevation: 8,
                                surfaceTintColor: Colors.transparent,
                                shadowColor: Color.fromRGBO(224, 191, 184, 0.5),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  height: 110,
                                  alignment: Alignment.center,
                                  child: ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 3, 5, 3),
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 1, 0, 1),
                                        foregroundDecoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              50),
                                          color: Color.fromRGBO(2, 48, 32, 1.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.asset(
                                          'asset/home.jpg',
                                          fit: BoxFit.fill,
                                          width: 70,
                                          height: 70,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                            Icons.house_outlined,
                                            color: Color.fromRGBO(
                                                13, 166, 186, 1.0)),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Text(
                                            userFarms[index].farmName,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                          color: Color.fromRGBO(
                                              13, 166, 186, 1.0),),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Text(
                                            userFarms[index].address,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          else{
            return Center(
              child: Text(currentLocalization['Error in Fetch'] ?? ''),
            );
          }
        });
        }
  }

