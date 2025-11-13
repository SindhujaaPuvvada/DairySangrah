import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../main.dart';
import '../../services/breedService.dart';
import '../../shared/constants.dart';
import '../cattle/cattleUtils.dart';
import 'onboardUtils.dart';

class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final PageController pageController = PageController();

  final TextEditingController breedCountController = TextEditingController(
    text: '1',
  );
  List<TextEditingController> milkedCountController = [];
  List<TextEditingController> dryCountController = [];
  List<TextEditingController> calfCountController = [];
  List<TextEditingController> heiferCountController = [];
  List<TextEditingController> maleCountController = [];
  List<String> selectedBreeds = [];

  bool isButtonDisabled = false;

  final List<Map<String, dynamic>> _pageData = [
    {
      'title': 'breed_wise_title',
      'type': 'breedWise',
      'desc': 'welcome_msg_onboard',
    },
    {
      'title': 'cow_breeds_title',
      'type': 'breed',
      'desc': 'cow_breed_msg_onboard',
    },
    {
      'title': 'cow_count_title',
      'type': 'count',
      'desc': 'cow_count_msg_onboard',
    },
    {
      'title': 'buffalo_breeds_title',
      'type': 'breed',
      'desc': 'buffalo_breed_msg_onboard',
    },
    {
      'title': 'buffalo_count_title',
      'type': 'count',
      'desc': 'buffalo_count_msg_onboard',
    },
  ];

  String? _selectedOption = 'yes';

  late List<String> cowBreed;
  late List<String> buffaloBreed;

  Future<void>? _breedsFuture;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _getBreeds();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    breedCountController.dispose();
    for (int i = 0; i < calfCountController.length; i++) {
      calfCountController[i].dispose();
      heiferCountController[i].dispose();
      dryCountController[i].dispose();
      milkedCountController[i].dispose();
      maleCountController[i].dispose();
    }
  }

  Future<void> _getBreeds() async {
    var totBreeds = await BreedService().getBreeds();
    setState(() {
      cowBreed = totBreeds[0];
      buffaloBreed = totBreeds[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
    return FutureBuilder<void>(
      future: _breedsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          Map<String, String> cowBreedMap = {};
          cowBreedMap['select'] = currentLocalization['select'] ?? 'select';
          for (var breed in cowBreed) {
            cowBreedMap[breed] = currentLocalization[breed] ?? breed;
          }

          Map<String, String> buffaloBreedMap = {};
          buffaloBreedMap['select'] = currentLocalization['select'] ?? 'select';
          for (var breed in buffaloBreed) {
            buffaloBreedMap[breed] = currentLocalization[breed] ?? breed;
          }

          return Scaffold(
            body: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              itemCount: _pageData.length,
              itemBuilder: (BuildContext context, int index) {
                final data = _pageData[index];
                return SingleChildScrollView(
                  child: Container(
                    color: Colors.white54,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(36),
                                bottomRight: Radius.circular(36),
                              ),
                              child: Image.asset(
                                'asset/base.jpg',
                                fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.22,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                15,
                                10,
                                10,
                              ),
                              child: Text(
                                currentLocalization[data['title']] ?? '',
                                style: const TextStyle(
                                  fontSize: 29,
                                  color: Color.fromRGBO(13, 166, 186, 1.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                30,
                                10,
                                10,
                                20,
                              ),
                              child: Text(
                                currentLocalization[data['desc']] ?? '',
                                style: const TextStyle(
                                  color: Color.fromRGBO(165, 42, 42, 1.0),
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            if (data['type'] == 'breedWise') ...[
                              RadioGroup<String>(
                                groupValue: _selectedOption,
                                //activeColor: Color.fromRGBO(13, 166, 186, 1.0),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedOption = value;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Radio<String>(
                                      value: 'yes',
                                      activeColor: Color.fromRGBO(
                                        13,
                                        166,
                                        186,
                                        1.0,
                                      ),
                                    ),
                                    Text(
                                      currentLocalization['yes'] ?? 'Yes',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(width: 50),
                                    Radio<String>(
                                      value: 'no',
                                      activeColor: Color.fromRGBO(
                                        13,
                                        166,
                                        186,
                                        1.0,
                                      ),
                                    ),
                                    Text(
                                      currentLocalization['no'] ?? 'No',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (data['type'] == 'breed') ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  30,
                                  0,
                                  30,
                                  50,
                                ),
                                child: TextFormField(
                                  controller: breedCountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r"[0-9]"),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    labelText:
                                        '${currentLocalization['enter_breed_count'] ?? "Enter the number of breeds"}*',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            if (data['type'] == 'count') ...[
                              StatefulBuilder(
                                builder: (
                                  BuildContext context,
                                  StateSetter setState,
                                ) {
                                  int breedCount = int.parse(
                                    breedCountController.text,
                                  );
                                  for (int i = 0; i < breedCount; i++) {
                                    milkedCountController.add(
                                      TextEditingController(text: '0'),
                                    );
                                    dryCountController.add(
                                      TextEditingController(text: '0'),
                                    );
                                    calfCountController.add(
                                      TextEditingController(text: '0'),
                                    );
                                    heiferCountController.add(
                                      TextEditingController(text: '0'),
                                    );
                                    maleCountController.add(
                                      TextEditingController(text: '0'),
                                    );
                                    selectedBreeds.add('select');
                                  }
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.80,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.38,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (
                                            int j = 0;
                                            j < breedCount;
                                            j++
                                          ) ...[
                                            (_selectedOption == 'no')
                                                ? Text(
                                                  currentLocalization['enter_the_details'] ??
                                                      '',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                      13,
                                                      166,
                                                      186,
                                                      1.0,
                                                    ),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                                : Text(
                                                  "${currentLocalization['enter_for_breed']} ${j + 1}",
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                      13,
                                                      166,
                                                      186,
                                                      1.0,
                                                    ),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            SizedBox(height: 15),
                                            (_selectedOption == 'no')
                                                ? Container()
                                                : OnboardUtils.buildDropdown(
                                                  label:
                                                      "${currentLocalization['breed']} ${j + 1}",
                                                  value: selectedBreeds[j],
                                                  items:
                                                      (index == 2)
                                                          ? cowBreedMap
                                                          : buffaloBreedMap,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedBreeds[j] =
                                                          newValue!;
                                                    });
                                                  },
                                                ),
                                            SizedBox(height: 15),
                                            Row(
                                              spacing:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.15,
                                              children: [
                                                Flexible(
                                                  child: OnboardUtils.buildTextField(
                                                    calfCountController[j],
                                                    currentLocalization['enter_calf_count'] ??
                                                        '',
                                                    true,
                                                    '',
                                                  ),
                                                ),
                                                Flexible(
                                                  child: OnboardUtils.buildTextField(
                                                    heiferCountController[j],
                                                    currentLocalization['enter_heifer_count'] ??
                                                        '',
                                                    true,
                                                    '',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              spacing:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.15,
                                              children: [
                                                Flexible(
                                                  child: OnboardUtils.buildTextField(
                                                    milkedCountController[j],
                                                    currentLocalization['enter_milked_count'] ??
                                                        '',
                                                    true,
                                                    '',
                                                  ),
                                                ),
                                                Flexible(
                                                  child: OnboardUtils.buildTextField(
                                                    dryCountController[j],
                                                    currentLocalization['enter_dry_count'] ??
                                                        '',
                                                    true,
                                                    '',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: OnboardUtils.buildTextField(
                                                    maleCountController[j],
                                                    currentLocalization['enter_male_count'] ??
                                                        '',
                                                    true,
                                                    '',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            SizedBox(height: 20),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SmoothPageIndicator(
                                controller: pageController,
                                count: _pageData.length,
                                effect: ExpandingDotsEffect(
                                  dotColor: Colors.black26,
                                  dotHeight: 10,
                                  dotWidth: 10,
                                  expansionFactor: 8,
                                  activeDotColor: Color.fromRGBO(
                                    13,
                                    166,
                                    186,
                                    1.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            OnboardUtils.buildElevatedButton(
                              currentLocalization['Continue'] ?? 'Continue',
                              onPressed:
                                  isButtonDisabled
                                      ? () {}
                                      : () {
                                        setState(() {
                                          isButtonDisabled = true;
                                        });
                                        onContinue(index, data);
                                      },
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<void> createGroups(
    String cattleType,
    String? breed,
    int calfCount,
    int heiferCount,
    int milkedCount,
    int dryCount,
    int maleCount,
    int lastGrpId,
    int lastRFId,
  ) async {
    List<Future<void>> futures = [];

    futures.add(
      CattleUtils.addCattleGroupToDB(cattleType, breed, 'Calf', lastGrpId),
    );
    lastGrpId++;
    for (int i = 0; i < calfCount; i++) {
      futures.add(
        CattleUtils.addNewCattleToDB(cattleType, breed, 'Calf', lastRFId),
      );
      lastRFId++;
    }

    futures.add(
      CattleUtils.addCattleGroupToDB(cattleType, breed, 'Heifer', lastGrpId),
    );
    lastGrpId++;
    for (int i = 0; i < heiferCount; i++) {
      futures.add(
        CattleUtils.addNewCattleToDB(
          cattleType,
          breed,
          'Heifer',
          lastRFId,
          'Female',
        ),
      );
      lastRFId++;
    }

    futures.add(
      CattleUtils.addCattleGroupToDB(cattleType, breed, 'Milked', lastGrpId),
    );
    lastGrpId++;
    for (int i = 0; i < milkedCount; i++) {
      futures.add(
        CattleUtils.addNewCattleToDB(
          cattleType,
          breed,
          'Milked',
          lastRFId,
          'Female',
        ),
      );
      lastRFId++;
    }

    futures.add(
      CattleUtils.addCattleGroupToDB(cattleType, breed, 'Dry', lastGrpId),
    );
    lastGrpId++;
    for (int i = 0; i < dryCount; i++) {
      futures.add(
        CattleUtils.addNewCattleToDB(
          cattleType,
          breed,
          'Dry',
          lastRFId,
          'Female',
        ),
      );
      lastRFId++;
    }

    futures.add(
      CattleUtils.addCattleGroupToDB(
        cattleType,
        breed,
        'Adult Male',
        lastGrpId,
      ),
    );
    lastGrpId++;
    for (int i = 0; i < maleCount; i++) {
      futures.add(
        CattleUtils.addNewCattleToDB(
          cattleType,
          breed,
          'Adult Male',
          lastRFId,
          'Male',
        ),
      );
      lastRFId++;
    }

    await Future.wait(futures);
  }

  Future<void> onContinue(int index, var data) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseServicesForUser userDB = DatabaseServicesForUser(uid);
    List<Future<void>> futures = [];

    if (data['type'] == 'count') {
      int breedCount = int.parse(breedCountController.text);

      if (_selectedOption == 'yes') {
        futures.add(userDB.updateAppMode(uid, 'GBW'));
        for (int l = 0; l < breedCount; l++) {
          if (selectedBreeds[l] == 'select') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${currentLocalization['select_the_breed']} - ${currentLocalization['breed']} ${l + 1}",
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            setState(() {
              isButtonDisabled = false;
            });
            return;
          }
        }
      } else {
        futures.add(userDB.updateAppMode(uid, 'Normal'));
      }

      String cattleType = (index == 2) ? 'Cow' : 'Buffalo';
      int calfCount, heiferCount, milkedCount, dryCount, maleCount;
      int lastGrpId, lastRFId;
      int prevBreedCattleCount = 0;

      final results = await Future.wait([
        CattleUtils.getLastUsedGrpId(uid),
        CattleUtils.getLastUsedRFId(uid),
      ]);
      lastRFId = results[1];

      for (int k = 0; k < breedCount; k++) {
        calfCount = int.parse(calfCountController[k].text);
        heiferCount = int.parse(heiferCountController[k].text);
        milkedCount = int.parse(milkedCountController[k].text);
        dryCount = int.parse(dryCountController[k].text);
        maleCount = int.parse(maleCountController[k].text);
        String? breed = (_selectedOption == 'no') ? null : selectedBreeds[k];

        lastGrpId = results[0] + (k * 5);
        lastRFId = lastRFId + prevBreedCattleCount;

        futures.add(
          createGroups(
            cattleType,
            breed,
            calfCount,
            heiferCount,
            milkedCount,
            dryCount,
            maleCount,
            lastGrpId,
            lastRFId,
          ),
        );

        prevBreedCattleCount =
            (calfCount + heiferCount + milkedCount + dryCount + maleCount);
      }
      breedCountController.text = '1';
      selectedBreeds = [];
      calfCountController = [];
      heiferCountController = [];
      milkedCountController = [];
      dryCountController = [];
      maleCountController = [];
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (index == _pageData.length - 1) {
      futures.add(prefs.setBool('first_launch_$uid', false));
      futures.add(userDB.updateIsFirstLaunch(uid, false));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WrapperHomePage()),
        );
      }
    } else {
      if (_selectedOption == 'no' || (breedCountController.text) == '0') {
        if ((index + 2) > _pageData.length - 1) {
          futures.add(prefs.setBool('first_launch_$uid', false));
          futures.add(userDB.updateIsFirstLaunch(uid, false));
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WrapperHomePage()),
            );
          }
        } else {
          pageController.jumpToPage(index + 2);
        }
      } else {
        pageController.jumpToPage(index + 1);
      }
    }

    await Future.wait(futures);

    setState(() {
      isButtonDisabled = false;
    });
  }
}
