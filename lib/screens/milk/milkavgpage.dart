import 'package:farm_expense_mangement_app/models/cattlegroups.dart';
import 'package:farm_expense_mangement_app/screens/milk/milkUtils.dart';
import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/cattle.dart';
import '../../../models/milk.dart';
import '../../../services/database/cattledatabase.dart';
import '../../../services/database/milkdatabase.dart';
import '../../shared/constants.dart';
import '../wrappers/wrapperhome.dart';
import 'milkbydate.dart';
import '../../../main.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';

class AvgMilkPage extends StatefulWidget {
  final bool? fromNotification;
  final String farmId;
  const AvgMilkPage({super.key, this.fromNotification, required this.farmId});

  @override
  State<AvgMilkPage> createState() => _AvgMilkPageState();
}

class _AvgMilkPageState extends State<AvgMilkPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  late DbServicesForMilk db;
  List<Milk> _allMilk = [];
  late DateTime _selectedDate = DateTime.now();
  List<Milk> _originalMilk = [];
  bool _isLoading = true;
  double totalMilkAcrossAllDates = 0.0;

  Future<void> _fetchAllMilk() async {
    final snapshot = await db.infoFromServerAllMilk(widget.farmId);
    setState(() {
      _originalMilk = snapshot.map((r) => Milk.fromDB(r)).toList();
      _allMilk = _originalMilk;
      if (_allMilk.isNotEmpty) {
        totalMilkAcrossAllDates =
            (_originalMilk
                    .map((milk) => milk.morningMilk + milk.eveningMilk)
                    .reduce((a, b) => a + b))
                .toPrecision(2);
      } // Calculate the total milk across all dates
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    db = DbServicesForMilk();
    setState(() {
      _fetchAllMilk();
    });
  }

  void _resetList() {
    setState(() {
      _allMilk = _originalMilk;
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
      _allMilk = _originalMilk
          .where((milk) => milk.milkingDate == selectedDate)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    
    List<DateTime> allMilkDates = _allMilk.map((m)=> m.milkingDate).toSet().toList();

    if (widget.fromNotification != null && widget.fromNotification == true) {
      return AddMilkDataPage(
        farmId: widget.farmId,
        onMilkRecordAdded: () {
          _fetchAllMilk();
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WrapperHomePage()),
          ),
        ),
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
              if (_allMilk.length != _originalMilk.length) {
                _resetList();
              } else {
                _selectDate(context);
              }
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: CircularProgressIndicator()),
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
                  child: allMilkDates.isEmpty
                      ? Center(
                          child: Text(
                            currentLocalization['no_entries_for_sel_date'] ??
                                '',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: allMilkDates.length,
                          itemBuilder: (context, index) {
                            return MilkDataRowByDate(milkingDate: allMilkDates[index], farmId: widget.farmId,);
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
                farmId: widget.farmId,
                onMilkRecordAdded: () {
                  _fetchAllMilk();
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
  final String farmId;

  const AddMilkDataPage({
    super.key,
    required this.farmId,
    this.onMilkRecordAdded,
  });

  @override
  State<AddMilkDataPage> createState() => _AddMilkDataPageState();
}

class _AddMilkDataPageState extends State<AddMilkDataPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  final formKey = GlobalKey<FormState>();

  late DbServicesForMilk db;
  late DbServicesForCattle cattleDb;
  late DbServicesForCattleGroups cgrpDb;

  List<CattleGroup> milkedCattleGrps = [];
  List<Cattle> milkedCattle = [];
  Map<String, String> milkEntryOptsMap = {};
  Map<String, String> milkedGrpIdsMap = {};
  Map<String, String> milkedCattleIdsMap = {};

  Future<void> _fetchCattle() async {
    final snapshot = await cattleDb.infoFromServerAllCattle(widget.farmId);
    final allCattleData = snapshot.map((r) => Cattle.fromDB(r)).toList();
    setState(() {
      var allCattle = allCattleData;
      milkedCattle = allCattle
          .where((cattle) => cattle.state == 'Milked')
          .toList();
      //allMilkedRfIds = milkedRfid.map((cattle) => cattle.rfid).toList();
    });
  }

  Future<void> _fetchCattleGroup() async {
    final snapshot = await cgrpDb.infoFromServerAllCattleGrps(widget.farmId);
    setState(() {
      var allCattleGrps = snapshot.map((r) => CattleGroup.fromDB(r)).toList();
      milkedCattleGrps = allCattleGrps
          .where((cattleGrp) => cattleGrp.state == 'Milked')
          .toList();
      //allMilkedGrpIds = milkedGrpId.map((cattleGrp) => cattleGrp.grpId).toList();
    });
  }

  String selectedEntryType = 'Whole-farm';
  String? selectedId;
  double? milkInMorning;
  double? milkInEvening;
  DateTime? milkingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    db = DbServicesForMilk();
    cattleDb = DbServicesForCattle();
    cgrpDb = DbServicesForCattleGroups();
    _fetchCattleGroup();
    _fetchCattle();
  }

  Future<void> _addMilk(Milk data) async {
    await db.infoToServerMilk(data);
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    currentLocalization = Localization().translations[languageCode] ?? {};

    for (var entryType in milkReportLevels) {
      milkEntryOptsMap[entryType] = currentLocalization[entryType] ?? entryType;
    }

    for (CattleGroup cgrp in milkedCattleGrps) {
      if (cgrp.breed != null) {
        milkedGrpIdsMap[cgrp.grpId.toString()] =
            "${currentLocalization[cgrp.state] ?? cgrp.state}-${currentLocalization[cgrp.breed] ?? cgrp.breed}";
      } else {
        milkedGrpIdsMap[cgrp.grpId.toString()] =
            "${currentLocalization[cgrp.state] ?? cgrp.state}-${currentLocalization[cgrp.type] ?? cgrp.type}";
      }
    }

    for (Cattle cattle in milkedCattle) {
      if (cattle.nickName != null) {
        milkedCattleIdsMap[cattle.cattleId.toString()] =
            "${cattle.cattleId}-${cattle.nickName}";
      } else {
        milkedCattleIdsMap[cattle.cattleId.toString()] = cattle.cattleId
            .toString();
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
                (selectedEntryType != "Whole-farm")
                    ? MilkUtils.buildDropdown(
                        label: (selectedEntryType == 'Group-wise')
                            ? currentLocalization['select_grpid'] ?? ""
                            : currentLocalization['select_rfid'] ?? "",
                        value: selectedId,
                        valMsg: (selectedEntryType == 'Group-wise')
                            ? currentLocalization['please_select_grp_id'] ?? ""
                            : currentLocalization['please_select_rfid'] ?? "",
                        items: selectedEntryType == 'Group-wise'
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
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
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
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
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
                          labelText: currentLocalization['milking_date'] ?? "",
                          labelStyle: const TextStyle(color: Colors.black),
                          suffixIcon: Icon(Icons.calendar_today),
                          border: InputBorder.none,
                        ),
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
                        DateTime now = DateTime.now();
                        final Milk newMilkData = Milk(
                          milkId: '',
                          farmId: widget.farmId,
                          morningMilk: milkInMorning!.toPrecision(2),
                          eveningMilk: milkInEvening!.toPrecision(2),
                          milkingDate: milkingDate!,
                          milkEntryType: selectedEntryType,
                          milkEntryId: selectedEntryType == "Whole-farm" ? "0" : selectedId!,
                          createdAt: now,
                          updatedAt: now,
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
                      child: Text(
                        currentLocalization['add'] ?? "",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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
  final DateTime milkingDate;
  final String farmId;

  const MilkDataRowByDate({super.key, required this.milkingDate, required this.farmId});

  @override
  State<MilkDataRowByDate> createState() => _MilkDataRowByDateState();
}

class _MilkDataRowByDateState extends State<MilkDataRowByDate> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  void viewMilkByDate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilkByDatePage(
          farmId: widget.farmId,
          dateOfMilk: (widget.milkingDate),
        ),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

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
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
              "${currentLocalization['date'] ?? ''}: ${widget.milkingDate.day}-${widget.milkingDate.month}-${widget.milkingDate.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
