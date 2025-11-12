import 'package:farm_expense_mangement_app/screens/cattle/cattleUtils.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import '../../models/cattle.dart';
import '../../shared/breedService.dart';
import 'grouplist.dart';

class AddNewCattleGroup extends StatefulWidget {
  const AddNewCattleGroup({super.key});

  @override
  State<AddNewCattleGroup> createState() => _AddNewCattleGroupState();
}

class _AddNewCattleGroupState extends State<AddNewCattleGroup> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late final DatabaseServicesForCattleGroups cgrpDB;
  late final DatabaseServicesForCattle cattleDb;

  late List<String> cowBreed;
  late List<String> buffaloBreed;
  late List<Cattle> allCattle;


  final TextEditingController _customBreedTextController =
      TextEditingController();
  final TextEditingController _cattleCountTextController =
      TextEditingController(text: '0');
  final TextEditingController _existingCattleCountController =
      TextEditingController(text: '0');

  String _selectedType = 'Cow';
  String _selectedStatus = 'Milked';
  String? _selectedBreed;

  @override
  void initState() {
    super.initState();
    cgrpDB = DatabaseServicesForCattleGroups(uid);
    cattleDb = DatabaseServicesForCattle(uid);
    _getBreeds();
    _fetchCattle();
  }

  @override
  void dispose() {
    _customBreedTextController.dispose();
    _cattleCountTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchCattle() async {
    final snapshot = await cattleDb.infoFromServerAllCattle(uid);
    setState(() {
      allCattle =
          snapshot.docs.map((doc) => Cattle.fromFireStore(doc, null)).toList();
    });
  }

  Future<void> _getBreeds() async {
    cowBreed = await BreedService().getCowBreeds();
    buffaloBreed = await BreedService().getBuffaloBreeds();
    setState(() {
      cowBreed;
      buffaloBreed;
    });
  }

  String getExistingCattleCount(String type, String state, String? breed) {
    int existingCount;
    existingCount =
        allCattle
            .where(
              (cattle) =>
                  cattle.type == type &&
                          cattle.state == state &&
                          (breed != null)
                      ? cattle.breed == breed
                      : false,
            )
            .length;

    return existingCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    Map<String, String> typeMap = {
      'Cow': currentLocalization['Cow']!,
      'Buffalo': currentLocalization['Buffalo']!,
    };

    Map<String, String> statusMap = {
      'Milked': currentLocalization['Milked']!,
      'Heifer': currentLocalization['Heifer']!,
      'Calf': currentLocalization['Calf']!,
      'Dry': currentLocalization['Dry']!,
      'Adult Male': currentLocalization['Adult Male']!,
    };

    Map<String, String> cowBreedMap = {};
    for (var breed in cowBreed) {
      cowBreedMap[breed] = currentLocalization[breed] ?? breed;
    }

    Map<String, String> buffaloBreedMap = {};
    for (var breed in buffaloBreed) {
      buffaloBreedMap[breed] = currentLocalization[breed] ?? breed;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          currentLocalization['new_cattle_group'] ?? "New Cattle Group",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GroupList()),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 26),
                  child: Row(
                    children: [
                      Flexible(
                        child: CattleUtils.buildDropdown(
                          label: '${currentLocalization['Type']}*',
                          value: _selectedType,
                          items: typeMap,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedType = newValue!;
                              _selectedBreed = null;
                              _existingCattleCountController
                                  .text = getExistingCattleCount(
                                _selectedType,
                                _selectedStatus,
                                _selectedBreed,
                              );
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: CattleUtils.buildDropdown(
                          label: '${currentLocalization['select_the_breed']}',
                          value: _selectedBreed,
                          items:
                              _selectedType == 'Cow'
                                  ? cowBreedMap
                                  : buffaloBreedMap,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedBreed = newValue!;
                              _existingCattleCountController
                                  .text = getExistingCattleCount(
                                _selectedType,
                                _selectedStatus,
                                _selectedBreed,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: CattleUtils.buildDropdown(
                    label: '${currentLocalization['status']}*',
                    value: _selectedStatus,
                    items: statusMap,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                        _existingCattleCountController
                            .text = getExistingCattleCount(
                          _selectedType,
                          _selectedStatus,
                          _selectedBreed,
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: CattleUtils.buildReadonlyTextFieldWithController(
                    controller: _existingCattleCountController,
                    label:
                        currentLocalization['Existing Cattle Count'] ??
                        "Existing Cattle Count",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: Text(
                    currentLocalization["want_to_add_more_cattle"] ??
                        'Want to add more cattles to this group?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: CattleUtils.buildTextField(
                    _cattleCountTextController,
                    currentLocalization['enter_cattle_count_to_add'] ??
                        "Enter the number of cattle you wish to add",
                    true,
                    currentLocalization['please_enter_value'] ?? '',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: CattleUtils.buildElevatedButton(
                    currentLocalization['submit'] ?? 'Submit',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedBreed == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  currentLocalization['select_the_breed'] ??
                                      'Select the breed',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          return;
                        }

                        final results = await Future.wait([
                          CattleUtils.getLastUsedGrpId(uid),
                          CattleUtils.getLastUsedRFId(uid),
                        ]);
                        int lastGrpId = results[0];
                        int lastRFId = results[1];

                        String result = await CattleUtils.addCattleGroupToDB(
                          _selectedType,
                          _selectedBreed,
                          _selectedStatus,
                          lastGrpId,
                        );
                        lastGrpId++;

                        String msg = "";
                        if (result == 'Already Exists') {
                          msg = 'cattle_grp_exists';
                        } else {
                          msg = 'new_cattle_grp_added_successfully';
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(currentLocalization[msg] ?? ""),
                            ),
                          );
                        }
                        int newCattleCount = int.parse(
                          _cattleCountTextController.text,
                        );
                        String? gender;
                        gender =
                            (_selectedStatus == 'Calf')
                                ? null
                                : (_selectedStatus == 'Adult Male')
                                ? 'Male'
                                : 'Female';
                        for (int i = 0; i < newCattleCount; i++) {
                          CattleUtils.addNewCattleToDB(
                            _selectedType,
                            _selectedBreed,
                            _selectedStatus,
                            lastRFId,
                            gender,
                          );
                          lastRFId++;
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupList(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
