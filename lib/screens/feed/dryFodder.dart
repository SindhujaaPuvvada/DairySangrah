import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/feed.dart';
import '../../services/database/feeddatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';


class DryFodderPage extends StatefulWidget {
  // final String uid;
  const DryFodderPage({super.key});

  @override
  State<DryFodderPage> createState() => _DryFodderPageState();
}

class _DryFodderPageState extends State<DryFodderPage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _otherTypeController = TextEditingController();

  String _selectedType='Wheat Straw';
  String _selectedSource='Purchased';
  String _selectedUnit = 'Kg';
  final List<String> _fodderTypes = ['Wheat Straw', 'Paddy', 'Straw', 'Others'];
  final List<String> _sourceTypes = ['Purchased', 'Own Farm'];

  late final DatabaseServicesForFeed _dbService;

  @override
  void initState() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    super.initState();
    _dbService = DatabaseServicesForFeed(uid!);
  }

  Future<void> _submitData() async {
    final type = _selectedType == 'Others' ? _otherTypeController.text : _selectedType;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unit = _selectedUnit;
    final rate = _rateController.text;
    final price = _priceController.text;
    final source = _selectedSource;

    final newFeed = Feed(
      itemName: type ?? '',
      quantity: quantity,
      Type:'Dry Fodder',
    );

    await _dbService.infoToServerFeed(newFeed);

    print('Data saved: Type: $type, Quantity: $quantity $unit, Rate: $rate, Price: $price, Source: $source');
  }

  // Weekly deduction logic
  /*Future<void> _scheduleWeeklyDeduction(Feed feed) async {
    final docSnapshot = await _dbService.infoFromServer(feed.itemName);
    if (docSnapshot.exists) {
      final currentFeed = Feed.fromFireStore(docSnapshot);
      final updatedQuantity = (currentFeed.quantity - (feed.requiredQuantity ?? _defaultWeeklyConsumption)).clamp(0, currentFeed.quantity);

      await _dbService.infoToServerFeed(Feed(
        itemName: currentFeed.itemName,
        quantity: updatedQuantity,
        Type: 'Dry Fodder',
        requiredQuantity: currentFeed.requiredQuantity,
      ));

      print('Weekly consumption deducted. New quantity: $updatedQuantity');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Dry Fodder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildDropdown(
                  label: 'Type', value: _selectedType, items: _fodderTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  }),
              if (_selectedType == 'Others') ...[
                const SizedBox(height: 20),
                _buildTextField(_otherTypeController, 'Custom Type'),
              ],
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Source', value: _selectedSource, items: _sourceTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value!;
                  });
                },),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_quantityController, 'Quantity'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                        label: 'Unit',
                        value: _selectedUnit,
                        items: ['Kg', 'Quintal'],
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUnit = newValue!;
                          });
                        }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(_rateController, 'Rate per Unit(if Purchased)'),
              const SizedBox(height: 20),
              _buildTextField(_priceController, 'Price(if Purchased)'),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitData();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create input fields
  Widget _buildTextField(TextEditingController controller, String label, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 12.0),
      ),
      style: const TextStyle(fontSize: 14.0),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 12.0),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

}
