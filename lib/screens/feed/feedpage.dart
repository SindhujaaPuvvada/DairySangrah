import 'package:farm_expense_mangement_app/models/inventory.dart';
import 'package:farm_expense_mangement_app/services/database/feeddatabase.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../wrappers/wrapperhome.dart';
import 'dryFodder.dart';
import 'greenFodder.dart';
import 'concentrate.dart';

class FeedPage extends StatefulWidget {
  final String farmId;
  const FeedPage({super.key, required this.farmId});

  @override
  State<FeedPage> createState() => _FeedState();
}

class _FeedState extends State<FeedPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  late DbServicesForFeed fdDB;

  late String selectedSection = 'Green Fodder'; // Default section

  bool _showCheckboxes = false;

  List<String> selectedEntries = [];

  @override
  void initState() {
    fdDB = DbServicesForFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WrapperHomePage()),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          currentLocalization['Inventory'] ?? "",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
        actions: _showCheckboxes
            ? <Widget>[
                IconButton(
                  onPressed: () {
                    _deleteInvEntries();
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                ),
              ]
            : <Widget>[], // AppBar color
      ),
      body: Column(
        children: [
          // The Row for the three sections
          Row(
            children: [
              Expanded(child: sectionButton('Green Fodder')),
              Expanded(child: sectionButton('Dry Fodder')),
              Expanded(child: sectionButton('Concentrate')),
            ],
          ),
          const SizedBox(height: 20),
          // Display content based on the selected section
          Expanded(child: displaySelectedSectionContent(farmId: widget.farmId)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedSection == 'Dry Fodder') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DryFodderPage(farmId: widget.farmId),
              ),
            );
          }
          if (selectedSection == 'Green Fodder') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GreenFodderPage(farmId: widget.farmId),
              ),
            );
          }
          if (selectedSection == 'Concentrate') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConcentratePage(farmId: widget.farmId),
              ),
            );
          }
        },
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
        // Same as AppBar color
        child: const Icon(
          Icons.add,
          color: Colors.black, // Icon color
          size: 30, // Icon size
        ),
      ),
    );
  }

  // Method to display the content based on the selected section
  Widget displaySelectedSectionContent({required String farmId}) {
    final sectionType = selectedSection.replaceAll(' ', '');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fdDB.infoFromServerForCategory(sectionType, farmId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(currentLocalization['out_of_stock'] ?? ''));
        }
        final items = snapshot.data!.map((r) => Inventory.fromDB(r)).toList();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            final DateTime fdDate = item.invDate;
            final String sFdDate =
                '${fdDate.day}-${fdDate.month}-${fdDate.year}';

            return Container(
              padding: EdgeInsets.all(10.0),
              child: ListTile(
                title: Text(
                  currentLocalization[item.feedName] ?? item.feedName,
                  style: TextStyle(
                    color: const Color(0xFF0DA6BA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${currentLocalization['quantity'] ?? 'Quantity'}: ${item.currentStockLevel} ${currentLocalization['Kg']}"
                  " | ${currentLocalization['Rate'] ?? 'Rate'}: ₹${item.ratePerKg} / ${currentLocalization['Kg']}"
                  " | ${currentLocalization['date'] ?? 'Date'}: $sFdDate"
                  " | ${currentLocalization['Source'] ?? 'Source'}: ${currentLocalization[item.source.toLowerCase()]}",
                ),
                tileColor: Color.fromRGBO(177, 243, 238, 0.4),
                onLongPress: () {
                  setState(() {
                    _showCheckboxes = true;
                  });
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _showCheckboxes
                        ? Checkbox(
                            value: selectedEntries.contains(item.invId),
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF0DA6BA),
                            shape: const CircleBorder(),
                            // Tealish blue
                            onChanged: (val) {
                              setState(() {
                                if (val!) {
                                  selectedEntries.add(item.invId);
                                } else {
                                  selectedEntries.remove(item.invId);
                                }
                              });
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to create a section button
  Widget sectionButton(String sectionName) {
    final isSelected = selectedSection == sectionName;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = sectionName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey[500] // Dark grey when selected
              : Colors.grey[200], // Light grey when unselected
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0), // No curves for rectangular shape
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Center(
          child: Text(
            currentLocalization[sectionName] ?? sectionName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteInvEntries() async {
    List<Future> futures = [];
    for (var invId in selectedEntries) {
      futures.add(fdDB.deleteFeedFromServer(invId));
    }
    var results = await Future.wait(futures);
    int successCnt = 0;
    int failureCnt = 0;
    for (int i = 0; i < results.length; i++) {
      if (results[i] == 'Success') {
        successCnt++;
      }
      else if(results[i] == 'AlreadyInUse'){
        failureCnt++;
      }
    }
    if (mounted) {
      if (failureCnt > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: successCnt > 0
                ? Text("${currentLocalization['some_feed_delete_msg']??'Some items cannot be deleted'} ")
                : Text(currentLocalization['all_feed_delete_msg']??'Cannot delete the selected item/items'),
          ),
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FeedPage(farmId: widget.farmId)),
      );
    }
  }

}
