import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/feed.dart';
import 'feedUtils.dart';
import 'feedpage.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';

class GreenFodderPage extends StatefulWidget {
  const GreenFodderPage({super.key});

  @override
  State<GreenFodderPage> createState() => _GreenFodderPageState();
}

class _GreenFodderPageState extends State<GreenFodderPage> {
  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _rateController = TextEditingController.fromValue(
    TextEditingValue(text: '0.0'),
  );
  final TextEditingController _priceController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _areaController = TextEditingController.fromValue(
    TextEditingValue(text: '1.0'),
  );
  final TextEditingController _seedCostController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _fertilizerCostController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _inoculantsCostController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _laborCostController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _dieselCostController =
      TextEditingController.fromValue(TextEditingValue(text: '0.0'));

  String _selectedType = 'Maize';
  late String _selectedSource = 'Purchased';
  bool _isCustomType = false;
  String _selectedUnit = 'Kg';
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  late Map<String, String> typeMap;
  late Map<String, String> sourceMap;
  late Map<String, String> unitMap;

  @override
  void dispose() {
    _rateController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _customTypeController.dispose();
    _dieselCostController.dispose();
    _laborCostController.dispose();
    _inoculantsCostController.dispose();
    _fertilizerCostController.dispose();
    _areaController.dispose();
    _seedCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode]!;
    typeMap = {
      'Maize': currentLocalization['Maize'] ?? 'Maize',
      'Barley': currentLocalization['Barley'] ?? 'Barley',
      'Mustard': currentLocalization['Mustard'] ?? 'Mustard',
      'Rye Grass': currentLocalization['Rye Grass'] ?? 'Rye Grass',
      'Bajra': currentLocalization['Bajra'] ?? 'Bajra',
      'Sorghum': currentLocalization['Sorghum'] ?? 'Sorghum',
      'Berseem': currentLocalization['Berseem'] ?? 'Berseem',
      'Oats': currentLocalization['Oats'] ?? 'Oats',
      'Others': currentLocalization['Others'] ?? 'Others',
    };

    sourceMap = {
      'Purchased': currentLocalization['purchased'] ?? 'Purchased',
      'Own Farm': currentLocalization['own farm'] ?? 'Own Farm',
    };

    unitMap = {
      'Kg': currentLocalization['Kg'] ?? 'Kg',
      'Quintal': currentLocalization['Quintal'] ?? 'Quintal',
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
          currentLocalization['Green Fodder'] ?? "",
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

              FeedUtils.buildDropdown(
                label: currentLocalization['Type'] ?? "Type",
                value: _selectedType,
                items: typeMap,
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    _isCustomType = _selectedType == 'Others';
                  });
                },
              ),

              const SizedBox(height: 20),

              (_isCustomType)
                  ? Column(
                    children: [
                      FeedUtils.buildTextField(
                        _customTypeController,
                        currentLocalization['Enter custom type'] ?? "",
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                  : Column(),

              FeedUtils.buildDropdown(
                label: currentLocalization['Source'] ?? "Source",
                value: _selectedSource,
                items: sourceMap,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSource = newValue!;
                  });
                },
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FeedUtils.buildTextField(
                      _quantityController,
                      currentLocalization['Quantity/Yield'] ?? "",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: FeedUtils.buildDropdown(
                      label: currentLocalization['Unit'] ?? "",
                      value: _selectedUnit,
                      items: unitMap,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUnit = newValue!;
                        });
                      },
                    ),
                    // print(_selectedSource),
                  ),
                ],
              ),
              // print(_selectedSource),
              const SizedBox(height: 20),

              (_selectedSource == 'Purchased')
                  ? Column(
                    children: [
                      FeedUtils.buildTextField(
                        _rateController,
                        currentLocalization['Rate per Unit'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _priceController,
                        currentLocalization['Total Price'] ?? "",
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      FeedUtils.buildTextField(
                        _areaController,
                        currentLocalization['Land Area(in acres)'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _seedCostController,
                        currentLocalization['Seed Cost'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _fertilizerCostController,
                        currentLocalization['Fertilizers Cost'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _inoculantsCostController,
                        currentLocalization['Inoculants Cost'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _laborCostController,
                        currentLocalization['Labor Cost'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _dieselCostController,
                        currentLocalization['Diesel Cost'] ?? "",
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _priceController,
                        currentLocalization['Total Production Cost'] ?? "",
                        true,
                      ),
                      const SizedBox(height: 20),
                      FeedUtils.buildTextField(
                        _rateController,
                        currentLocalization['Rate per Unit'] ?? "",
                        true,
                      ),
                    ],
                  ),

              const SizedBox(height: 40),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FeedUtils.buildElevatedButton(
                      currentLocalization['Calculate'] ?? "",
                      onPressed: () => _calculatePrice(),
                    ),
                    FeedUtils.buildElevatedButton(
                      currentLocalization['Save'] ?? "",
                      onPressed: () => _submitData(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitData() async {
    final type = _isCustomType ? _customTypeController.text : _selectedType;
    double quantity = double.parse(_quantityController.text);
    final source = _selectedSource;
    double rate = double.parse(_rateController.text);
    double price = double.parse(_priceController.text);

    if (type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentLocalization['Custom Type cannot be empty!'] ?? '',
          ),
        ),
      );
      return;
    }

    if (_selectedUnit != 'Kg') {
      quantity = quantity * 100;
      rate = rate / 100;
    }
    Feed feed = Feed(
      category: "GreenFodder",
      feedType: type,
      quantity: quantity,
      source: source,
      totPrice: price,
      ratePerKg: rate,
      feedDate: DateTime.now(),
    );

    await FeedUtils.saveFeedDetails(feed);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedPage()),
      );
    }
  }

  void _calculatePrice() {
    double quantity =
        (_quantityController.text.isNotEmpty)
            ? double.parse(_quantityController.text)
            : 0.0;
    double rate =
        (_rateController.text.isNotEmpty)
            ? double.parse(_rateController.text)
            : 0.0;
    double price =
        (_priceController.text.isNotEmpty)
            ? double.parse(_priceController.text)
            : 0.0;

    setState(() {
      if (_selectedSource == 'Purchased') {
        var lt = FeedUtils.calRateOrPrice(price, rate, quantity);
        price = lt[0];
        rate = lt[1];
      } else {
        price =
            double.parse(_seedCostController.text) +
            double.parse(_fertilizerCostController.text) +
            double.parse(_inoculantsCostController.text) +
            double.parse(_laborCostController.text) +
            double.parse(_dieselCostController.text);

        var area =
            _areaController.text.isNotEmpty
                ? double.parse(_areaController.text)
                : double.parse('1');

        if (quantity != 0.0) {
          rate = (price / quantity) / area;
        }
      }
      _priceController.text = (price.toPrecision(2)).toString();
      _rateController.text = (rate.toPrecision(2)).toString();
    });
  }
}
