import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';
import 'dryFodder.dart';
import 'greenFodder.dart';
import 'concentrate.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedState();
}

class _FeedState extends State<FeedPage> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late String selectedSection = 'Green Fodder'; // Default section

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    if (languageCode == 'en') {
      currentLocalization = LocalizationEn.translations;
    } else if (languageCode == 'hi') {
      currentLocalization = LocalizationHi.translations;
    } else if (languageCode == 'pa') {
      currentLocalization = LocalizationPun.translations;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          currentLocalization['inventory']??"",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0), // AppBar color
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
          Expanded(
            child: displaySelectedSectionContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedSection == 'Dry Fodder') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DryFodderPage()),
            );
          }
          if (selectedSection == 'Green Fodder') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GreenFodderPage()),
            );
          }
          if (selectedSection == 'Concentrate') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConcentratePage()),
            );
          }
        },
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0), // Same as AppBar color
        child: const Icon(
          Icons.add,
          color: Colors.black, // Icon color
          size: 30, // Icon size
        ),
      ),
    );
  }

  // Method to display the content based on the selected section
  Widget displaySelectedSectionContent() {
    final sectionType = selectedSection.replaceAll(' ', '').toLowerCase(); // Normalize section name
    final collectionPath = 'feed/$sectionType/items';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionPath).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No items found.'));
        }
        final items = snapshot.data!.docs;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(item['itemName'] ?? 'Unknown Item'),
              subtitle: Text('Quantity: ${item['quantity'] ?? 0}'),
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
            sectionName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
