import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';
import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/cattle.dart';
import '../../models/cattlegroups.dart';
import '../../services/database/cattledatabase.dart';
import '../../shared/constants.dart';
import '../wrappers/wrapperhome.dart';
import 'animallist2.dart';
import 'newcattle.dart';
import 'newcattlegroup.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseServicesForCattleGroups cgrpDB;
  late DatabaseServicesForCattle cattleDB;
  late DatabaseServicesForUser userDB;
  bool showActionButton = true;
  List<CattleGroup> allCattleGrps = [];
  List<Cattle> allCattle = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    cgrpDB = DatabaseServicesForCattleGroups(uid!);
    cattleDB = DatabaseServicesForCattle(uid);
    userDB = DatabaseServicesForUser(uid);
    _showFloatingActionButton();
    _fetchCattleGroups();
    _fetchCattle();
  }

  Future<void> _showFloatingActionButton() async {
    String appMode = await userDB.getAppMode(uid);
    setState(() {
      showActionButton = (appMode == 'GBW') ? true : false;
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

  Future<void> _fetchCattle() async {
    final snapshot = await cattleDB.infoFromServerAllCattle(
      FirebaseAuth.instance.currentUser!.uid,
    );
    setState(() {
      allCattle =
          snapshot.docs.map((doc) => Cattle.fromFireStore(doc, null)).toList();
    });
  }

  String fetchCattleCount(String type, String state, String? breed) {
    int count;
    if (breed != 'select' && breed != null && state != '') {
      count =
          allCattle
              .where(
                (cattle) =>
                    cattle.type == type &&
                    cattle.state == state &&
                    cattle.breed == breed,
              )
              .length;
    } else {
      if (state != '') {
        count =
            allCattle
                .where((cattle) => cattle.type == type && cattle.state == state)
                .length;
      } else {
        count = allCattle.where((cattle) => cattle.type == type).length;
      }
    }

    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WrapperHomePage(),
                ),
              ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          currentLocalization['Cattle Groups'] ?? 'Cattle Groups',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
      floatingActionButton:
          (showActionButton)
              ? FloatingActionButton(
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
              )
              : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _displayCattleGrpSection(String type) {
    var groups = allCattleGrps.where((grp) => grp.type == type).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${currentLocalization['total_cattle']}: ${fetchCattleCount(type, '', '')}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${currentLocalization['total_groups']}: ${groups.length}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final grp = groups[index];
              var grpName =
                  (grp.breed == null)
                      ? currentLocalization[grp.state]
                      : '${currentLocalization[grp.state]}-${currentLocalization[grp.breed] ?? grp.breed}';
              String cattleCount = fetchCattleCount(
                grp.type,
                grp.state,
                grp.breed,
              );
              return Container(
                padding: EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AnimalList2(
                              animalType: type,
                              section: grp.state,
                              breed: grp.breed,
                            ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      grpName!,
                      style: const TextStyle(
                        color: Color(0xFF0DA6BA),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${currentLocalization['grpid']}: ${grp.grpId}\n${currentLocalization['cattle_count']}: $cattleCount",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    tileColor: Color.fromRGBO(177, 243, 238, 0.4),
                    leading: Container(
                      margin: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                      foregroundDecoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        'asset/${grp.state}.png',
                        fit: BoxFit.contain,
                        width: 70,
                        height: 150,
                      ),
                    ),
                    trailing: Tooltip(
                      message: currentLocalization['add_new_cattle'],
                      preferBelow: true,
                      textAlign: TextAlign.right,
                      textStyle: TextStyle(
                        color: Color.fromRGBO(13, 166, 186, 1.0),
                        fontStyle: FontStyle.italic,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54,strokeAlign: BorderSide.strokeAlignInside),
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(3.5)
                        ),
                        child: IconButton(
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add_circle),
                          color: Color.fromRGBO(13, 166, 186, 0.8),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddNewCattle(
                                      type: grp.type,
                                      state: grp.state,
                                      breed: grp.breed,
                                      gender:
                                          (grp.state != 'Calf')
                                              ? (grp.state != 'Adult Male')
                                                  ? 'Female'
                                                  : 'Male'
                                              : null,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
