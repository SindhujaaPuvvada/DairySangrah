import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../main.dart';
import '../../models/cattlegroups.dart';
import '../../shared/constants.dart';
import '../cattle/cattleUtils.dart';
import 'onboardUtils.dart';

class OnBoardingScreens extends StatefulWidget{
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';


  final PageController pageController = PageController();

  final TextEditingController breedCountController = TextEditingController(
      text: '1');
  List<TextEditingController> milkedCountController = [];
  List<TextEditingController> dryCountController = [];
  List<TextEditingController> calfCountController = [];
  List<TextEditingController> heiferCountController = [];
  List<TextEditingController> maleCountController = [];
  List<String> selectedBreeds = [];

  final List<Map<String, dynamic>> _pageData = [
    {
      'title': 'breed_wise_title',
      'type': 'breedWise',
      'desc': 'welcome_msg_onboard'
    },
    {
      'title': 'cow_breeds_title',
      'type': 'breed',
      'desc': 'cow_breed_msg_onboard'
    },
    {
      'title': 'cow_count_title',
      'type': 'count',
      'desc': 'cow_count_msg_onboard'
    },
    {
      'title': 'buffalo_breeds_title',
      'type': 'breed',
      'desc': 'buffalo_breed_msg_onboard'
    },
    {
      'title': 'buffalo_count_title',
      'type': 'count',
      'desc': 'buffalo_count_msg_onboard'
    },
  ];

  String? _selectedOption = 'yes';

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

  @override
  Widget build(BuildContext context) {
    languageCode = Provider
        .of<AppData>(context)
        .persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    Map<String, String> cowBreedMap = {};
    for (var breed in cowBreed) {
      if(breed == 'None') {
        cowBreedMap['select'] = currentLocalization['select'] ?? 'select';
      }
      else{
        cowBreedMap[breed] = currentLocalization[breed] ?? breed;
      }
    }

    Map<String, String> buffaloBreedMap = {};
    for (var breed in buffaloBreed) {
      if(breed == 'None') {
        buffaloBreedMap['select'] = currentLocalization['select'] ?? 'select';
      }
      else{
        buffaloBreedMap[breed] = currentLocalization[breed] ?? breed;
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          itemCount: _pageData.length,
          itemBuilder: (BuildContext context, int index) {
            final data = _pageData[index];
            return Container(
              color: Color.fromRGBO(177, 243, 238, 0.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Text(
                      currentLocalization[data['title']] ?? '',
                      style: const TextStyle(fontSize: 35,
                          color: Color.fromRGBO(13, 166, 186, 1.0),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 10, 30),
                    child: Text(
                      currentLocalization[data['desc']] ?? '',
                      style: const TextStyle(fontSize: 18,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(height: 20),
                  if(data['type'] == 'breedWise')...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Radio<String>(
                          value: 'yes',
                          groupValue: _selectedOption,
                          activeColor: Color.fromRGBO(13, 166, 186, 1.0),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedOption = value;
                            });
                          },
                        ),
                        Text(currentLocalization['yes'] ?? 'Yes',
                          style: TextStyle(color: Colors.black, fontSize: 18),),
                        SizedBox(width: 50),
                        Radio<String>(
                          value: 'no',
                          groupValue: _selectedOption,
                          activeColor: Color.fromRGBO(13, 166, 186, 1.0),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedOption = value;
                            });
                          },
                        ),
                        Text(currentLocalization['no'] ?? 'No',
                            style: TextStyle(color: Colors.black, fontSize: 18)),
                      ],
                    )
                  ],
                  if(data['type'] == 'breed')...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
                      child: TextFormField(
                        controller: breedCountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))
                        ],
                        decoration: InputDecoration(
                          labelText: '${currentLocalization['enter_breed_count'] ??
                              "Enter the number of breeds"}*',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if(data['type'] == 'count')...[
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          int breedCount = int.parse(breedCountController.text);
                          for (int i = 0; i < breedCount; i++) {
                            milkedCountController.add(TextEditingController(
                                text: '0'));
                            dryCountController.add(TextEditingController(
                                text: '0'));
                            calfCountController.add(TextEditingController(
                                text: '0'));
                            heiferCountController.add(TextEditingController(
                                text: '0'));
                            maleCountController.add(TextEditingController(
                                text: '0'));
                            selectedBreeds.add('select');
                          }
                          return SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.85,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.50,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for(int j = 0; j < breedCount; j++)...[
                                    (_selectedOption == 'no') ?
                                    Container()
                                        :
                                    Text(
                                        "${currentLocalization['enter_for_breed']} ${j +
                                            1}",
                                        style: TextStyle(color: Color.fromRGBO(
                                            13, 166, 186, 1.0),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 20),
                                    (_selectedOption == 'no') ?
                                    Container()
                                        : OnboardUtils.buildDropdown(
                                        label: "${currentLocalization['breed']} ${j +
                                            1}",
                                        value: selectedBreeds[j],
                                        items: (index == 2)
                                            ? cowBreedMap
                                            : buffaloBreedMap,
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedBreeds[j] = newValue!;
                                          });
                                        }),
                                    SizedBox(height: 20),
                                    Row(
                                      spacing: 50,
                                      children: [
                                        Flexible(
                                          child: OnboardUtils.buildTextField(
                                              calfCountController[j],
                                              currentLocalization['enter_calf_count'] ??
                                                  '',
                                              true, ''),
                                        ),
                                        Flexible(
                                          child: OnboardUtils.buildTextField(
                                              heiferCountController[j],
                                              currentLocalization['enter_heifer_count'] ??
                                                  '',
                                              true, ''),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      spacing: 50,
                                        children: [
                                          Flexible(
                                            child: OnboardUtils.buildTextField(
                                                milkedCountController[j],
                                                currentLocalization['enter_milked_count'] ?? '',
                                                true, ''),
                                          ),
                                          Flexible(
                                            child: OnboardUtils.buildTextField(dryCountController[j],
                                                currentLocalization['enter_dry_count'] ?? '',
                                                true, ''),
                                          ),
                                        ]),
                                    SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: OnboardUtils.buildTextField(
                                              maleCountController[j],
                                              currentLocalization['enter_male_count'] ?? '',
                                              true, ''),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ],
                              ),
                            ),
                          );
                        })
                  ],
                  SizedBox(height: 50),
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
                        activeDotColor: Color.fromRGBO(13, 166, 186, 1.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  OnboardUtils.buildElevatedButton(
                    currentLocalization['Continue'] ?? 'Continue',
                    onPressed: () async {
                      if (data['type'] == 'count') {
                        int breedCount = int.parse(breedCountController.text);
                        String cattleType = (index == 2) ? 'Cow' : 'Buffalo';
                        int calfCount, heiferCount, milkedCount, dryCount,
                            maleCount;

                        for (int k = 0; k < breedCount; k++) {
                          calfCount = int.parse(calfCountController[k].text);
                          heiferCount = int.parse(
                              heiferCountController[k].text);
                          milkedCount = int.parse(
                              milkedCountController[k].text);
                          dryCount = int.parse(dryCountController[k].text);
                          maleCount = int.parse(maleCountController[k].text);
                          String breed = (_selectedOption == 'no')
                              ? 'None'
                              : selectedBreeds[k];
                          if (calfCount != 0 || heiferCount != 0 ||
                              milkedCount != 0 || dryCount != 0 ||
                              maleCount != 0) {
                            await createGroups(
                                cattleType,
                                breed,
                                calfCount,
                                heiferCount,
                                milkedCount,
                                dryCount,
                                maleCount);
                          }
                        }
                        breedCountController.text = '1';
                        selectedBreeds = [];
                        calfCountController = [];
                        heiferCountController = [];
                        milkedCountController = [];
                        dryCountController = [];
                        maleCountController = [];
                      }
                      if (index == _pageData.length - 1) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                WrapperHomePage()));
                      }
                      else {
                        if (_selectedOption == 'no' || (breedCountController.text) == '0') {
                          if ((index + 2)   > _pageData.length - 1) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    WrapperHomePage()));
                          }
                          else {
                            pageController.jumpToPage(index + 2);
                          }
                        } else {
                          pageController.jumpToPage(index + 1);
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> createGroups(String cattleType, String breed, int calfCount,
      int heiferCount, int milkedCount, int dryCount, int maleCount) async {

    if(calfCount != 0) {
      await CattleUtils.addCattleGrouptoDB(cattleType, breed, 'Calf');
    }
    if(heiferCount != 0) {
      await CattleUtils.addCattleGrouptoDB(cattleType, breed, 'Heifer');
    }
    if(milkedCount != 0) {
      await CattleUtils.addCattleGrouptoDB(cattleType, breed, 'Milked');
    }
    if(dryCount != 0) {
      await CattleUtils.addCattleGrouptoDB(cattleType, breed, 'Dry');
    }
    if(maleCount != 0) {
      await CattleUtils.addCattleGrouptoDB(cattleType, breed, 'Male');
    }
  }


}
