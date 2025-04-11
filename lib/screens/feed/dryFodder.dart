import 'package:farm_expense_mangement_app/screens/feed/feedUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/feed.dart';
import 'feedpage.dart';



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
  final List<String> _fodderTypes = ['Wheat Straw', 'Paddy Straw', 'Others'];
  final List<String> _sourceTypes = ['Purchased', 'Own Farm'];

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
              feedUtils.buildDropdown(
                  label: 'Type', value: _selectedType, items: _fodderTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  }),
              if (_selectedType == 'Others') ...[
                const SizedBox(height: 20),
                feedUtils.buildTextField(_customTypeController, 'Custom Type'),
              ],
              const SizedBox(height: 20),
              feedUtils.buildDropdown(
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
                    child: feedUtils.buildTextField(
                        _quantityController, 'Quantity'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: feedUtils.buildDropdown(
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
        SnackBar(content: Text('Custom Type cannot be empty!')),
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
