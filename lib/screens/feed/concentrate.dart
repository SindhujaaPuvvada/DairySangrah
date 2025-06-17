import 'package:farm_expense_mangement_app/screens/feed/feedUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/feed.dart';
import 'feedpage.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';

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
  late Map<String, String> currentLocalization = {};
  late Map<String, String> sourceMap;
  late Map<String, String> unitMap;
  late String languageCode = 'en';

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
    for (var ing in _homemadeIngredients) {
      TextEditingController txtCntrlr = TextEditingController.fromValue(
          TextEditingValue(text: '0.0'));
      _ingControllers[ing] = txtCntrlr;
    }
  }


  @override
  void dispose() {
    super.dispose();
    for (var txtCntrlr in _ingControllers.values) {
      txtCntrlr.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider
        .of<AppData>(context)
        .persistentVariable;

    if (languageCode == 'en') {
      currentLocalization = LocalizationEn.translations;
    } else if (languageCode == 'hi') {
      currentLocalization = LocalizationHi.translations;
    } else if (languageCode == 'pa') {
      currentLocalization = LocalizationPun.translations;
    }

    sourceMap = {
      'Purchased': currentLocalization['purchased'] ?? 'Purchased',
      'Homemade': currentLocalization['homemade'] ?? 'Homemade',
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
          currentLocalization['Concentrate']??"",
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
                label: currentLocalization['Source'] ?? "Source",
                value: _selectedType,
                items: sourceMap,
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
                    currentLocalization['Enter Custom Homemade Type']??""),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        currentLocalization['Select Ingredients:']??"", style: TextStyle(fontSize: 18,
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
                                        checkColor: Colors.white,
                                        activeColor: const Color(0xFF0DA6BA),
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
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.20, child: Text(currentLocalization[item]??"")),
                                    SizedBox(width: 20),
                                    (_selectedIngredients.contains(item)) ?
                                    Expanded(
                                      child: TextField(
                                        controller: _ingControllers[item],
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: currentLocalization['Enter its cost']??"",
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
                      currentLocalization['Enter Custom Purchased Type']??""),
                ],
              const SizedBox(height: 20),
              const SizedBox(height: 20),

              // Row containing Quantity and Unit
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
                        value:
                        _selectedUnit,
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
              feedUtils.buildTextField(_rateController, currentLocalization['Rate per Unit']??"", _selectedType == 'Homemade'? true: false),
              const SizedBox(height: 20),
              feedUtils.buildTextField(_priceController, currentLocalization['Total Price']??"", _selectedType == 'Homemade'? true: false),
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
        SnackBar(content: Text(currentLocalization['Custom Type cannot be empty!']??'')),
      );
      return;
    }

    if (_selectedUnit != 'Kg') {
      quantity = quantity * 100;
      rate = rate / 100;
    }
    Feed feed = Feed(
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
        rate=0.0;
        price=0.0;
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


