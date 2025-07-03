import 'package:farm_expense_mangement_app/screens/feed/feedUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/feed.dart';
import 'feedpage.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';



class DryFodderPage extends StatefulWidget {
  const DryFodderPage({super.key});

  @override
  State<DryFodderPage> createState() => _DryFodderPageState();
}

class _DryFodderPageState extends State<DryFodderPage> {
  final TextEditingController _quantityController = TextEditingController
      .fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _rateController = TextEditingController.fromValue(
      TextEditingValue(text: '0.0'));
  final TextEditingController _priceController = TextEditingController
      .fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _customTypeController = TextEditingController();

  String _selectedType = 'Wheat Straw';
  String _selectedSource = 'Purchased';
  String _selectedUnit = 'Kg';
  late Map<String, String> currentLocalization = {};
  late Map<String, String> typeMap;
  late Map<String, String> sourceMap;
  late Map<String, String> unitMap;

  late String languageCode = 'en';

  @override
  void dispose() {
    _customTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider
        .of<AppData>(context)
        .persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    typeMap = {
      'Wheat Straw': currentLocalization['Wheat Straw'] ?? 'Wheat Straw',
      'Paddy Straw': currentLocalization['Paddy Straw'] ?? 'Paddy Straw',
      'Others': currentLocalization['Others'] ?? 'Others',
    };

    sourceMap = {
      'Purchased': currentLocalization['purchased'] ?? 'Purchased',
      'Own Farm': currentLocalization['own farm'] ?? 'Own Farm',
    };

    unitMap = {
      'Kg':currentLocalization['Kg']??'Kg',
      'Quintal':currentLocalization['Quintal']??'Quintal'
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          currentLocalization['Dry Fodder']??"",
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
              feedUtils.buildDropdown(
                label: currentLocalization['Type'] ?? "Type",
                value: _selectedType,
                items: typeMap,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),

              if (_selectedType == 'Others') ...[
                const SizedBox(height: 20),
                feedUtils.buildTextField(_customTypeController, currentLocalization['Enter custom type']??""),
              ],
              const SizedBox(height: 20),
              feedUtils.buildDropdown(
                label: currentLocalization['Source'] ?? "Source",
                value: _selectedSource,
                items: sourceMap,
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: feedUtils.buildTextField(
                        _quantityController, currentLocalization['Quantity']??""),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: feedUtils.buildDropdown(
                        label: currentLocalization['Unit']??"",
                        value: _selectedUnit,
                        items: unitMap,
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
              feedUtils.buildTextField(_rateController, currentLocalization['Rate per Unit']??""),
              const SizedBox(height: 20),
              feedUtils.buildTextField(_priceController, currentLocalization['Total Price']??""),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    feedUtils.buildElevatedButton(currentLocalization['Calculate']??"",
                        onPressed: () => _calculatePrice()),
                    feedUtils.buildElevatedButton(currentLocalization['Save']??"",
                        onPressed: () => _submitData()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitData() {
    final type = _selectedType == 'Others'
        ? _customTypeController.text
        : _selectedType;
    double quantity = double.parse(_quantityController.text);
    double rate = double.parse(_rateController.text);
    double price = double.parse(_priceController.text);
    final source = _selectedSource;

    if(type.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentLocalization['Custom Type cannot be empty!']??'')),
      );
      return;
    }

    if (_selectedUnit != 'Kg') {
      quantity = quantity * 100;
      rate = rate / 100;
    }

    Feed feed = Feed(
      category: "DryFodder",
      feedType: type,
      quantity: quantity,
      source: source,
      totPrice: price,
      ratePerKg: rate,
      feedDate: DateTime.now(),
    );

    feedUtils.saveFeedDetails(feed);

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedPage()));
  }

  void _calculatePrice() {
    double quantity = (_quantityController.text.isNotEmpty) ? double.parse(_quantityController.text):0.0;
    double rate = (_rateController.text.isNotEmpty) ? double.parse(_rateController.text):0.0;
    double price = (_priceController.text.isNotEmpty) ? double.parse(_priceController.text):0.0;

    var lt = feedUtils.calRateOrPrice(price, rate, quantity);

    _priceController.text = (lt[0].toPrecision(2)).toString();
    _rateController.text = (lt[1].toPrecision(2)).toString();
  }

}
