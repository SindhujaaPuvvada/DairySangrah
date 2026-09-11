import 'package:farm_expense_mangement_app/models/dairyfarm.dart';
import 'package:farm_expense_mangement_app/screens/feed/feedpage.dart';
import 'package:farm_expense_mangement_app/services/database/dairyfarmDatabase.dart';
//import 'package:farm_expense_mangement_app/screens/cattle/animallist1.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../cattle/grouplist.dart';
import '../milk/milkavgpage.dart';
import '../transaction/transactionpage.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  final Color myColor = const Color(0xFF39445A);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        child: Stack(
          children: [
            Image.asset(
              'asset/bg.png',
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(130);
}

class HomePage extends StatefulWidget implements PreferredSizeWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  late String farmId;
  List<DairyFarm> farmsList = [];
  List<Map<String, dynamic>> cattleDashboardValues = [];
  List<Map<String, dynamic>> feedDashboardValues = [];
  List<Map<String, dynamic>> milkDashboardValues = [];
  List<Map<String, dynamic>> transactionDashboardValues = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _getAllFarms();
      currentLocalization = Localization().translations['en'] ?? {};
      _fetch_dashboard_values();
    });
  }

  Future<void> _getAllFarms() async {
    final uid = SupabaseService.client.auth.currentUser!.id;
    var farms = await DbServicesForDairyFarm().infoFromServerAllFarms(uid);
    setState(() {
      farmsList = farms;
    });
  }

  Future<void> _fetch_dashboard_values() async {
    farmId = Provider.of<AppData>(context, listen: false).farmId;
    var values = await DbServicesForDairyFarm().getDashboardValues(farmId);
    var cattleList = values.where((r) => r['type'] == 'cattle').toList();
    var feedList = values.where((r) => r['type'] == 'feed').toList();
    var milkList = values.where((r) => r['type'] == 'milk').toList();
    var transList = values
        .where((r) => (r['type'] == 'income' || r['type'] == 'expenses'))
        .toList();
    setState(() {
      cattleDashboardValues = cattleList;
      feedDashboardValues = feedList;
      milkDashboardValues = milkList;
      transactionDashboardValues = transList;
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    currentLocalization = Localization().translations[languageCode] ?? {};
    farmId = Provider.of<AppData>(context).farmId;
    //String appMode = Provider.of<AppData>(context).appMode;
    Color totalCowsColor = const Color.fromRGBO(
      224,
      191,
      184,
      1.0,
    ); // Green color
    Color milkingCowsColor = const Color.fromRGBO(
      252,
      222,
      172,
      1.0,
    ); // Red color
    Color dryCowsColor = const Color.fromRGBO(88, 148, 120, 1.0); // Blue color
    Color avgMilkPerCowColor = const Color.fromRGBO(
      202,
      217,
      173,
      1.0,
    ); // Yellow color
    return Placeholder(
      strokeWidth: 0,
      color: Colors.white70,
      child: Container(
        height: 600,
        color: Colors.grey[300],
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
        child: Column(
          children: <Widget>[
            Text(
              '𝒹𝒶𝒾𝓇𝓎 𝓈𝒶𝓃𝑔𝓇𝒶𝒽',
              style: TextStyle(
                fontSize: 25, // Adjust the size as needed
                fontWeight: FontWeight.bold,
                color: Colors
                    .black87, // You can choose a color that fits your theme
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              elevation: 2,
              initialValue: farmId,
              decoration: InputDecoration(
                labelText: currentLocalization['My Farms'],
                labelStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 255, 255, 1),
              ),
              items: farmsList.map((farm) {
                return DropdownMenuItem<String>(
                  value: farm.farmId,
                  child: Text(farm.farmName),
                );
              }).toList(),
              onChanged: (val) {
                Provider.of<AppData>(context, listen: false).farmId = val!;
                farmId = val;
                _fetch_dashboard_values();
                setState(() {});
              },
            ),
            const SizedBox(
              height: 15,
            ), // Space between the text and the content
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: buildClickableContainer(
                      context,
                      'cattle',
                      'asset/cat.png',
                      totalCowsColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            //if (appMode == 'CGM') {
                            return GroupList(farmId: farmId);
                            /*} else {
                          return const AnimalList1();
                        }*/
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildClickableContainer(
                      context,
                      'Inventory',
                      'asset/inventory.png',
                      milkingCowsColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedPage(farmId: farmId),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: buildClickableContainer(
                      context,
                      'transaction',
                      'asset/transact_1.png',
                      dryCowsColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionPage(farmId: farmId, showIncome: true),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildClickableContainer(
                      context,
                      'Milk Details',
                      'asset/milk.png',
                      avgMilkPerCowColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvgMilkPage(farmId: farmId),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildClickableContainer(
    BuildContext context,
    String value,
    String imageUrl,
    Color containerColor,
    Function() onTap,
  ) {
    List<Map<String, dynamic>> valuesToDisplay = [];
    switch (value) {
      case 'cattle':
        valuesToDisplay = cattleDashboardValues;
        break;
      case 'Inventory':
        valuesToDisplay = feedDashboardValues;
        break;
      case 'Milk Details':
        valuesToDisplay = milkDashboardValues;
        break;
      case 'transaction':
        valuesToDisplay = transactionDashboardValues;
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:
            MediaQuery.of(context).size.height *
            0.30, // Keep container size the same
        decoration: BoxDecoration(
          color: const Color.fromRGBO(4, 142, 161, 1.0),
          border: Border.all(color: Colors.indigo.shade300, width: 3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: containerColor.withValues(alpha: 0.5),
              spreadRadius: 4,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Text(
                currentLocalization[value] ?? value,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(13, 166, 186, 1),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(imageUrl),
                      fit: BoxFit.fill),
                      color: Colors.white70,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: valuesToDisplay.length,
                      itemBuilder: (context, index) {
                        String subType = '';
                        String typeValue = '';
                        switch (value) {
                          case 'cattle':
                            subType =
                                currentLocalization[valuesToDisplay[index]['sub_type']
                                    .toLowerCase()];
                            typeValue = valuesToDisplay[index]['value']
                                .toString();
                            break;
                          case 'Inventory':
                            var fcName = valuesToDisplay[index]['sub_type']
                                .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
                            subType = currentLocalization[fcName];
                            typeValue =
                                "${valuesToDisplay[index]['value']} ${currentLocalization['Kg']}";
                            break;
                          case 'Milk Details':
                            subType =
                                currentLocalization[valuesToDisplay[index]['sub_type']] ??
                                'Today';
                            typeValue =
                                "${valuesToDisplay[index]['value']} ${currentLocalization['Litres']}";
                            break;
                          case 'transaction':
                            subType =
                                "${currentLocalization[valuesToDisplay[index]['sub_type']] ?? 'This month'} ${currentLocalization[valuesToDisplay[index]['type']]}";
                            typeValue =
                                "${currentLocalization['rupees']} ${valuesToDisplay[index]['value']}";
                            break;
                        }
                        return Column(
                          children: [
                            SizedBox(height: 5),
                            Text(
                              subType,
                              style: TextStyle(
                                color: Color.fromRGBO(165, 42, 42, 1),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              typeValue,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
