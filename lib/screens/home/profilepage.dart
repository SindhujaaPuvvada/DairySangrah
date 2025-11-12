import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:farm_expense_mangement_app/logging.dart';
import 'package:farm_expense_mangement_app/main.dart';
import 'package:farm_expense_mangement_app/models/user.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/language.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../services/database/userdatabase.dart';
import '../authenticate/authUtils.dart';
import '../wrappers/wrapperhome.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  ProfileAppBar({super.key});

  final Color myColor = const Color(0xFF39445A);
  final log = logger(ProfileAppBar);

  @override
  Widget build(BuildContext context) {
    Map<String, String> currentLocalization = {};
    String languageCode = 'en';

    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return AppBar(
      leading: BackButton(
        color: Colors.white,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WrapperHomePage()),
            ),
      ),
      centerTitle: true,
      title: Text(
        currentLocalization['Profile'] ?? '',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
      actions: [
        MenuBar(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromRGBO(13, 166, 186, 1),
            ),
            elevation: WidgetStatePropertyAll<double>(1.0),
          ),
          children: [
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text(currentLocalization['Log out'] ?? ''),
                ),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      child: Text(currentLocalization['Delete Data'] ?? ''),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AuthUtils.buildAlertDialog(
                              title: currentLocalization["Are you Sure?"] ?? '',
                              content:
                                  currentLocalization['Delete Data Content'] ??
                                  '',
                              opt1: currentLocalization['yes'] ?? '',
                              onPressedOpt1: () async {
                                try {
                                  HttpsCallable callDeleteFarmData =
                                      FirebaseFunctions.instance.httpsCallable(
                                        'deleteFarmData',
                                      );
                                  bool isDeleting = true;
                                  if (isDeleting) {
                                    final snackBar = SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                        currentLocalization['data_del_msg'] ??
                                            'Please wait!',
                                      ),
                                      duration: Duration(minutes: 1),
                                    );
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(snackBar);
                                  }
                                  callDeleteFarmData().then((val) async {
                                    isDeleting = false;
                                    log.i(
                                      'Completed Sucessfully!',
                                      time: DateTime.now(),
                                    );
                                    if(context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => SignUpPage(),
                                        ),
                                            (Route<dynamic> route) => false,
                                      );
                                    }
                                  });
                                } catch (error) {
                                  log.e(
                                    'Encountered error',
                                    time: DateTime.now(),
                                    error: error.toString(),
                                  );
                                }
                              },
                              opt2: currentLocalization['cancel'] ?? '',
                              onPressedOpt2: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                    MenuItemButton(
                      child: Text(currentLocalization['Delete Account'] ?? ''),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AuthUtils.buildAlertDialog(
                              title: currentLocalization["Are you Sure?"] ?? '',
                              content:
                                  currentLocalization['Delete Account Content'] ??
                                  '',
                              opt1: currentLocalization['delete'] ?? '',
                              onPressedOpt1: () async {
                                var user = FirebaseAuth.instance.currentUser!;

                                //deleting the current user account permanently
                                user
                                    .delete()
                                    .then((val) async {
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => SignUpPage(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      }
                                    })
                                    .catchError((e) {
                                      if (e.code == 'requires-recent-login') {
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AuthUtils.buildAlertDialog(
                                                title:
                                                    currentLocalization['requires recent login'] ??
                                                    '',
                                                content:
                                                    currentLocalization['re_login content'] ??
                                                    '',
                                                opt1:
                                                    currentLocalization['re-login'] ??
                                                    '',
                                                onPressedOpt1: () {
                                                  FirebaseAuth.instance
                                                      .signOut();
                                                  Navigator.of(
                                                    context,
                                                  ).pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              SignUpPage(),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false,
                                                  );
                                                },
                                                opt2:
                                                    currentLocalization['cancel'] ??
                                                    '',
                                                onPressedOpt2: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        log.e(
                                          'Encountered error',
                                          time: DateTime.now(),
                                          error: e.toString(),
                                        );
                                      }
                                    });
                              },
                              opt2: currentLocalization['cancel'] ?? '',
                              onPressedOpt2: () => Navigator.pop(context),
                            );
                          },
                        );
                      },
                    ),
                  ],
                  child: Text(currentLocalization['More Options'] ?? ''),
                ),
              ],
              child: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfilePage extends StatefulWidget implements PreferredSizeWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';
  late String appVersion;
  late String appBuildNumber;

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late final Future<DocumentSnapshot<Map<String, dynamic>>>? _futureController;

  late FarmUser farmUser;
  late DatabaseServicesForUser userDb;

  Future<void> _fetchPkgInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      appBuildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    userDb = DatabaseServicesForUser(uid);
    setState(() {
      _fetchPkgInfo();
      _futureController = userDb.infoFromServer(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return FutureBuilder(
      future: _futureController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          farmUser = FarmUser.fromFireStore(snapshot.requireData, null);

          return Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(13, 166, 186, 0.9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  height: 180,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 35),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentLocalization['Farm Owner'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            farmUser.ownerName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    "${currentLocalization['app_version'] ?? ''}: $appVersion ($appBuildNumber)",
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 0),
                  child: Container(
                    color: Colors.blueGrey[100],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 18, 8, 18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                child: Icon(
                                  Icons.home,
                                  color: Color.fromRGBO(13, 166, 186, 1),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  currentLocalization["Farm Name"] ?? '',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Text(
                                farmUser.farmName,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),

                          // SizedBox(height: 20,),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Color.fromRGBO(13, 166, 186, 1),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  currentLocalization["Phone No."] ?? '',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: Text(
                                  "${farmUser.phoneNo}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Color.fromRGBO(13, 166, 186, 1),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  currentLocalization["Farm Address"] ?? '',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: Text(
                                  farmUser.location,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const Icon(
                                Icons.language,
                                color: Color.fromRGBO(13, 166, 186, 1),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  currentLocalization["Preferred Language"] ??
                                      'Preferred Language',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: Text(
                                  currentLocalization[langCodeMap[farmUser
                                      .chosenLanguage]]!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          /*Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color.fromRGBO(13, 166, 186, 1),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              SizedBox(
                                  width: 120,
                                  child: Text(
                                    currentLocalization["App Mode"] ??
                                        'App Mode',
                                    style: TextStyle(fontSize: 18),
                                  )),
                              const SizedBox(
                                width: 40,
                              ),
                              Expanded(
                                  child: Text(
                                currentLocalization[farmUser.appMode] ??
                                    farmUser.appMode,
                                style: const TextStyle(fontSize: 18),
                              )),
                            ],
                          ),*/
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProfileEditPage(
                              farmUser: farmUser,
                              refresh: () {
                                setState(() {
                                  final snapshot1 =
                                      userDb.infoFromServer(uid)
                                          as AsyncSnapshot<
                                            DocumentSnapshot<
                                              Map<String, dynamic>
                                            >
                                          >;
                                  farmUser = FarmUser.fromFireStore(
                                    snapshot1.requireData,
                                    null,
                                  );
                                });
                              },
                            ),
                      ),
                    );
                  },
                  child: Text(currentLocalization['Edit Profile'] ?? ''),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text(currentLocalization['Error in Fetch'] ?? ''),
          );
        }
      },
    );
  }
}

class ProfileEditPage extends StatefulWidget {
  final FarmUser farmUser;
  final Function refresh;
  const ProfileEditPage({
    super.key,
    required this.farmUser,
    required this.refresh,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _controllerName = TextEditingController();
  final _controllerOwnerName = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerAddress = TextEditingController();
  late String _selectedLanguage;
  //late String _selectedAppMode;

  @override
  void initState() {
    super.initState();
    _controllerName.text = widget.farmUser.farmName;
    _controllerOwnerName.text = widget.farmUser.ownerName;
    _controllerPhone.text = widget.farmUser.phoneNo.toString();
    _controllerAddress.text = widget.farmUser.location;
    _selectedLanguage = widget.farmUser.chosenLanguage;
    //_selectedAppMode = widget.farmUser.appMode;
  }

  Future updateUser(FarmUser user) async {
    final db = DatabaseServicesForUser(uid);
    db.infoToServer(uid, user);
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
        title: Text(
          currentLocalization['Edit Profile'] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40, 20, 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _controllerOwnerName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: currentLocalization['Owner Name'] ?? '',
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _controllerName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: currentLocalization['Farm Name'] ?? '',
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                readOnly: true,
                controller: _controllerPhone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: currentLocalization['Phone No.'] ?? '',
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _controllerAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: currentLocalization['Farm Address'] ?? '',
                ),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: currentLocalization["Preferred Language"] ?? '',
                  labelStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 12.0,
                  ),
                ),
                items:
                    langCodeMap.entries.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang.key,
                        child: Text(currentLocalization[lang.value]!),
                      );
                    }).toList(),
                onChanged: (val) => (_selectedLanguage = val!),
              ),
              const SizedBox(height: 25),
              /*DropdownButtonFormField<String>(
                    value: _selectedAppMode,
                    decoration: InputDecoration(
                      labelText: currentLocalization["App Mode"] ?? 'App Mode',
                      labelStyle: const TextStyle(
                          color: Colors.black54, fontSize: 14.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                    ),
                    items: appModes.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(currentLocalization[item] ?? item),
                      );
                    }).toList(),
                    onChanged: (val) => (_selectedAppMode = val!),
                  ),
                  const SizedBox(height: 25),*/
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final FarmUser farmUser = FarmUser(
                    ownerName: _controllerOwnerName.text,
                    farmName: _controllerName.text,
                    location: _controllerAddress.text,
                    phoneNo: int.parse(_controllerPhone.text),
                    chosenLanguage: _selectedLanguage,
                    appMode: widget.farmUser.appMode,
                    isFirstLaunch: widget.farmUser.isFirstLaunch,
                    fcmToken: widget.farmUser.fcmToken,
                  );
                  updateUser(farmUser);
                  Provider.of<AppData>(context, listen: false).counter = 0;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WrapperHomePage(),
                    ),
                  );
                },
                child: Text(
                  currentLocalization['Save Changes'] ?? '',
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
