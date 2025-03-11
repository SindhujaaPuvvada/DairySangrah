import 'package:flutter/material.dart';

class GreenFodderPage extends StatefulWidget {
  const GreenFodderPage({super.key});

  @override
  State<GreenFodderPage> createState() => _GreenFodderPageState();
}

class _GreenFodderPageState extends State<GreenFodderPage> {
  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _seedTypeController = TextEditingController();
  final TextEditingController _seedCostController = TextEditingController();
  final TextEditingController _fertilizerCostController = TextEditingController();
  final TextEditingController _inoculantsCostController = TextEditingController();
  final TextEditingController _laborCostController = TextEditingController();
  final TextEditingController _dieselCostController = TextEditingController();


  String _selectedType = 'Maize';
  String _selectedSource = 'Purchased';
  bool _isCustomType = false;
  String _selectedUnit = 'Kg';

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
                items: [
                  'Maize',
                  'Barley',
                  'Mustard',
                  'Rye Grass',
                  'Bajra',
                  'Sorghum',
                  'Barseem',
                  'Oats',
                  'Others'
                ],
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    _isCustomType = _selectedType == 'Others';
                  });
                },
              ),

              const SizedBox(height: 20),

              (_isCustomType)?
                  Column(
                    children: [
                _buildTextField(_customTypeController, 'Enter custom type'),
                const SizedBox(height: 20),
                ])
                : Column(),

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

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_quantityController, 'Quantity/Yield'),
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

              (_selectedSource == 'Purchased')
                  ?
                  Container(
                    child:
              Column(
                  children: [
                    _buildTextField(_rateController, 'Rate per Unit'),
                    const SizedBox(height: 20),
                    _buildTextField(_priceController, 'Total Price'),
                  ])
                  )
                  :
              Container(
                child: Column(
                  children: [
                    _buildTextField(_areaController, 'Land Area(in acres)'),
                    const SizedBox(height: 20),
                    _buildTextField(_seedTypeController, 'Seed Type'),
                    const SizedBox(height: 20),
                    _buildTextField(_seedCostController, 'Seed Cost'),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _fertilizerCostController, 'Fertilizers Cost'),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _inoculantsCostController, 'Inoculants Cost'),
                    const SizedBox(height: 20),
                    _buildTextField(_laborCostController, 'Labor Cost'),
                    const SizedBox(height: 20),
                    _buildTextField(_dieselCostController, 'Diesel Cost'),
                    const SizedBox(height: 20),
                    _buildTextField(_priceController, 'Total Production Cost'),
                    const SizedBox(height: 20),
                    _buildTextField(_rateController, 'Rate per Unit'),
                ]
                  ),
              ),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitData();
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
              const SizedBox(height: 20,)
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

  void _submitData() {
    final type = _isCustomType ? _customTypeController.text : _selectedType;
    double quantity = double.parse(_quantityController.text);
    final unit =  _selectedUnit;
    final source = _selectedSource;
    double rate = double.parse(_rateController.text);
    double price = double.parse(_priceController.text);

    if(_selectedUnit != 'Kg'){
      quantity = quantity * 100;
    }

    if(_selectedSource == 'Purchased'){

    }



    print('Type: $type, Quantity: $quantity $unit, Source: $source, Rate: $rate, Price: $price');
  }
}