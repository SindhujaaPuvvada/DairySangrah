import 'package:farm_expense_mangement_app/screens/cattle/animallist2.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_expense_mangement_app/models/cattle.dart';
import 'package:farm_expense_mangement_app/screens/cattle/newcattle.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';

class AnimalList1 extends StatefulWidget {
  const AnimalList1({super.key});

  @override
  _AnimalList1State createState() => _AnimalList1State();
}

class _AnimalList1State extends State<AnimalList1> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DatabaseServicesForCattle cattleDb;
  int CalfCount = 0;
  int dryCount = 0;
  int milkedCount = 0;
  int heiferCount = 0;
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    cattleDb = DatabaseServicesForCattle(uid!);
    setState(() {
      _fetchCounts('Cow');
    });
     // Fetch counts for cows initially
  }

  void _fetchCounts(String type) async {
    final snapshot = await cattleDb.infoFromServerAllCattle(FirebaseAuth.instance.currentUser!.uid);
    final allCattle = snapshot.docs.map((doc) => Cattle.fromFireStore(doc, null)).toList();

    setState(() {
      CalfCount = allCattle.where((cattle) => cattle.type == type && cattle.state == 'Calf').length;
      dryCount = allCattle.where((cattle) => cattle.type == type && cattle.state == 'Dry').length;
      milkedCount = allCattle.where((cattle) => cattle.type == type && cattle.state == 'Milked').length;
      heiferCount = allCattle.where((cattle) => cattle.type == type && cattle.state == 'Heifer').length;
    });
  }


  @override
  Widget build(BuildContext context) {
    languageCode = Provider
        .of<AppData>(context)
        .persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () =>
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => const WrapperHomePage())
                )),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          currentLocalization['Animals'] ?? 'Animals',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Increased text size
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          tabs:  [
            Tab(text: currentLocalization['Cow'] ?? 'Cow'),
            Tab(text: currentLocalization['Buffalo'] ?? 'Buffalo'),

          ],
          onTap: (index) {
            if (index == 0) {
              setState(() {
                _fetchCounts('Cow');
              });
            } else {
              setState(() {
                _fetchCounts('Buffalo');

              });
            }
          },
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          _buildCattleSection('Cow'),
          _buildCattleSection('Buffalo'),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewCattle(),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCattleSection(String type) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(10),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [_buildSectionCard('Calf', CalfCount, type),
        _buildSectionCard('Dry', dryCount, type),
        _buildSectionCard('Milked', milkedCount, type),
        _buildSectionCard('Heifer', heiferCount, type),

      ],
    );
  }

  Widget _buildSectionCard(String section, int count, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimalList2(animalType: type, section: section),
          ),
        );
      },

      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white
          ),
          child: Column(
            children: [
              // Section name container with white background at the top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color:  Color.fromRGBO(13, 166, 186, 0.9),// White background for section name
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  currentLocalization[section] ?? section,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

              ),

              // Spacer for middle section
              SizedBox(height: 25),

              // Total count in the middle with different background color
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  '${currentLocalization['Total Count'] ?? 'Total Count'}: $count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );

  }
}
