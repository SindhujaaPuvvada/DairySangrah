import 'package:flutter/material.dart';

class GreenFodderPage extends StatefulWidget {
  const GreenFodderPage({super.key});

  @override
  State<GreenFodderPage> createState() => _GreenFodderPageState();
}

class _GreenFodderPageState extends State<GreenFodderPage> {
  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  String _selectedType = 'Maize';
  String _selectedSource = 'Purchased';
  bool _isCustomType = false;

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
          'Green Fodder',
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
                label: 'Type',
                value: _selectedType,
                items: ['Maize', 'Barley', 'Mustard', 'Rye Grass', 'Bajra', 'Sorghum', 'Barseem', 'Oats', 'Others'],
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    _isCustomType = _selectedType == 'Others';
                  });
                },
              ),

              const SizedBox(height: 20),

              if (_isCustomType)
                _buildTextField(_customTypeController, 'Enter custom type'),

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
                    child: _buildTextField(_unitController, 'Unit (e.g., kg)'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Source',
                value: _selectedSource,
                items: ['Purchased', 'Own Farm'],
                onChanged: (newValue) {
                  setState(() {
                    _selectedSource = newValue!;
                  });
                },
              ),

              const SizedBox(height: 20),
              _buildTextField(_rateController, 'Rate per Unit (if Purchased)'),
              const SizedBox(height: 20),
              _buildTextField(_priceController, 'Price (if Purchased)'),
              const SizedBox(height: 20),
              _buildTextField(_brandController, 'Brand Name (if Purchased)'),
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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

  void _submitData() {
    final type = _isCustomType ? _customTypeController.text : _selectedType;
    final quantity = _quantityController.text;
    final unit = _unitController.text;
    final source = _selectedSource;
    final rate = _rateController.text;
    final price = _priceController.text;
    final brand = _brandController.text;

    print('Type: $type, Quantity: $quantity $unit, Source: $source, Rate: $rate, Price: $price, Brand: $brand');
  }
}