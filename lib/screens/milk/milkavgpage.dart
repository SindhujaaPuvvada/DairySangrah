import 'package:farm_expense_mangement_app/models/cattlegroups.dart';
import 'package:farm_expense_mangement_app/screens/milk/milkUtils.dart';
import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/cattle.dart';
import '../../../models/milk.dart';
import '../../../services/database/cattledatabase.dart';
import '../../../services/database/milkdatabase.dart';
import 'milkbydate.dart';
import '../../../main.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';

class AvgMilkPage extends StatefulWidget {
  const AvgMilkPage({super.key});

  @override
  State<AvgMilkPage> createState() => _AvgMilkPageState();
}

class _AvgMilkPageState extends State<AvgMilkPage> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DatabaseForMilkByDate db;
  List<MilkByDate> _allMilkByDate = [];
  late DateTime _selectedDate = DateTime.now();
  List<MilkByDate> _originalMilkByDate = [];
  bool _isLoading = true;
  double totalMilkAcrossAllDates = 0.0;

  Future<void> _fetchAllMilkByDate() async {
    final snapshot = await db.infoFromServerAllMilk();
    setState(() {
      _originalMilkByDate = snapshot.docs
          .map((doc) => MilkByDate.fromFireStore(doc, null))
          .toList();
      _allMilkByDate = _originalMilkByDate;
      if (_allMilkByDate.isNotEmpty) {
        totalMilkAcrossAllDates = (_originalMilkByDate
            .map((milk) => milk.totalMilk)
            .reduce((a, b) => a + b)).toPrecision(2);
      } // Calculate the total milk across all dates
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    db = DatabaseForMilkByDate(uid);
    setState(() {
      _fetchAllMilkByDate();
    });
  }

  void _resetList() {
    setState(() {
      _allMilkByDate = _originalMilkByDate;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _filterMilkByDate(_selectedDate);
    }
  }

  void _filterMilkByDate(DateTime selectedDate) {
    setState(() {
      _allMilkByDate = _originalMilkByDate
          .where((milk) => milk.dateOfMilk == selectedDate)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        title: Center(
          child: Text(
            currentLocalization['milk_records'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            color: Colors.black,
            onPressed: () {
              if (_allMilkByDate.length != _originalMilkByDate.length) {
                _resetList();
              } else {
                _selectDate(context);
              }
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "${currentLocalization['Total Milk'] ?? 'Total Milk'}: $totalMilkAcrossAllDates ${currentLocalization['Litres']}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: _allMilkByDate.isEmpty
                      ? Center(
                          child: Text(
                            currentLocalization['no_entries_for_sel_date'] ??
                                '',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _allMilkByDate.length,
                          itemBuilder: (context, index) {
                            return MilkDataRowByDate(
                              data: _allMilkByDate[index],
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMilkDataPage(
                onMilkRecordAdded: () {
                  _fetchAllMilkByDate();
                },
              ),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddMilkDataPage extends StatefulWidget {
  final VoidCallback? onMilkRecordAdded;

  const AddMilkDataPage({super.key, this.onMilkRecordAdded});

  @override
  State<AddMilkDataPage> createState() => _AddMilkDataPageState();
}

class _AddMilkDataPageState extends State<AddMilkDataPage> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final formKey = GlobalKey<FormState>();

  late DatabaseForMilk db;
  late DatabaseForMilkByDate dbByDate;
  late DatabaseServicesForCattle cattleDb;
  late DatabaseServicesForCattleGroups cgrpDb;

  List<CattleGroup> milkedCattleGrps = [];
  List<Cattle> milkedCattle = [];
  Map<String, String> milkEntryOptsMap = {};
  Map<String, String> milkedGrpIdsMap = {};
  Map<String, String> milkedCattleIdsMap = {};

  Future<void> _fetchCattle() async {
    final snapshot = await cattleDb.infoFromServerAllCattle(uid);
    setState(() {
      var allCattle =
          snapshot.docs.map((doc) => Cattle.fromFireStore(doc, null)).toList();
      milkedCattle =
          allCattle.where((cattle) => cattle.state == 'Milked').toList();
      //allMilkedRfIds = milkedRfid.map((cattle) => cattle.rfid).toList();
    });
  }

  Future<void> _fetchCattleGroup() async {
    final snapshot = await cgrpDb.infoFromServerAllCattleGrps(uid);
    setState(() {
      var allCattleGrps = snapshot.docs
          .map((doc) => CattleGroup.fromFireStore(doc, null))
          .toList();
      milkedCattleGrps = allCattleGrps
          .where((cattleGrp) => cattleGrp.state == 'Milked')
          .toList();
      //allMilkedGrpIds = milkedGrpId.map((cattleGrp) => cattleGrp.grpId).toList();
    });
  }

  String selectedEntryType = 'whole farm';
  String? selectedId;
  double? milkInMorning;
  double? milkInEvening;
  DateTime? milkingDate;

  @override
  void initState() {
    super.initState();
    db = DatabaseForMilk(uid);
    dbByDate = DatabaseForMilkByDate(uid);
    cattleDb = DatabaseServicesForCattle(uid);
    cgrpDb = DatabaseServicesForCattleGroups(uid);
    _fetchCattleGroup();
    _fetchCattle();
  }

  Future<void> _addMilk(Milk data) async {
    await db.infoToServerMilk(data);
    final snapshot = await dbByDate.infoFromServerMilk(data.dateOfMilk!);
    final MilkByDate milkByDate;
    if (snapshot.exists) {
      milkByDate = MilkByDate.fromFireStore(snapshot, null);
    } else {
      milkByDate = MilkByDate(dateOfMilk: data.dateOfMilk);
      await dbByDate.infoToServerMilk(milkByDate);
    }
    final double totalMilk =
        (milkByDate.totalMilk + data.morning + data.evening).toPrecision(2);
    await dbByDate.infoToServerMilk(
        MilkByDate(dateOfMilk: data.dateOfMilk, totalMilk: totalMilk));
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    currentLocalization = langFileMap[languageCode]!;

    for (var entryType in milkEntryTypes) {
      milkEntryOptsMap[entryType] = currentLocalization[entryType] ?? entryType;
    }

    for (CattleGroup cgrp in milkedCattleGrps) {
      if (cgrp.breed != null) {
        milkedGrpIdsMap[cgrp.grpId] =
            "${currentLocalization[cgrp.state] ?? cgrp.state}-${currentLocalization[cgrp.breed] ?? cgrp.breed}";
      } else {
        milkedGrpIdsMap[cgrp.grpId] =
            "${currentLocalization[cgrp.state] ?? cgrp.state}-${currentLocalization[cgrp.type] ?? cgrp.type}";
      }
    }

    for (Cattle cattle in milkedCattle) {

      if (cattle.nickname != null) {
        milkedCattleIdsMap[cattle.rfid] =  "${cattle.rfid}-${cattle.nickname}";
      } else {
        milkedCattleIdsMap[cattle.rfid] = cattle.rfid;
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          currentLocalization['add_milk_data'] ?? "",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                MilkUtils.buildDropdown(
                  label: currentLocalization['milk_entry_type'] ?? "",
                  value: selectedEntryType,
                  items: milkEntryOptsMap,
                  valMsg: "",
                  onChanged: (value) {
                    setState(() {
                      selectedEntryType = value!;
                      selectedId = null;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                (selectedEntryType != "whole farm")
                    ? MilkUtils.buildDropdown(
                        label: (selectedEntryType == 'group wise')
                            ? currentLocalization['select_grpid'] ?? ""
                            : currentLocalization['select_rfid'] ?? "",
                        value: selectedId,
                        valMsg: (selectedEntryType == 'group wise')
                            ? currentLocalization['please_select_grp_id'] ?? ""
                            : currentLocalization['please_select_rfid'] ?? "",
                        items: selectedEntryType == 'group wise'
                            ? milkedGrpIdsMap
                            : milkedCattleIdsMap,
                        onChanged: (value) {
                          setState(() {
                            selectedId = value;
                          });
                        },
                      )
                    : Container(),
                const SizedBox(height: 20.0),
                _buildInputBox(
                  child: TextFormField(
                    onChanged: (value) {
                      milkInMorning = double.tryParse(value);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_enter_value'] ?? "";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: currentLocalization['morning_milk'] ?? "",
                      labelStyle: const TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildInputBox(
                  child: TextFormField(
                    onChanged: (value) {
                      milkInEvening = double.tryParse(value);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_enter_value'] ?? "";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: currentLocalization['evening_milk'] ?? "",
                      labelStyle: const TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildInputBox(
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
                          milkingDate = pickedDate;
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: milkingDate != null
                              ? '${milkingDate!.year}-${milkingDate!.month}-${milkingDate!.day}'
                              : '',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return currentLocalization['please_choose_date'] ??
                                "";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            labelText:
                                currentLocalization['milking_date'] ?? "",
                            labelStyle: const TextStyle(color: Colors.black),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        String idVal;
                        if (selectedEntryType == 'whole farm') {
                          idVal = "WholeFarm";
                        } else {
                          idVal = (selectedEntryType == 'group wise')
                              ? "GPID${selectedId!}"
                              : "RFID${selectedId!}";
                        }
                        final Milk newMilkData = Milk(
                          id: idVal,
                          morning: milkInMorning!.toPrecision(2),
                          evening: milkInEvening!.toPrecision(2),
                          dateOfMilk: milkingDate,
                        );

                        _addMilk(newMilkData).then((_) {
                          if (widget.onMilkRecordAdded != null) {
                            widget.onMilkRecordAdded!();
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        });
                      } else {
                        //Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(currentLocalization['add'] ?? "",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
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

  Widget _buildInputBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
      child: child,
    );
  }
}

class MilkDataRowByDate extends StatefulWidget {
  final MilkByDate data;

  const MilkDataRowByDate({super.key, required this.data});

  @override
  State<MilkDataRowByDate> createState() => _MilkDataRowByDateState();
}

class _MilkDataRowByDateState extends State<MilkDataRowByDate> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';
  void viewMilkByDate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MilkByDatePage(dateOfMilk: (widget.data.dateOfMilk)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return GestureDetector(
      onTap: () {
        viewMilkByDate();
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        color: const Color.fromRGBO(240, 255, 255, 1),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                foregroundDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'asset/milk.jpg',
                  fit: BoxFit.cover,
                  width: 70,
                  height: 200,
                ),
              ),
            ),
            title: Text(
              "${currentLocalization['date'] ?? ''}: ${widget.data.dateOfMilk?.day}-${widget.data.dateOfMilk?.month}-${widget.data.dateOfMilk?.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
