import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/screens/cattle/animaldetails.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';

class AnimalList2 extends StatefulWidget {
  final String animalType;
  final String section;
  final String? breed;

  const AnimalList2(
      {required this.animalType, required this.section, this.breed, super.key});

  @override
  State<AnimalList2> createState() => _AnimalList2State();
}

class _AnimalList2State extends State<AnimalList2> {
  late DatabaseServicesForCattle cattleDb;
  late List<Cattle> allCattle = [];
  List<Cattle> filteredCattle = [];
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBreed; // Store the selected breed for filtering
  List<String> breedList = [];

  @override
  void initState() {
    super.initState();
    _selectedBreed = widget.breed;
    if (widget.animalType == 'Cow') {
      for (String breed in cowBreed) {
        if (breed == 'select') {
          breedList.add('All');
        } else {
          breedList.add(breed);
        }
      }
    } else {
      for (String breed in buffaloBreed) {
        if (breed == 'select') {
          breedList.add('All');
        } else {
          breedList.add(breed);
        }
      }
    }
    cattleDb =
        DatabaseServicesForCattle(FirebaseAuth.instance.currentUser!.uid);
    _fetchCattle();
    _searchController.addListener(_searchCattle);
  }

  Future<void> _fetchCattle() async {
    final snapshot = await cattleDb
        .infoFromServerAllCattle(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      allCattle =
          snapshot.docs.map((doc) => Cattle.fromFireStore(doc, null)).toList();
      //print(widget.animalType);
      // print(widget.section);
      _filterCattle();
    });
  }

  void _filterCattle() {
    setState(() {
      filteredCattle = allCattle.where((cattle) {
        //print(cattle.type);
        //print(cattle.state);
        if (widget.animalType == 'Cow' && cattle.type != 'Cow') return false;
        if (widget.animalType == 'Buffalo' && cattle.type != 'Buffalo') {
          return false;
        }
        if (cattle.state != widget.section) return false;
        if (_selectedBreed != null &&
            _selectedBreed != 'All' &&
            cattle.breed?.toLowerCase() != _selectedBreed?.toLowerCase()) {
          return false; // Filter by breed
        }
        return true;
      }).toList();
      _searchCattle(); // Apply search filter after breed filter
    });
    //print(filteredCattle);
  }

  void _viewCattleDetail(Cattle cattle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalDetails(rfid: cattle.rfid),
      ),
    );
  }

  void _searchCattle() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredCattle = filteredCattle.where((cattle) {
        if (_selectedBreed != null &&
            _selectedBreed != 'All' &&
            cattle.breed?.toLowerCase() != _selectedBreed?.toLowerCase()) {
          return false; // Apply breed filter
        }
        return cattle.rfid
            .toLowerCase()
            .contains(query); // Search functionality
      }).toList();
    });
  }

  void _filterByBreed(String? breed) {
    setState(() {
      _selectedBreed = breed;
      _filterCattle();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterCattle(); // Apply breed filter after clearing search
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          '${currentLocalization[widget.animalType] ?? widget.animalType} - ${currentLocalization[widget.section] ?? widget.section}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          textAlign: TextAlign.start,
        ),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Filter Dropdown on AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedBreed,
              hint: Text(
                _selectedBreed ?? currentLocalization['all'] ?? 'All',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              onChanged: (String? newValue) {
                _filterByBreed(newValue);
              },
              items: breedList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      currentLocalization[value.toLowerCase()] ?? value,
                      style: TextStyle(
                        color: _selectedBreed == value
                            ? Colors.black
                            : Colors.black,
                        fontWeight: _selectedBreed == value
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ));
              }).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with reduced height and border
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: currentLocalization['Search Cattle'] ??
                          'Search Cattle',
                      hintText:
                          currentLocalization['RF ID'] ?? 'Filter by Cattle ID',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10), // Reduced height
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black38, width: 1), // Border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.black38, width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      _filterCattle();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ],
            ),
          ),
          // Cattle List
          Expanded(
            child: ListView.builder(
              itemCount: filteredCattle.length,
              itemBuilder: (context, index) {
                final cattleInfo = filteredCattle[index];
                return GestureDetector(
                  onTap: () => _viewCattleDetail(cattleInfo),
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(5),
                            child: //cattleInfo.sex == 'Female'?
                            Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 1, 0, 1),
                                    foregroundDecoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Color.fromRGBO(2, 48, 32, 1.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      'asset/${cattleInfo.state}.png',
                                      fit: BoxFit.contain,
                                      width: 70,
                                      height: 70,
                                    ),
                                  )
                             /*   : Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 1, 0, 1),
                                    foregroundDecoration: const BoxDecoration(
                                        shape: BoxShape.circle),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      'asset/Bull1.jpg',
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 150,
                                    ),
                                  ),*/
                          ),
                          title: Text(
                            "${currentLocalization['RF ID'] ?? 'Cattle ID'}: ${cattleInfo.rfid}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${currentLocalization['breed'] ?? 'Breed'}: ${currentLocalization[cattleInfo.breed?.toLowerCase()] ?? ''}"),
                              Text(
                                  "${currentLocalization['sex'] ?? 'Sex'}: ${currentLocalization[cattleInfo.sex?.toLowerCase()] ?? ''}"),
                            ],
                          ),
                          trailing: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   (cattleInfo.nickname != null) ?
                                   Text(currentLocalization['cattle_name'] ??
                                       'Name'): Text(""),
                                   Text(
                                     cattleInfo.nickname ?? '',
                                     style: const TextStyle(
                                         color: Colors.black, fontSize: 16),
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
    );
  }
}
