import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/cattlegroups.dart';
import '../../shared/constants.dart';
import '../wrappers/wrapperhome.dart';
import 'newcattlegroup.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';


  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseServicesForCattleGroups cgrpDB;
  List<CattleGroup> allCattleGrps = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    cgrpDB = DatabaseServicesForCattleGroups(uid!);
    setState(() {
      _fetchCattleGroups();
    });
  }

  Future<void> _fetchCattleGroups() async {
    final snapshot = await cgrpDB.infoFromServerAllCattleGrps(uid);

    setState(() {
      allCattleGrps =
          snapshot.docs
              .map((doc) => CattleGroup.fromFireStore(doc, null))
              .toList();
    });
  }

  Future<void> deleteCattleGroupDatabase(String grpId) async {
    await cgrpDB.deleteCattleGrp(grpId);
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
          currentLocalization['Cattle Groups'] ?? 'Cattle Groups',
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
          labelStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
          // Increased text size
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          tabs: [
            Tab(text: currentLocalization['Cow'] ?? 'Cow'),
            Tab(text: currentLocalization['Buffalo'] ?? 'Buffalo'),

          ],
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          _displayCattleGrpSection('Cow'),
          _displayCattleGrpSection('Buffalo'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewCattleGroup(),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _displayCattleGrpSection(String type) {
    var groups = allCattleGrps.where((grp) => grp.type == type).toList();
    return ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final grp = groups[index];
          var grpName = (grp.breed == 'None')
              ? currentLocalization[grp.state]
              : '${currentLocalization[grp.state]}-${currentLocalization[grp
              .breed] ?? grp.breed}';
          return Container(
            padding: EdgeInsets.all(10.0),
            child: ListTile(
              title: Text(grpName!,
                style: const TextStyle(
                    color: Color(0xFF0DA6BA), fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "${currentLocalization['grpid']}: ${grp
                      .grpId} | ${currentLocalization['cattle_count']}: "
              ),
              tileColor: Color.fromRGBO(177, 243, 238, 0.4),
            ),
          );
        });
  }
}
