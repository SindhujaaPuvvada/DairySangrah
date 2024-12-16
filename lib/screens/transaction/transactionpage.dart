import 'package:farm_expense_mangement_app/models/transaction.dart';
import 'package:farm_expense_mangement_app/screens/transaction/edittransaction.dart';
import 'package:farm_expense_mangement_app/services/database/transactiondatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expenses.dart';
import 'income.dart';
import '../../main.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';

class TransactionPage extends StatefulWidget {

  final bool showIncome; // New parameter
  const TransactionPage({super.key, required this.showIncome});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DatabaseForSale dbSale;
  late DatabaseForExpense dbExpanse;

  bool showIncome = true;
  List<Sale> incomeTransactions = [];
  List<Expense> expenseTransactions = [];

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> _fetchIncome() async {
    final snapshot = await dbSale.infoFromServerAllTransaction();
    setState(() {
      incomeTransactions = snapshot.docs
          .map((doc) => Sale.fromFireStore(doc, null))
          .where((sale) =>
      (selectedStartDate == null ||
          sale.saleOnMonth!.isAfter(selectedStartDate!)) &&
          (selectedEndDate == null ||
              sale.saleOnMonth!.isBefore(selectedEndDate!)))
          .toList();
    });
  }

  Future<void> _fetchExpense() async {
    final snapshot = await dbExpanse.infoFromServerAllTransaction();
    setState(() {
      expenseTransactions = snapshot.docs
          .map((doc) => Expense.fromFireStore(doc, null))
          .where((expense) =>
      (selectedStartDate == null ||
          expense.expenseOnMonth!.isAfter(selectedStartDate!)) &&
          (selectedEndDate == null ||
              expense.expenseOnMonth!.isBefore(selectedEndDate!)))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    dbSale = DatabaseForSale(uid: uid);
    dbExpanse = DatabaseForExpense(uid: uid);
    showIncome = widget.showIncome; // Set showIncome based on the parameter
    _fetchIncome();
    _fetchExpense();
  }

  Color filterColor = Colors.black;

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
        backgroundColor: const Color.fromRGBO(13, 152, 186, 1.0),
        title:  Text(
          currentLocalization['transactions']??"",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_outlined,
              color: Colors.black,
            ),
            onPressed: () async {
              await _showDateRangePicker(context);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.attach_money,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigate to the page displaying total income, total sale, and net profit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TotalTransactionPage(
                    selectedStartDate: selectedStartDate,
                    selectedEndDate: selectedEndDate,
                    incomeTransactions: incomeTransactions,
                    expenseTransactions: expenseTransactions,
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: selectedStartDate != null || selectedEndDate != null,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
              color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  selectedStartDate = null;
                  selectedEndDate = null;
                  _fetchIncome();
                  _fetchExpense();
                });
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showIncome = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: showIncome
                            ? Colors.blueGrey[100]
                            : const Color.fromRGBO(240, 255, 255, 0.9),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        boxShadow: showIncome
                            ? [BoxShadow(color: Colors.grey.withOpacity(1), blurRadius: 4)]
                            : [],
                      ),
                      child:  Center(
                        child: Text(
                          currentLocalization['income']??"",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showIncome = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: showIncome
                            ? const Color.fromRGBO(240, 255, 255, 0.9)
                            : Colors.blueGrey[100],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        boxShadow: showIncome ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 4)],
                      ),
                      child:  Center(
                        child: Text(
                          currentLocalization['expenses']??"",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (showIncome)
                ? ListTileForSale(data: incomeTransactions)
                : ListTileForExpense(data: expenseTransactions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => (showIncome)
                  ? AddIncome(
                onSubmit: () {
                  _fetchIncome();
                  _fetchExpense();
                },
              )
                  : AddExpenses(
                onSubmit: () {
                  _fetchIncome();
                  _fetchExpense();
                },
              ),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1),
        tooltip: 'Add Transaction',
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: selectedStartDate != null && selectedEndDate != null
          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
          : null,
    );
    if (picked != null) {
      selectedStartDate = picked.start;
      selectedEndDate = picked.end;
      _fetchIncome();
      _fetchExpense();
    }
  }
}

class ListTileForSale extends StatefulWidget {
  final List<Sale> data;
  const ListTileForSale({super.key, required this.data});

  @override
  State<ListTileForSale> createState() => _ListTileForSaleState();
}

class _ListTileForSaleState extends State<ListTileForSale> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';
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
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final sale = widget.data[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 5, 8, 2),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.green.shade500.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                sale.name == "Milk Sale"
                    ? currentLocalization['milk_sale'] ?? ''
                    : sale.name == "Cattle Sale"
                    ? currentLocalization['cattle_sale'] ?? ''
                    : sale.name ?? '',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${currentLocalization['amount']}:  ${sale.value.toStringAsFixed(2)}| ${currentLocalization['on_date']}: ${sale.saleOnMonth?.day}-${sale.saleOnMonth?.month}-${sale.saleOnMonth?.year}',
                style:  TextStyle(color: Colors.grey[800]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditTransaction(showIncome: true,sale: sale,expense: null,)));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ListTileForExpense extends StatefulWidget {
  final List<Expense> data;
  const ListTileForExpense({super.key, required this.data});

  @override
  State<ListTileForExpense> createState() => _ListTileForExpenseState();
}

class _ListTileForExpenseState extends State<ListTileForExpense> {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';
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
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final expense = widget.data[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 5, 8, 2),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.red.shade500.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                expense.name != "Feed" && expense.name != "Veterinary" && expense.name != "Labor Costs"&& expense.name != "Equipment and Machinery"
                    ? expense.name ?? ''
                    : currentLocalization[expense.name] ?? '',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${currentLocalization['amount']}:  ${expense.value.toStringAsFixed(2)}| ${currentLocalization['on_date']}: ${expense.expenseOnMonth?.day}-${expense.expenseOnMonth?.month}-${expense.expenseOnMonth?.year}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditTransaction(showIncome: false,sale: null,expense: expense,)));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class TotalTransactionPage extends StatelessWidget {
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final List<Sale> incomeTransactions;
  final List<Expense> expenseTransactions;

   TotalTransactionPage({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.incomeTransactions,
    required this.expenseTransactions,

  });


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
    // Calculate total income
    final totalIncome = incomeTransactions
        .where((sale) =>
    (selectedStartDate == null ||
        sale.saleOnMonth!.isAfter(selectedStartDate!)) &&
        (selectedEndDate == null ||
            sale.saleOnMonth!.isBefore(selectedEndDate!)))
        .map((sale) => sale.value)
        .fold<double>(0, (prev, amount) => prev + amount);

    // Calculate total expense
    final totalExpense = expenseTransactions
        .where((expense) =>
    (selectedStartDate == null ||
        expense.expenseOnMonth!.isAfter(selectedStartDate!)) &&
        (selectedEndDate == null ||
            expense.expenseOnMonth!.isBefore(selectedEndDate!)))
        .map((expense) => expense.value)
        .fold<double>(0, (prev, amount) => prev + amount);

    // Calculate net profit
    final netProfit = totalIncome - totalExpense;

    // Calculate total income per category
    final Map<String, double> incomePerCategory = {};
    for (final transaction in incomeTransactions) {
      final category = transaction.name;
      incomePerCategory[category] = (incomePerCategory[category] ?? 0) + transaction.value;
    }

    // Calculate total expense per category
    final Map<String, double> expensePerCategory = {};
    for (final transaction in expenseTransactions) {
      final category = transaction.name;
      expensePerCategory[category] = (expensePerCategory[category] ?? 0) + transaction.value;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 152, 186, 1.0),
        title:  Text(
          currentLocalization['total_transactions']??'',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(240, 255, 255, 1),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${currentLocalization["date_range"]} ${selectedStartDate != null ? "${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}" : "Start"} - ${selectedEndDate != null ? "${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}" : "End"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              '${currentLocalization["total_income"]}: ₹$totalIncome',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 7),
             Text(
              '${currentLocalization["income_per_category"]}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...incomePerCategory.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${entry.key != "Milk Sale" && entry.key != "Cattle Sale"? entry.key : currentLocalization[entry.key]}' ,
                      style: const TextStyle(fontSize: 14)),
                  Text('₹${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
            const SizedBox(height: 25),
            Text(
              '${currentLocalization["total_expense"]}: ₹$totalExpense',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 7),
             Text(
              '${currentLocalization["expense_per_category"]}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...expensePerCategory.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key!= "Feed" && entry.key != "Veterinary" && entry.key != "Labor Costs"&& entry.key != "Equipment and Machinery"
                          ? entry.key ?? ''
                          : currentLocalization[entry.key] ?? '',
                      style: const TextStyle(fontSize: 14)),
                  Text('₹${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
            const SizedBox(height: 30),
            Text(
              netProfit>=0?
              '${currentLocalization['net_profit']}: ₹$netProfit':
    '${currentLocalization['net_loss']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,

                color: netProfit >= 0 ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
