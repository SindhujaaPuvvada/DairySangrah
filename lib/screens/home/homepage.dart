import 'package:farm_expense_mangement_app/screens/feed/feedpage.dart';
//import 'package:farm_expense_mangement_app/screens/cattle/animallist1.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
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
    return PreferredSize(
      preferredSize: const Size.fromHeight(240),
      child: AppBar(
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      myColor.withValues(alpha: 0.3),
                      myColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(240);
}

class HomePage extends StatefulWidget implements PreferredSizeWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _HomePageState extends State<HomePage> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  @override
  void initState() {
    super.initState();
    setState(() {
      currentLocalization = langFileMap['en']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    currentLocalization = langFileMap[languageCode]!;
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(
              '𝒹𝒶𝒾𝓇𝓎 𝓈𝒶𝓃𝑔𝓇𝒶𝒽',
              style: TextStyle(
                fontSize: 35, // Adjust the size as needed
                fontWeight: FontWeight.bold,
                color:
                    Colors
                        .black87, // You can choose a color that fits your theme
              ),
            ),
            const SizedBox(
              height: 10,
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
                            return const GroupList();
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
                          builder: (context) => const FeedPage(),
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
                          builder:
                              (context) =>
                                  const TransactionPage(showIncome: true),
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
                          builder: (context) => const AvgMilkPage(),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:
            MediaQuery.of(context).size.height *
            0.25, // Keep container size the same
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
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: Image.asset(
                      imageUrl,
                      height: MediaQuery.of(context).size.height * 0.16,
                      width: MediaQuery.of(context).size.width * 0.45,
                      fit:
                          BoxFit
                              .fill, // Ensures the image fits well without overflowing
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
