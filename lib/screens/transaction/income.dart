import 'package:farm_expense_mangement_app/screens/transaction/transactionpage.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logging.dart';
import '../../models/cattle.dart';
import '../../models/sales.dart';
import '../../services/database/transactiondatabase.dart';
import '../../main.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:excel/excel.dart';
import '../../services/supabaseService.dart';

class AddIncome extends StatefulWidget {
  final Function onSubmit;
  final String farmId;
  const AddIncome({super.key, required this.onSubmit, required this.farmId});

  @override
  State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  final log = logger(AddIncome);
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  late DbForSale dbSale;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountTextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _snfController = TextEditingController();
  final TextEditingController _tmpController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _cCntController = TextEditingController();

  String? _selectedCategory;
  String? _selectedBuyer;
  List<Cattle> allCattle = [];
  final List<String> _selectedCList = [];

  final List<String> sourceOptions = ['Cattle Sale', 'Milk Sale', 'Other'];
  final List<String> milkOptions = ['Amul', 'Verka', 'Nestle', 'D to C'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked.day.toString() != _dateController.text) {
      setState(() {
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dbSale = DbForSale();
    _fetchCattle();
  }

  Future<void> _fetchCattle() async {
    final snapshot = await DbServicesForCattle().infoFromServerAllCattle(
      widget.farmId,
    );
    setState(() {
      allCattle = snapshot.map((r) => Cattle.fromDB(r)).toList();
    });
  }

  Future<String> _addIncome(Sale data) async {
    final sale = await dbSale.infoFromServerSaleOnDate(
      data.saleType,
      data.saleDate,
      widget.farmId,
    );

    String sId;
    if (sale != null && sale.isNotEmpty) {
      data.amount = data.amount + sale['amount'];
      sId = sale['saleId'].toString();
      await dbSale.updateExistingSaleToServer(sId, data.amount);
    } else {
      sId = await dbSale.infoToServerSale(data);
    }
    return sId;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountTextController.dispose();
    _categoryTextController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _tmpController.dispose();
    _quantityController.dispose();
    _cCntController.dispose();
    super.dispose();
  }

  Future<double> getMilkPrice(double fat, double snf) async {
    try {
      // 🔹 Fetch Excel file as bytes from Firebase Storage
      final fileBytes = await SupabaseService.client.storage
          .from('MilkRates')
          .download('${_selectedBuyer}_Rates.xlsx');

      // 🔹 Decode Excel file from bytes
      var excel = Excel.decodeBytes(fileBytes);

      int colIndex = 0;

      var firstSheet = excel.tables.keys.first;
      var firstRow = excel.tables[firstSheet]!.rows.first;

      for (int i = 0; i < firstRow.length; i++) {
        double colSnf =
            double.tryParse(firstRow[i]?.value.toString() ?? '') ?? 0.0;
        if (snf == colSnf) {
          colIndex = i;
          break;
        }
      }

      for (var row in excel.tables[firstSheet]!.rows) {
        double rowFat = double.tryParse(row[0]?.value.toString() ?? '') ?? 0.0;
        if (fat == rowFat) {
          if (colIndex != 0) {
            double rowPrice =
                double.tryParse(row[colIndex]?.value.toString() ?? '') ?? 0.0;

            if (rowPrice != 0.0) {
              return rowPrice;
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${currentLocalization['no_matching_price']} ${currentLocalization['fat']}: $fat, ${currentLocalization['snf']}: $snf!",
                    ),
                  ),
                );
              }
              return 0.0;
            }
          }
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${currentLocalization['no_matching_price']} ${currentLocalization['fat']}: $fat, ${currentLocalization['snf']}: $snf!",
            ),
          ),
        );
      }
      return 0.0;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(currentLocalization['Error in Fetch'] ?? '')),
        );
      }
      log.e("Error fetching price", time: DateTime.now(), error: e.toString());
      return 0.0;
    }
  }

  void _calculateMilkIncome() async {
    double fat = double.tryParse(_fatController.text) ?? 0.0;
    double snf = double.tryParse(_snfController.text) ?? 0.0;
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;

    if (fat > 0 && snf > 0 && quantity > 0) {
      double pricePerLiter = await getMilkPrice(fat, snf);
      double totalPrice = pricePerLiter * quantity;
      setState(() {
        _amountTextController.text = totalPrice.toStringAsFixed(2);
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentLocalization["err_msg"] ?? 'Error'),
          content: Text(currentLocalization[message] ?? message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(currentLocalization["OK"] ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  void _validateAndSubmit() async {
    if (_dateController.text.isEmpty) {
      _showErrorDialog("please_choose_date");
      return;
    }
    if (_selectedCategory == null) {
      _showErrorDialog("please_sel_income_type");
      return;
    }
    if (_selectedCategory == 'Other' && _categoryTextController.text.isEmpty) {
      _showErrorDialog('please_enter_category_other');
      return;
    }
    if (_selectedCategory == 'Milk Sale') {
      if (_selectedBuyer == null) {
        _showErrorDialog('please_sel_milk_buyer');
        return;
      }
      if (_selectedBuyer != 'D to C') {
        if (_fatController.text.isEmpty ||
            _snfController.text.isEmpty ||
            _quantityController.text.isEmpty) {
          _showErrorDialog('please_sel_fat_snf_qty');
          return;
        }

        double fat = double.tryParse(_fatController.text) ?? 0.0;
        double snf = double.tryParse(_snfController.text) ?? 0.0;
        double quantity = double.tryParse(_quantityController.text) ?? 0.0;

        if (fat <= 0 || snf <= 0 || quantity <= 0) {
          _showErrorDialog('fat_snf_qty_val_chk');
          return;
        }

        // Fetch price from Firebase
        double pricePerLiter = await getMilkPrice(fat, snf);
        double totalPrice = pricePerLiter * quantity;

        if (totalPrice == 0.0) {
          _showErrorDialog('no_price_fat_snf');
          return;
        }

        setState(() {
          _amountTextController.text = totalPrice.toStringAsFixed(2);
        });
      } else {
        if (_quantityController.text.isEmpty) {
          _showErrorDialog('please_enter_qty');
          return;
        }
      }
    }

    if (_amountTextController.text.isEmpty) {
      _showErrorDialog('please_enter_tot_income');
      return;
    }
    final DateTime now = DateTime.now();
    final data = Sale(
      saleId: '',
      farmId: widget.farmId,
      saleType: (_selectedCategory != 'Other')
          ? _selectedCategory.toString()
          : _categoryTextController.text,
      amount: double.parse(_amountTextController.text),
      saleDate: DateTime.parse(_dateController.text),
      createdAt: now,
      updatedAt: now,
    );

    final saleId = await _addIncome(data);
    if (mounted) {
      bool mSaleEntryNeeded =
          data.saleType.contains('Milk') &&
          (_quantityController.text.isNotEmpty ||
              (_fatController.text.isNotEmpty &&
                  _snfController.text.isNotEmpty));
      if (mSaleEntryNeeded) {
        final mSale = MilkSale(
          id: '',
          saleId: saleId,
          Fat: double.tryParse(_fatController.text),
          SNF: double.tryParse(_snfController.text),
          temperature: double.tryParse(_tmpController.text),
          quantity: double.parse(_quantityController.text),
        );
        dbSale.infoToServerMilkSale(mSale);
      } else {
        bool cSaleEntryNeeded =
            _cCntController.text.isNotEmpty || _selectedCList.isNotEmpty;

        if (cSaleEntryNeeded) {
          final cSale = CattleSale(
            id: '',
            saleId: saleId,
            cattleCount: int.parse(_cCntController.text),
            cattleIdsList: _selectedCList.join(','),
          );
          dbSale.infoToServerCattleSale(cSale);
        }
      }
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TransactionPage(farmId: widget.farmId, showIncome: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          '${currentLocalization['new_income']}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: '${currentLocalization['date_of_income']}',
                      hintText: 'YYYY-MM-DD',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 255, 255, 1),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: '${currentLocalization['select_income_type']}',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 255, 255, 1),
                    ),
                    items: sourceOptions.map((String source) {
                      return DropdownMenuItem<String>(
                        value: source,
                        child: Text('${currentLocalization[source]}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                if (_selectedCategory == 'Cattle Sale') ...[
                  _buildTextField(
                    _cCntController,
                    currentLocalization['num_cattle_sold'] ??
                        'No. of cattle sold',
                  ),
                  /*SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          for (Cattle ct in allCattle) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: const Color(0xFF0DA6BA),
                                  value: _selectedCList.contains(ct.cattleId),
                                  onChanged: (isSelected) {
                                    if (isSelected == true) {
                                      _selectedCList.add(ct.cattleId);
                                    } else if (isSelected == false) {
                                      _selectedCList.remove(ct.cattleId);
                                    }
                                    setState(() {});
                                  },
                                ),
                                Text(
                                  ct.nickName != null ? '${ct.cattleId} - ${ct.nickName}' : ct.cattleId
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),*/
                ],
                if (_selectedCategory == 'Milk Sale') ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBuyer,
                      decoration: InputDecoration(
                        labelText:
                            currentLocalization['Select Buyer'] ??
                            'Select Buyer',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 1),
                      ),
                      items: milkOptions.map((String buyer) {
                        return DropdownMenuItem<String>(
                          value: buyer,
                          child: Text(
                            currentLocalization[buyer.toLowerCase()] ?? buyer,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBuyer = value;
                        });
                      },
                    ),
                  ),
                  _buildTextField(
                    _quantityController,
                    currentLocalization['Quantity (Liters)'] ??
                        'Quantity (Liters)',
                  ),
                  _buildTextField(
                    _fatController,
                    currentLocalization['Fat Percentage'] ?? 'Fat Percentage',
                  ),
                  _buildTextField(
                    _snfController,
                    currentLocalization['SNF Percentage'] ?? 'SNF Percentage',
                  ),
                  _buildTextField(
                    _tmpController,
                    "${currentLocalization['temperature'] ?? 'Temperature'}${currentLocalization['optional']}",
                  ),
                  if (_selectedBuyer != 'D to C') ...[
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          _calculateMilkIncome();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: const Size(120, 50),
                          backgroundColor: const Color.fromRGBO(
                            13,
                            166,
                            186,
                            1.0,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 10,
                          // adjust elevation value as desired
                          side: const BorderSide(color: Colors.grey, width: 2),
                        ),
                        child: Text(
                          '${currentLocalization['Calculate']}',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
                if (_selectedCategory == 'Other')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1, 0, 1, 30),
                    child: TextFormField(
                      controller: _categoryTextController,
                      decoration: InputDecoration(
                        labelText: '${currentLocalization['enter_category']}',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 1),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                  child: TextFormField(
                    controller: _amountTextController,
                    keyboardType: TextInputType.number,
                    readOnly:
                        (_selectedCategory == 'Milk Sale' &&
                            _selectedBuyer != 'D to C')
                        ? true
                        : false,
                    decoration: InputDecoration(
                      labelText:
                          currentLocalization['Total Income'] ?? 'Total Income',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 1),
                    ),
                  ),
                ),

                // SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      _validateAndSubmit();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      minimumSize: const Size(120, 50),
                      backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
                      foregroundColor: Colors.white,
                      elevation: 10,
                      // adjust elevation value as desired
                      side: const BorderSide(color: Colors.grey, width: 2),
                    ),
                    child: Text(
                      '${currentLocalization['submit']}',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
