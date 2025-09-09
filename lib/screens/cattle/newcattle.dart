import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/screens/cattle/animallist1.dart';
import 'package:farm_expense_mangement_app/screens/notification/alertnotifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/database/cattledatabase.dart';
import '../../../main.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';

class AddNewCattle extends StatefulWidget {
  const AddNewCattle({super.key});

  @override
  State<AddNewCattle> createState() => _AddNewCattleState();
}

class _AddNewCattleState extends State<AddNewCattle> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rfidTextController = TextEditingController();
  final TextEditingController _weightTextController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // final TextEditingController _tagNumberController3 = TextEditingController();

  String? _selectedGender; // Variable to store selected gender
  String? _selectedSource;
  String? _selectedBreed;
  String? _selectedState;
  String? _selectedType;
  String? _selectedIsPregnant;
  DateTime? _birthDate;


  // Variable to store selected gender

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> typeOptions = ['Cow', 'Buffalo'];
  final List<String> pregnantOptions = ['No','Yes'];

  final List<String> sourceOptions = [
    'Born on Farm',
    'Purchased'
  ]; // List of gender options
  final List<String> stateOptions = [
    'Milked',
    'Heifer',
    'Calf',
    'Dry',
  ];

  final List<String> stateOptionsMale = [
    'Calf',
    'Male',
  ];

  late List<String> stateOptionsHolder;
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late final DatabaseServicesForCattle cattleDb;

  void addNewCattleButton(BuildContext context) async {
    final cattle = Cattle(
        rfid: _rfidTextController.text,
        breed: _selectedBreed!,
        sex: _selectedGender != null ? _selectedGender! : '',
        weight: _weightTextController.text.isNotEmpty
            ? int.parse(_weightTextController.text)
            : 0,
        source: _selectedSource != null ? _selectedSource! : '',
        state: _selectedState != null ? _selectedState! : '',
        type: _selectedType != null ? _selectedType! : ' ',
        isPregnant: (_selectedIsPregnant != null &&
            _selectedIsPregnant == 'Yes')
            ? true : false,
        dateOfBirth: _birthDate!
    );
    bool exists = await cattleDb.checkIfRFIDExists(cattle.rfid);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentLocalization['rfid_already_exists']??'')),
      );
      return;
    }

    // print(_selectedType);
    await cattleDb.infoToServerSingleCattle(cattle);
    if (cattle.state == "Calf" && cattle.sex == "Female" && cattle.dateOfBirth != null) {
      AlertNotifications alert = AlertNotifications();
      alert.createCalfNotifications(cattle);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              currentLocalization['new_cattle_added_successfully'] ?? "")),
    );

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AnimalList1()
        )
    );
  }

  @override
  void initState() {
    super.initState();

    cattleDb = DatabaseServicesForCattle(uid);
    setState(() {
      stateOptionsHolder = stateOptions;
    });
  }

  @override
  void dispose() {
    _rfidTextController.dispose();
    _birthDateController.dispose();
    _weightTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider
        .of<AppData>(context)
        .persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
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
            Navigator.pop(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AnimalList1()));
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Form(
            key: _formKey,
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                child: TextFormField(
                  controller: _rfidTextController,
                  decoration: InputDecoration(
                    labelText: '${currentLocalization['enter_the_rfid'] ??
                        ""}*',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return currentLocalization['please_enter_tag_num']??'';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
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
                      _selectedType = value;
                      _selectedBreed=null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return currentLocalization['please_select_cattle_type']??'';
                    }
                    return null;
                  },
                ),
              ),
              // SizedBox(height: 0.00008),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
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
                          currentLocalization[gender.toLowerCase()]??""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                      _selectedState=null;
                      stateOptionsHolder = (_selectedGender == 'Female') ? stateOptions : stateOptionsMale;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return currentLocalization['please_select_gender']??'';
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
                        '${_birthDate!.year}-${_birthDate!.month}-${_birthDate!
                            .day}';
                      });
                    }
                  },
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      controller: _birthDateController,
                      decoration: InputDecoration(
                        labelText: '${currentLocalization['enter_the_DOB'] ??
                            ""}*',
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
                    labelText: '${currentLocalization['enter_the_weight'] ??
                        ""}*',
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
                    value: _selectedSource,
                    decoration: InputDecoration(
                      labelText: '${currentLocalization['source_of_cattle'] ??
                          ""}*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items: sourceOptions.map((String source) {
                      return DropdownMenuItem<String>(
                        value: source,
                        child: Text(currentLocalization[source.toLowerCase()] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSource = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_select_source']??'';
                      }
                      return null;
                    }),
              ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                child: DropdownButtonFormField<String>(
                  value: _selectedBreed,
                  decoration: InputDecoration(
                    labelText: currentLocalization['select_the_breed']??""'*',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                  ),
                  items: (_selectedType == 'Cow') ? cowBreed.map((String breed) {
                    return DropdownMenuItem<String>(
                      value: breed,
                      child: Text(currentLocalization[breed]??'breed'),
                    );
                  }).toList()
                  :  buffaloBreed.map((String breed) {
                    return DropdownMenuItem<String>(
                      value: breed,
                      child: Text(currentLocalization[breed]??'breed'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return currentLocalization['please_select_breed'];
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                child: DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: InputDecoration(
                    labelText: currentLocalization['status'] ?? "",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                  ),
                  items: stateOptionsHolder.map((String stage) {
                    return DropdownMenuItem<String>(
                      value: stage,
                      child: Text(
                          currentLocalization[stage] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                ),
              ),
              (_selectedGender == 'Female') ?
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                child: DropdownButtonFormField<String>(
                  value: _selectedIsPregnant,
                  decoration: InputDecoration(
                    labelText: currentLocalization['isPregnant'] ?? "",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                  ),
                  items: pregnantOptions.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(currentLocalization[val.toLowerCase()] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIsPregnant = value;
                    });
                  },
                ),
              ) : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: DropdownButtonFormField<String>(
                    items: [],
                    onChanged: null,
                  )),
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
                          const Color.fromRGBO(13, 166, 186, 1.0)),
                    ),
                    child: Text(
                      currentLocalization['submit'] ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
