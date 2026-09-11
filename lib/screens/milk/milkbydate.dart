import 'package:farm_expense_mangement_app/screens/milk/milkavgpage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../../models/milk.dart';
import '../../../services/database/milkdatabase.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';

class MilkByDatePage extends StatefulWidget {
  final DateTime? dateOfMilk;
  final String farmId;

  const MilkByDatePage({super.key, required this.farmId, this.dateOfMilk});

  @override
  State<MilkByDatePage> createState() => _MilkByDatePageState();
}

class _MilkByDatePageState extends State<MilkByDatePage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  late DbServicesForMilk db;

  List<Milk> _allMilkInDate = [];
  List<Milk> _filteredMilk = [];

  @override
  void initState() {
    super.initState();
    db = DbServicesForMilk();
    _fetchAllMilk();
  }

  void _deleteAllMilkOnDate() async {
    await db.deleteAllMilkRecordsForDate(widget.farmId, widget.dateOfMilk!);
    if (mounted) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AvgMilkPage(farmId: widget.farmId),
        ),
      );
    }
  }

  Future<void> _fetchAllMilk() async {
    final snapshot = await db.infoFromServerMilk(widget.farmId, widget.dateOfMilk!);
    setState(() {
      _allMilkInDate = snapshot.map((r) => Milk.fromDB(r)).toList();
      _filteredMilk = _allMilkInDate;
    });
  }

  void _searchMilk(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMilk = _allMilkInDate;
      } else {
        _filteredMilk = _allMilkInDate
            .where(
              (milk) => milk.milkEntryId.toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  double _calculateTotalMilk() {
    return _filteredMilk.fold(0, (sum, milk) => sum + milk.morningMilk + milk.eveningMilk);
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        title: Center(
          child: Text(
            currentLocalization['milk_records'] ?? "",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _deleteAllMilkOnDate();
            },
            color: Colors.black,
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            color: Colors.black,
            onPressed: () {
              showSearch(
                context: context,
                delegate: MilkSearchDelegate(
                  allMilk: _allMilkInDate,
                  onSearch: _searchMilk,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AvgMilkPage(farmId: widget.farmId),
              ),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${currentLocalization['date']}: ${widget.dateOfMilk!.day}-${widget.dateOfMilk!.month}-${widget.dateOfMilk!.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${currentLocalization['Total Milk'] ?? 'Total Milk'}: ${_calculateTotalMilk().toStringAsFixed(2)}L',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 16,
            child: ListView.builder(
              itemCount: _filteredMilk.length,
              itemBuilder: (context, index) {
                final data = _filteredMilk[index];
                return MilkDataRow(data: data);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MilkSearchDelegate extends SearchDelegate<String> {
  final List<Milk> allMilk;
  final Function(String) onSearch;

  MilkSearchDelegate({required this.allMilk, required this.onSearch});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromRGBO(13, 166, 186, 1),
      ),
      // Customize the search bar's appearance
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // Set to true to add a background color

        fillColor: const Color.fromRGBO(240, 255, 255, 1),
        hintStyle: const TextStyle(fontSize: 18),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.black), // Border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.black), // Border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.black), // Border color
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black),
        onPressed: () {
          query = '';
          onSearch('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final List<Milk> searchResults = query.isEmpty
        ? allMilk
        : allMilk
              .where(
                (milk) => milk.milkEntryId.toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();

    return Container(
      color: const Color.fromRGBO(
        240,
        255,
        255,
        1,
      ), // Set the background color here
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final data = searchResults[index];
          return MilkDataRow(data: data);
        },
      ),
    );
  }
}

class MilkDataRow extends StatefulWidget {
  final Milk data;

  const MilkDataRow({super.key, required this.data});

  @override
  State<MilkDataRow> createState() => _MilkDataRowState();
}

class _MilkDataRowState extends State<MilkDataRow> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  void editDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMilkByDate(data: widget.data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    currentLocalization = Localization().translations[languageCode] ?? {};

    String id = '';
    String idVal = '';
    final double totalMilk =
        (widget.data.morningMilk + widget.data.eveningMilk)
            .toPrecision(2);

    if (widget.data.milkEntryType == 'Whole-farm') {
      id = 'Whole-farm';
      idVal = '';
    } else {
      idVal = widget.data.milkEntryId.toString();
      if (widget.data.milkEntryType == 'Group-wise') {
        id = 'grpid';
      } else {
        id = 'RF ID';
      }
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      color: const Color.fromRGBO(240, 255, 255, 1),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(color: Colors.white, width: 3),
      ),
      child: Row(
        children: [
          // Left container
          Container(
            //width: 150,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${currentLocalization[id] ?? ""}:\n$idVal",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: false,
                ),
                // const SizedBox(height: 5),
                ClipOval(
                  child: Image.asset(
                    'asset/cow1.jpg',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 65,
                  ),
                ),
              ],
            ),
          ),
          // Right container
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('asset/morning.webp', width: 20, height: 20),
                      const SizedBox(width: 10),
                      Text(
                        "${currentLocalization['morning'] ?? ""}: ${widget.data.morningMilk.toStringAsFixed(2)}L",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset('asset/evening2.jpg', width: 20, height: 20),
                      const SizedBox(width: 10),
                      Text(
                        "${currentLocalization['evening']}: ${widget.data.eveningMilk.toStringAsFixed(2)}L",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Image.asset('asset/milk.jpg', width: 20, height: 20),
                      const SizedBox(width: 10),
                      Text(
                        "${currentLocalization['total']}: ${totalMilk}L",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.black,
            onPressed: () {
              editDetail();
            },
          ),
        ],
      ),
    );
  }
}

class EditMilkByDate extends StatefulWidget {
  final Milk data;

  const EditMilkByDate({super.key, required this.data});

  @override
  State<EditMilkByDate> createState() => _EditMilkByDateState();
}

class _EditMilkByDateState extends State<EditMilkByDate> {
  late DbServicesForMilk db;
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  double? milkInMorning;
  double? milkInEvening;

  @override
  void initState() {
    super.initState();
    db = DbServicesForMilk();
    milkInMorning = widget.data.morningMilk;
    milkInEvening = widget.data.eveningMilk;
  }

  Future<void> _editMilkDetail(String milkId, double morMilkQty, double eveMilkQty) async {
    await db.updateToServerMilkQuantity(milkId, morMilkQty, eveMilkQty);
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    String id = '';
    String idVal = '';

    if (widget.data.milkEntryType == 'Whole-farm') {
      id = 'Whole-farm';
      idVal = '';
    } else {
      idVal = widget.data.milkEntryId.toString();
      if (widget.data.milkEntryType == 'Group-wise') {
        id = 'grpid';
      } else {
        id = 'RF ID';
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          currentLocalization['edit_milk_data'] ?? '',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${currentLocalization[id]} : $idVal",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${currentLocalization['date']} : ${widget.data.milkingDate.day}-${widget.data.milkingDate.month}-${widget.data.milkingDate.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              _buildInputBox(
                labelText: currentLocalization['morning_milk'] ?? "",
                initialValue: milkInMorning.toString(),
                onChanged: (value) {
                  setState(() {
                    milkInMorning = double.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 30.0),
              _buildInputBox(
                labelText: currentLocalization['evening_milk'] ?? "",
                initialValue: milkInEvening.toString(),
                onChanged: (value) {
                  setState(() {
                    milkInEvening = double.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
                  ),
                  onPressed: () async {
                    if (milkInMorning != null && milkInEvening != null) {
                      double newMorMilkQty =
                          milkInMorning!.toPrecision(2);
                      double newEveMilkQty =
                          milkInEvening!.toPrecision(2);
                      await _editMilkDetail(widget.data.milkId, newMorMilkQty, newEveMilkQty);
                      if(context.mounted) {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => const AvgMilkPage()));
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MilkByDatePage(
                                  farmId: widget.data.farmId,
                                  dateOfMilk: widget.data.milkingDate,
                                ),
                          ),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      currentLocalization['Save'] ?? '',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required String labelText,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))],
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
