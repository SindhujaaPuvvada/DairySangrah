
import 'package:farm_expense_mangement_app/screens/transaction/transactionpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaction.dart';
import '../../services/database/transactiondatabase.dart';
import '../../main.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';

class AddIncome extends StatefulWidget {
  final Function onSubmit;
  const AddIncome({super.key, required this.onSubmit});

  @override
  State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DatabaseForSale dbSale;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountTextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();

  String? _selectedCategory;

  final List<String> sourceOptions = ['Cattle Sale', 'Milk Sale', 'Other'];

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

  // Future<void> _selectDate(BuildContext context) async {
  //   final List<String> months = [
  //     'January', 'February', 'March', 'April', 'May', 'June',
  //     'July', 'August', 'September', 'October', 'November', 'December'
  //   ];
  //
  //   final List<int> years = List.generate(100, (index) => DateTime.now().year - index);
  //
  //   String? selectedMonth = months[DateTime.now().month - 1];
  //   int? selectedYear = DateTime.now().year;
  //
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Select Month and Year'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButton<String>(
  //               value: selectedMonth,
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedMonth = value;
  //                 });
  //               },
  //               items: months.map((String month) {
  //                 return DropdownMenuItem<String>(
  //                   value: month,
  //                   child: Text(month),
  //                 );
  //               }).toList(),
  //             ),
  //             const SizedBox(height: 20),
  //             DropdownButton<int>(
  //               value: selectedYear,
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedYear = value;
  //                 });
  //               },
  //               items: years.map((int year) {
  //                 return DropdownMenuItem<int>(
  //                   value: year,
  //                   child: Text('$year'),
  //                 );
  //               }).toList(),
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               final String? monthName = selectedMonth;
  //               final int? year = selectedYear;
  //               _dateController.text = '$monthName-$year';
  //
  //               // Do something with the selected month and year
  //               // print('Selected Month: $monthName');
  //               // print('Selected Year: $year');
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbSale = DatabaseForSale(uid: uid);
  }

  void _addIncome(Sale data) {
    dbSale.infoToServerSale(data);

    widget.onSubmit;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountTextController.dispose();
    _categoryTextController.dispose();

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
          '${currentLocalization['new_income']}',
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
                height: 5,
              ),

              const SizedBox(height: 10,),

              Form(
                key: _formKey,
                child: Expanded(
                  child: ListView(children: [
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
                    // SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _amountTextController,
                        decoration:  InputDecoration(
                          labelText: '${currentLocalization['how_much_did_you_earn']}',
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
                        decoration:  InputDecoration(
                          labelText: '${currentLocalization['select_income_type']}',
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
                          decoration:  InputDecoration(
                            labelText: '${currentLocalization['enter_category']}',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(240, 255, 255, 1),

                          )
                        )
                      ),

                    // SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(

                        onPressed: () {
                          final data = Sale(
                              name: (_selectedCategory.toString() != 'Other')
                                  ? _selectedCategory.toString()
                                  : _categoryTextController.text,
                              value: double.parse(_amountTextController.text),
                              saleOnMonth:
                                  DateTime.tryParse(_dateController.text));
                          _addIncome(data);
                          Navigator.pop(context);
    Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (context) => const TransactionPage(showIncome: true,)));

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
                        child:  Text(
                          '${currentLocalization['submit']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
    ),
                      ),

                  ]
    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
