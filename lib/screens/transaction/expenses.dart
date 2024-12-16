import 'package:farm_expense_mangement_app/models/transaction.dart';
import 'package:farm_expense_mangement_app/screens/transaction/transactionpage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/database/transactiondatabase.dart';
import '../../main.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';

class AddExpenses extends StatefulWidget {
  final Function onSubmit;
  const AddExpenses({super.key, required this.onSubmit});

  @override
  State<AddExpenses> createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DatabaseForExpense dbExpanse;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountTextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();
  String? _selectedCategory;

  final List<String> sourceOptions = [
    'Feed',
    'Veterinary',
    'Labor Costs',
    'Equipment and Machinery',
    'Other'
  ];

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
    // TODO: implement initState
    super.initState();
    dbExpanse = DatabaseForExpense(uid: uid);
  }

  void _addExpense(Expense data) {
    dbExpanse.infoToServerExpanse(data);
    widget.onSubmit;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    if (languageCode == 'en') {
      currentLocalization = LocalizationEn.translations;
    } else if (languageCode == 'hi') {
      currentLocalization = LocalizationHi.translations;
    } else if (languageCode == 'pa') {
      currentLocalization = LocalizationPun.translations;
    }
    return Scaffold(

      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        title: Text(
          '${currentLocalization['new_expense']}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          child: Column(
            children: [

              const SizedBox(
                height: 15,
              ),
              Form(
                key: _formKey,
                child: Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: '${currentLocalization['date_of_expense']}',
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
                    // SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _amountTextController,
                        decoration: InputDecoration(
                          labelText: '${currentLocalization['how_much_did_you_spend']}',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color.fromRGBO(240, 255, 255, 1),

                        ),
                      ),
                    ),
                    // SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: '${currentLocalization['select_expense_type']}*',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color.fromRGBO(240, 255, 255, 1),

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

                    // SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          final data = Expense(
                              name: (_selectedCategory.toString() != 'Other')
                                  ? _selectedCategory.toString()
                                  : _categoryTextController.text,
                              value: double.parse(_amountTextController.text),
                              expenseOnMonth:
                                  DateTime.parse(_dateController.text));
                          _addExpense(data);
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => const TransactionPage(showIncome: false,)));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          minimumSize: const Size(120, 50),
                          backgroundColor:
                              const Color.fromRGBO(13, 166, 186, 1.0),
                          foregroundColor: Colors.white,
                          elevation: 10, // adjust elevation value as desired
                          side: const BorderSide(color: Colors.grey, width: 2),
                        ),
                        child: Text(
                          '${currentLocalization['submit']}',
                          style: TextStyle(
                            color:Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
