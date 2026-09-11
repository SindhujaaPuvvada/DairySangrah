import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/screens/notification/alertnotifications.dart';
import 'package:farm_expense_mangement_app/services/breedService.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/database/cattledatabase.dart';
import '../../../main.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';

import 'grouplist.dart';

class AddNewCattle extends StatefulWidget {
  final String farmId;
  final String? type;
  final String? state;
  final String? breed;
  final String? gender;
  final String? source;
  final DateTime? dob;
  final String? motherInfo;
  final String? fatherInfo;
  const AddNewCattle({
    required this.farmId,
    this.type,
    this.state,
    this.breed,
    this.gender,
    this.source,
    this.dob,
    this.motherInfo,
    this.fatherInfo,
    super.key,
  });

  @override
  State<AddNewCattle> createState() => _AddNewCattleState();
}

class _AddNewCattleState extends State<AddNewCattle> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cattleNameTextController =
      TextEditingController();
  final TextEditingController _weightTextController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _fatherInfoTextController =
      TextEditingController();
  final TextEditingController _motherInfoTextController =
      TextEditingController();

  // final TextEditingController _tagNumberController3 = TextEditingController();

  late String? _selectedGender; // Variable to store selected gender
  String? _selectedSource;
  late String? _selectedBreed;
  late String? _selectedState;
  late String? _selectedType;
  String? _selectedIsPregnant;
  DateTime? _birthDate;
  late List<String> cowBreed;
  late List<String> buffaloBreed;
  late String? _selectedMotherId;

  // Variable to store selected gender

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> typeOptions = ['Cow', 'Buffalo'];
  final List<String> pregnantOptions = ['No', 'Yes'];

  final List<String> sourceOptions = [
    'Born on Farm',
    'Purchased',
  ]; // List of gender options
  final List<String> stateOptions = ['Milked', 'Heifer', 'Calf', 'Dry'];

  final List<String> stateOptionsMale = ['Calf', 'Adult Male'];

  late List<String> stateOptionsHolder;

  late final DbServicesForCattle cattleDb;

  List<Cattle> femaleCattle = [];

  Future<void> _fetchCattle() async {
    final snapshot = await cattleDb.infoFromServerAllCattle(widget.farmId);
    final allCattle = snapshot.map((r) => Cattle.fromDB(r)).toList();
    setState(() {
      femaleCattle = allCattle
          .where(
            (cattle) =>
                cattle.sex == 'Female' &&
                cattle.state != 'Calf' &&
                cattle.state != 'Heifer',
          )
          .toList();
    });
  }

  void addNewCattleButton(BuildContext context) async {
    DateTime now = DateTime.now();
    final cattle = Cattle(
      cattleId: '',
      nickName: _cattleNameTextController.text,
      farmId: widget.farmId,
      breed: _selectedBreed!,
      sex: _selectedGender,
      weight: _weightTextController.text.isNotEmpty
          ? double.parse(_weightTextController.text)
          : 0,
      source: _selectedSource != null ? _selectedSource! : 'Born on Farm',
      state: _selectedState != null ? _selectedState! : '',
      type: _selectedType != null ? _selectedType! : ' ',
      reproductiveStatus:
          (_selectedIsPregnant != null && _selectedIsPregnant == 'Yes')
          ? 'Pregnant'
          : 'Open',
      dateOfBirth: _birthDate ?? widget.dob,
      motherInfo: _selectedSource == 'Born on Farm'
          ? _selectedMotherId
          : _motherInfoTextController.text,
      fatherInfo: _fatherInfoTextController.text,
      createdAt: now,
      updatedAt: now,
    );

    await cattleDb.infoToServerSingleCattle(cattle);

    if (cattle.state == "Calf" &&
        cattle.sex == "Female" &&
        cattle.dateOfBirth != null) {
      AlertNotifications alert = AlertNotifications();
      alert.createCalfNotifications(cattle);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentLocalization['new_cattle_added_successfully'] ?? "",
          ),
        ),
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupList(farmId: widget.farmId),
        ),
      );
    } else {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    cowBreed = BreedService().cowBreeds;
    buffaloBreed = BreedService().buffaloBreeds;
    cattleDb = DbServicesForCattle();
    setState(() {
      _fetchCattle();
      _selectedType = widget.type;
      _selectedState = widget.state;
      _selectedBreed = widget.breed;
      _selectedGender = widget.gender;
      _selectedSource = widget.source;
      _birthDateController.text = widget.dob != null
          ? '${widget.dob?.year}-${widget.dob?.month}-${widget.dob?.day}'
          : '';
      stateOptionsHolder = (_selectedGender == 'Female')
          ? stateOptions
          : stateOptionsMale;
      _selectedMotherId = widget.motherInfo;
      _fatherInfoTextController.text = widget.fatherInfo ?? '';
    });
  }

  @override
  void dispose() {
    _cattleNameTextController.dispose();
    _birthDateController.dispose();
    _weightTextController.dispose();
    _fatherInfoTextController.dispose();
    _motherInfoTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    final motherCattleList = femaleCattle
        .where((c) => c.type == _selectedType)
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          currentLocalization['new_cattle'] ?? "",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupList(farmId: widget.farmId),
              ),
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
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: TextFormField(
                    controller: _cattleNameTextController,
                    decoration: InputDecoration(
                      labelText:
                          '${currentLocalization['enter_the_cattle_name'] ?? ""}*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_enter_tag_num'] ??
                            '';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: '${currentLocalization['Type'] ?? ""}*',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items: typeOptions.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(currentLocalization[type] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedBreed = null;
                        setState(() {});
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_select_cattle_type'] ??
                            '';
                      }
                      return null;
                    },
                  ),
                ),
                // SizedBox(height: 0.00008),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      labelText: '${currentLocalization['gender'] ?? ""}*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items: genderOptions.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(
                          currentLocalization[gender.toLowerCase()] ?? "",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _selectedState = 'Calf';
                        stateOptionsHolder = (_selectedGender == 'Female')
                            ? stateOptions
                            : stateOptionsMale;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_select_gender'] ??
                            '';
                      }
                      return null;
                    },
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthDate = pickedDate;
                          _birthDateController.text =
                              '${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}';
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: _birthDateController,
                        decoration: InputDecoration(
                          labelText:
                              '${currentLocalization['enter_the_DOB'] ?? ""}*',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return currentLocalization['please_choose_date'];
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    // initialValue: '0',
                    controller: _weightTextController,
                    decoration: InputDecoration(
                      labelText: currentLocalization['enter_the_weight'] ?? "",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSource,
                    decoration: InputDecoration(
                      labelText: currentLocalization['source_of_cattle'] ?? "",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items: sourceOptions.map((String source) {
                      return DropdownMenuItem<String>(
                        value: source,
                        child: Text(
                          currentLocalization[source.toLowerCase()] ?? "",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSource = value;
                        setState(() {});
                      });
                    },
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedBreed,
                    decoration: InputDecoration(
                      labelText:
                          currentLocalization['select_the_breed'] ??
                          ""
                              '*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items: (_selectedType == 'Cow')
                        ? cowBreed.map((String breed) {
                            return DropdownMenuItem<String>(
                              value: breed,
                              child: Text(
                                currentLocalization[breed] ?? 'breed',
                              ),
                            );
                          }).toList()
                        : buffaloBreed.map((String breed) {
                            return DropdownMenuItem<String>(
                              value: breed,
                              child: Text(
                                currentLocalization[breed] ?? 'breed',
                              ),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBreed = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    decoration: InputDecoration(
                      labelText: "${currentLocalization['status'] ?? ''}*",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items: stateOptionsHolder.map((String stage) {
                      return DropdownMenuItem<String>(
                        value: stage,
                        child: Text(currentLocalization[stage] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value == 'select') {
                        return currentLocalization['please_select_status'];
                      }
                      return null;
                    },
                  ),
                ),
                if (_selectedSource == 'Born on Farm') ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedMotherId,
                      decoration: InputDecoration(
                        labelText:
                            currentLocalization['enter_mother_info'] ?? "",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                      ),
                      items: motherCattleList.map((Cattle ct) {
                        return DropdownMenuItem<String>(
                          value: ct.cattleId,
                          child: Text(ct.nickName ?? ct.cattleId),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMotherId = value;
                        });
                      },
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                    child: TextFormField(
                      controller: _motherInfoTextController,
                      decoration: InputDecoration(
                        labelText:
                            currentLocalization['enter_mother_info'] ?? "",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: TextFormField(
                    controller: _fatherInfoTextController,
                    decoration: InputDecoration(
                      labelText: currentLocalization['enter_father_info'] ?? "",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                  ),
                ),
                (_selectedGender == 'Female')
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedIsPregnant,
                          decoration: InputDecoration(
                            labelText: currentLocalization['isPregnant'] ?? "",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                          ),
                          items: pregnantOptions.map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(
                                currentLocalization[val.toLowerCase()] ?? "",
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIsPregnant = value;
                            });
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                        child: DropdownButtonFormField<String>(
                          items: [],
                          onChanged: null,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process the data
                          // For example, save it to a database or send it to an API
                          addNewCattleButton(context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color.fromRGBO(13, 166, 186, 1.0),
                        ),
                      ),
                      child: Text(
                        currentLocalization['submit'] ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
