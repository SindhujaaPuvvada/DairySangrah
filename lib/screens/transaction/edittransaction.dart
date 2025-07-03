import 'package:farm_expense_mangement_app/models/transaction.dart';
import 'package:farm_expense_mangement_app/screens/transaction/transactionpage.dart';
import 'package:farm_expense_mangement_app/services/database/transactiondatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';

class EditTransaction extends StatefulWidget {
  final bool showIncome;
  final Sale? sale;
  final Expense? expense;
  const EditTransaction({super.key,required this.showIncome,this.sale,this.expense});

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryTransaction;
  late TextEditingController _valueController;

  late DatabaseForSale _dbSale;
  late DatabaseForExpense _dbExpense;
  
  late DateTime _dateOfTransaction;
  
  @override
  initState() {
    super.initState();
    _dbSale = DatabaseForSale(uid: uid);
    _dbExpense = DatabaseForExpense(uid: uid);
    if(widget.showIncome) {
      _categoryTransaction = TextEditingController(text: widget.sale?.name);
      _valueController = TextEditingController(text: widget.sale?.value.toString());
      _dateOfTransaction = widget.sale?.saleOnMonth ?? DateTime.now();
    } else {
      _categoryTransaction = TextEditingController(text: widget.expense?.name);
      _valueController = TextEditingController(text: widget.expense?.value.toString());
      _dateOfTransaction = widget.expense?.expenseOnMonth ?? DateTime.now();
    }
  }
  
  Future<void> editTransactionDatabase() async {
    if(_formKey.currentState!.validate()){
      if (widget.showIncome) {
        final sale = Sale(
            name: _categoryTransaction.text,
            value: double.parse(_valueController.text),
            saleOnMonth: widget.sale?.saleOnMonth);
        return await _dbSale.infoToServerSale(sale);
      } else {
        final expense = Expense(
            name: _categoryTransaction.text,
            value: double.parse(_valueController.text),
            expenseOnMonth: widget.expense?.expenseOnMonth);
        return await _dbExpense.infoToServerExpense(expense);
      }
    }
  }
  Future<void> deleteSaleDatabase() async {
    await _dbSale.deleteSaleFromServer(widget.sale!);

  }

  Future<void> deleteExpenseDatabase() async {
    await _dbExpense.deleteExpenseFromServer(widget.expense!);

  }

  void _submitForm(BuildContext context) {
    editTransactionDatabase();

    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => TransactionPage(showIncome: widget.showIncome)));

    // Check if the transaction date is in future
    if (_dateOfTransaction.isAfter(DateTime.now())) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select a valid date.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    // }
      // else {
    //   editTransactionDatabase();
    //   Navigator.pop(context);
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransactionPage(showIncome: widget.showIncome)));
    }
  }

  void _deleteTransaction(BuildContext context) {
    if(widget.showIncome) {
      deleteSaleDatabase();
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransactionPage(showIncome: widget.showIncome)));
    }
    else {
      deleteExpenseDatabase();
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransactionPage(showIncome: widget.showIncome)));
    }

  }



  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        title: Text(
          (widget.showIncome) ? '${currentLocalization['edit_income']}' : '${currentLocalization['edit_expense']}',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  readOnly: true,
                  enabled: false,
                  style:  TextStyle(fontSize: 20, color: Colors.black),
                  // controller: _categoryTransaction,
                    initialValue:(widget.showIncome) ? '${currentLocalization[widget.sale?.name]??widget.sale?.name}' : '${currentLocalization[widget.expense?.name]??widget.expense?.name}',
                  decoration: InputDecoration(
                      labelText: (widget.showIncome) ? '${currentLocalization['income_category']}' : '${currentLocalization['expense_category']}',
                      labelStyle: const TextStyle(fontSize: 20, color: Colors.black)),

                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  readOnly: true,
                  enabled: false,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  initialValue: '${_dateOfTransaction.year}-${_dateOfTransaction.month}-${_dateOfTransaction.day}',
                  decoration: InputDecoration(
                      labelText: '${currentLocalization['transaction_date']}',
                      labelStyle: TextStyle(fontSize: 20, color: Colors.black)),

                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(labelText: '${currentLocalization['enter_transaction_amount']}'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return currentLocalization['please_enter_value']??'';
                    }
                    if (double.tryParse(value) == null) {
                      return currentLocalization['enter_valid_number']??'';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _deleteTransaction(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromRGBO(13, 166, 186, 0.9)),
                    ),
                    child: Text(
                        currentLocalization['delete']??"",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromRGBO(13, 166, 186, 0.9)),
                    ),
                    child: Text(
                      currentLocalization['save']??"",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
