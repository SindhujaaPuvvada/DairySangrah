import 'package:flutter/material.dart';

class ConcentratePage extends StatefulWidget {
  const ConcentratePage({super.key});

  @override
  State<ConcentratePage> createState() => _ConcentratePageState();
}

class _ConcentratePageState extends State<ConcentratePage> {
  // TextEditingControllers to handle input
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _customHomemadeController = TextEditingController();
  final TextEditingController _customPurchasedController = TextEditingController();

  String _selectedType = 'Homemade'; // Default value
  String _selectedHomemadeType = 'Mustard'; // Default value for homemade types
  //String _selectedPurchasedType = 'Brand Name'; // Default value for purchased types

  // List of dropdown items
  final List<String> _homemadeTypes = [
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
    'Others'
  ];

  /*final List<String> _purchasedTypes = [
    'Brand Name',
    'Type'
  ];*/

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
              _buildDropdown(
                label: 'Source',
                value: _selectedType,
                items: ['Homemade', 'Purchased'],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    // Reset specific type values based on the selected type
                    if (_selectedType == 'Homemade') {
                      _customPurchasedController.clear(); // Clear custom input if switching to Homemade
                    } else if (_selectedType == 'Purchased') {
                      _selectedHomemadeType = 'Mustard'; // Reset homemade type if purchased is selected
                      _customHomemadeController.clear(); // Clear custom input if switching to Purchased
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_selectedType == 'Homemade') ...[
                _buildDropdown(
                  label: 'Homemade Type',
                  value: _selectedHomemadeType,
                  items: _homemadeTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedHomemadeType = value!;
                      if (_selectedHomemadeType == 'Others') {
                        _customHomemadeController.text = ''; // Clear custom input when 'Others' is selected
                      }
                    });
                  },
                ),
                if (_selectedHomemadeType == 'Others') ...[
                  const SizedBox(height: 20),
                  _buildTextField(_customHomemadeController, 'Enter Custom Homemade Type'),
                ],
              ] else if (_selectedType == 'Purchased') ...[
               /* _buildDropdown(
                  value: _selectedPurchasedType,
                  items: _purchasedTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedPurchasedType = value!;
                      if (_selectedPurchasedType == 'Brand Name') {
                        _customPurchasedController.text = ''; // Clear custom input when 'Brand Name' is selected
                      }
                    });
                  },
                ),
                if (_selectedPurchasedType == 'Type') ...[*/
                  _buildTextField(_customPurchasedController, 'Enter Custom Purchased Type'),
                //],
              ],
              const SizedBox(height: 20),
              // Row containing Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_quantityController, 'Quantity'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(_unitController, 'Unit (e.g., kg)'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(_rateController, 'Rate per Unit (if Purchased)'),
              const SizedBox(height: 20),
              _buildTextField(_priceController, 'Price (if Purchased)'),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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

  // Helper method to create dropdown
 /* Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      isExpanded: true,
    );
  }*/

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


  // Helper method to create input fields with smaller size
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      style: const TextStyle(fontSize: 14.0),
    );
  }

  // Method to handle form submission
  void _submitData() {
    final quantity = _quantityController.text;
    final unit = _unitController.text;
    final rate = _rateController.text;
    final price = _priceController.text;
    final customHomemade = _customHomemadeController.text;
    final customPurchased = _customPurchasedController.text;

    print('Type: $_selectedType');
    if (_selectedType == 'Homemade') {
      print('Homemade Type: $_selectedHomemadeType');
      if (_selectedHomemadeType == 'Others') {
        print('Custom Homemade Type: $customHomemade');
      }
    } else if (_selectedType == 'Purchased') {
        print('Custom Purchased Type: $customPurchased');
    }
    print('Quantity: $quantity $unit, Rate: $rate, Price: $price');
  }
}