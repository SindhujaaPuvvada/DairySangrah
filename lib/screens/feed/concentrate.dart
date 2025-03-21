import 'package:farm_expense_mangement_app/screens/feed/feedUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/feed.dart';
import 'feedpage.dart';

class ConcentratePage extends StatefulWidget {
  const ConcentratePage({super.key});

  @override
  State<ConcentratePage> createState() => _ConcentratePageState();
}

class _ConcentratePageState extends State<ConcentratePage> {
  // TextEditingControllers to handle input
  final TextEditingController _quantityController = TextEditingController
      .fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _rateController = TextEditingController.fromValue(
      TextEditingValue(text: '0.0'));
  final TextEditingController _priceController = TextEditingController
      .fromValue(TextEditingValue(text: '0.0'));
  final TextEditingController _customHomemadeController = TextEditingController();
  final TextEditingController _customPurchasedController = TextEditingController();
  final Map<String, TextEditingController> _ingControllers = {};

  String _selectedType = 'Homemade'; // Default value
  String _selectedUnit = 'Kg';

  // List of dropdown items
  final List<String> _homemadeIngredients = [
    'Mustard',
    'Maize',
    'Barley',
    'De-Oiled Rice Bran',
    'Soyabean',
    'Wheat Bran',
    'DCP',
    'LSP',
    'Salt',
    'Sodium Bicarbonate',
    'Nicen',
    'Urea',
    'Mineral Mixture',
    'Others',
  ];

  List<String> _selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _homemadeIngredients.forEach((ing) {
      TextEditingController txtCntrlr = TextEditingController.fromValue(
          TextEditingValue(text: '0.0'));
      _ingControllers[ing] = txtCntrlr;
    });
  }


  @override
  void dispose() {
    super.dispose();
    _ingControllers.values.forEach((txtCntrlr) {
      txtCntrlr.dispose();
    });
  }

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
          'Concentrate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
                label: 'Source',
                value: _selectedType,
                items: ['Homemade', 'Purchased'],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    // Reset specific type values based on the selected type
                    if (_selectedType == 'Homemade') {
                      _customPurchasedController
                          .clear(); // Clear custom input if switching to Homemade
                    } else if (_selectedType == 'Purchased') {
                      _selectedIngredients = [];
                      _customHomemadeController
                          .clear(); // Clear custom input if switching to Purchased
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_selectedType == 'Homemade') ...[
                feedUtils.buildTextField(
                    _customHomemadeController,
                    'Enter Custom Homemade Type'),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Select Ingredients:', style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(4, 142, 161, 1.0)),),
                    ]
                ),
                const SizedBox(height: 20),
                SizedBox(height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            for (String item in _homemadeIngredients)...[
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        value: _selectedIngredients.contains(
                                            item),
                                        onChanged: (isSelected) {
                                          if (isSelected == true) {
                                            _selectedIngredients.add(item);
                                          } else if (isSelected == false) {
                                            _selectedIngredients.remove(
                                                item);
                                          }
                                          setState(() {});
                                        }
                                    ),
                                    SizedBox(width: 100, child: Text(item)),
                                    SizedBox(width: 20),
                                    (_selectedIngredients.contains(item)) ?
                                    Expanded(
                                      child: TextField(
                                        controller: _ingControllers[item],
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Enter its cost',
                                        ),
                                      ),
                                    ) : Text('')
                                  ]
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                if (_selectedType == 'Purchased') ...[
                  feedUtils.buildTextField(
                      _customPurchasedController,
                      'Enter Custom Purchased Type'),
                ],
              const SizedBox(height: 20),
              const SizedBox(height: 20),

              // Row containing Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: feedUtils.buildTextField(
                        _quantityController, 'Quantity'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: feedUtils.buildDropdown(
                        label: 'Unit',
                        value:
                        _selectedUnit,
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
              feedUtils.buildTextField(_rateController, 'Rate per Unit'),
              const SizedBox(height: 20),
              feedUtils.buildTextField(_priceController, 'Price'),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    feedUtils.buildElevatedButton('Calculate',
                        onPressed: () => _calculatePrice()),
                    feedUtils.buildElevatedButton('Save',
                        onPressed: () => _submitData()),
                  ],
                ),
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }

  // Method to handle form submission
  void _submitData() {
    final type = (_selectedType == 'Homemade')
        ? _customHomemadeController.text
        : _customPurchasedController.text;
    double quantity = double.parse(_quantityController.text);
    final source = _selectedType;
    double rate = double.parse(_rateController.text);
    double price = double.parse(_priceController.text);

    if(type.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Custom Type cannot be empty!')),
      );
      return;
    }

    if (_selectedUnit != 'Kg') {
      quantity = quantity * 100;
      rate = rate / 100;
    }
    Feed feed = new Feed(
      category: "Concentrate",
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

    setState(() {
      if (_selectedType == 'Purchased') {
        var lt = feedUtils.calRateOrPrice(price, rate, quantity);
        price = lt[0];
        rate = lt[1];
      }
      else{
        for (String item in _selectedIngredients) {
          price = price + double.parse(_ingControllers[item]!.text);
        }
        var lt = feedUtils.calRateOrPrice(price, rate, quantity);
        price = lt[0];
        rate = lt[1];
      }
      _priceController.text = (price.toPrecision(2)).toString();
      _rateController.text = (rate.toPrecision(2)).toString();
    });
  }
}


