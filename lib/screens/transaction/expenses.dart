import 'package:farm_expense_mangement_app/models/feed.dart';
import 'package:farm_expense_mangement_app/models/transaction.dart';
import 'package:farm_expense_mangement_app/screens/transaction/transUtils.dart';
import 'package:farm_expense_mangement_app/screens/transaction/transactionpage.dart';
import 'package:farm_expense_mangement_app/services/database/feeddatabase.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../services/database/transactiondatabase.dart';
import '../../main.dart';

class AddExpenses extends StatefulWidget {
  final Function onSubmit;
  const AddExpenses({super.key, required this.onSubmit});

  @override
  State<AddExpenses> createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DatabaseForExpense dbExpense;
  late DatabaseServicesForFeed fdDB;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountTextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();
  final Map<String, TextEditingController> _qtyControllers = {};
  String? _selectedCategory;

  List<Feed> _feedTypes = [];
  final List<Feed> _selectedFeed = [];

  void _getFeedData() {
    fdCategoryId.forEach((fdType) async {
      final snapshot = await fdDB.infoFromServerForCategory(fdType);

      setState(() {
        List<Feed> feeds = snapshot.docs.map((doc) =>
            Feed.fromFireStore(doc,fdType)).toList();
        _feedTypes = _feedTypes + feeds;

        for (var fd in _feedTypes) {
          TextEditingController txtCntrlr = TextEditingController();
          _qtyControllers[fd.feedId ?? ""] = txtCntrlr;
        }
      });
    });

  }


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


  Future<void> _addExpense(Expense data) async {
    await dbExpense.infoFromServerExpenseOnDate(
        data.name, data.expenseOnMonth).then((doc) async {
      if (doc.exists) {
        data.value = data.value + doc['value'];
      }
      await dbExpense.infoToServerExpense(data);
      widget.onSubmit();
    });
  }

  @override
  void initState() {
    super.initState();
    dbExpense = DatabaseForExpense(uid: uid);
    fdDB = DatabaseServicesForFeed(uid);
    setState(() {
      _getFeedData();
    });
  }


  @override
  void dispose() {
    _dateController.dispose();
    _amountTextController.dispose();
    for (var txtCntrlr in _qtyControllers.values) {
      txtCntrlr.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider
        .of<AppData>(context)
        .persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    Map<String, String> categoryMap = {
      'Feed': currentLocalization['feed']!,
      'Veterinary': currentLocalization['Veterinary']!,
      'Labor Costs': currentLocalization['Labor Costs']!,
      'Equipment and Machinery':currentLocalization['Equipment and Machinery']!,
      'Other': currentLocalization['other']!,
    };

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
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return '${currentLocalization['please_choose_date']}';
                          }
                          else {
                            return null;
                          }
                        },
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
                      child: TransUtils.buildDropdown(
                        label: '${currentLocalization['select_expense_type']}*',
                        value: _selectedCategory != null ? categoryMap[_selectedCategory!] : null,
                        items: categoryMap.values.toList(),
                        onChanged: (selectedLocalizedValue) {
                          setState(() {
                            _selectedCategory = categoryMap.entries
                                .firstWhere((entry) => entry.value == selectedLocalizedValue)
                                .key;
                          });
                        },
                      ),
                    ),

                    if (_selectedCategory == 'Other')
                      Padding(
                          padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                          child: TransUtils.buildTextField(
                              _categoryTextController,
                              "${currentLocalization['enter_category']}")
                      ),
                    if (_selectedCategory == 'Feed')...[
                      Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(1, 0, 1, 10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(
                                      currentLocalization['sel_feed_consumption']??'',
                                      style: TextStyle(fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              4, 142, 161, 1.0)),),
                                  ]
                              )
                          ),
                          const SizedBox(height: 10),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25, width: MediaQuery.of(context).size.width * 0.95,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(12.0)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0, 20, 10, 20),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      if(_feedTypes.isEmpty)...[
                                        Text(currentLocalization['out_of_stock']??'',
                                            style: TextStyle(fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent))
                                      ]
                                      else
                                        ...[
                                          for (Feed item in _feedTypes)...[
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .start,
                                                children: [
                                                  Checkbox(
                                                      checkColor: Colors.white,
                                                      activeColor: const Color(
                                                          0xFF0DA6BA),
                                                      value: _selectedFeed
                                                          .contains(
                                                          item),
                                                      onChanged: (isSelected) {
                                                        if (isSelected ==
                                                            true) {
                                                          _selectedFeed.add(
                                                              item);
                                                        } else if (isSelected ==
                                                            false) {
                                                          _selectedFeed.remove(
                                                              item);
                                                        }
                                                        setState(() {});
                                                      }
                                                  ),
                                                  SizedBox(width: MediaQuery.of(context).size.width * 0.37,
                                                      child: Text('${currentLocalization['Type']}: ${currentLocalization[item
                                                          .feedType]??item.feedType} |\n${currentLocalization['Quantity']}: ${item
                                                          .quantity} ${currentLocalization['Kg']} |\n${currentLocalization['Rate']}: ₹${item
                                                          .ratePerKg} / ${currentLocalization['Kg']}')),
                                                  SizedBox(width: 20),
                                                  (_selectedFeed.contains(
                                                      item)) ?
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: _qtyControllers[item
                                                          .feedId],
                                                      autovalidateMode: AutovalidateMode
                                                          .onUserInteraction,
                                                      textAlign: TextAlign
                                                          .center,
                                                      decoration: InputDecoration(
                                                        labelText: currentLocalization['enter_qty_consumed_kg']??'',
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return currentLocalization['please_enter_value'] ??
                                                              "";
                                                        }
                                                        else if (item.quantity -
                                                            double.parse(
                                                                value) <
                                                            0) {
                                                          return currentLocalization['cannot_be_more_than_existing']??'';
                                                        }
                                                        else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ) : Text('')
                                                ]
                                            ),
                                            SizedBox(height: 20),
                                          ]
                                        ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        child:
                        TransUtils.buildElevatedButton(
                            currentLocalization['Calculate']??'Calculate',
                            onPressed: () => _calculateExpense()),
                      ),
                      SizedBox(height: 20),
                    ],
                    Padding(
                        padding: const EdgeInsets.fromLTRB(1, 0, 1, 20),
                        child: TransUtils.buildTextField(_amountTextController,
                            "${currentLocalization['how_much_did_you_spend']}",_selectedCategory == 'Feed' ? true : false)
                    ),

                    Container(
                      alignment: Alignment.center,
                      child:
                      TransUtils.buildElevatedButton(
                          '${currentLocalization['submit']}',
                          onPressed: () => _submitExpense()),
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

  Future<void> _submitExpense() async {

    if(_formKey.currentState!.validate()) {
      final data = Expense(
          name: (_selectedCategory.toString() != 'Other')
              ? _selectedCategory.toString()
              : _categoryTextController.text,
          value: double.parse(_amountTextController.text),
          expenseOnMonth:
          DateTime.parse(_dateController.text));

      await _addExpense(data);

      for (var feed in _selectedFeed) {
        var qty = double.parse(_qtyControllers[feed.feedId]!.text);
        _updateQuantityForFeed(feed, qty);
      }

      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context) =>
          const TransactionPage(
            showIncome: false,)));
    }

  }

  void _calculateExpense() {
    double totPrice = 0;
    if(_formKey.currentState!.validate()){
        for (var feed in _selectedFeed) {
            double qty = double.parse(_qtyControllers[feed.feedId]!.text);
            totPrice = totPrice + (qty*feed.ratePerKg);
        }
        _amountTextController.text = (totPrice.toPrecision(2)).toString();
    }

  }

  void _updateQuantityForFeed(Feed feed, double newQty) {

    if(feed.quantity - newQty == 0){
      //delete the feed if all the quantity is used up
      fdDB.deleteFeedFromServer(feed.category, feed.feedId!);
    }
    else{
      feed.quantity = feed.quantity - newQty;
      fdDB.infoToServerFeed(feed);
    }
  }
}
