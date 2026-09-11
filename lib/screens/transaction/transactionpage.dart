import 'package:farm_expense_mangement_app/models/sales.dart';
import 'package:farm_expense_mangement_app/screens/transaction/edittransaction.dart';
import 'package:farm_expense_mangement_app/services/database/transactiondatabase.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../models/expenses.dart';
import '../wrappers/wrapperhome.dart';
import 'expenses.dart';
import 'income.dart';
import '../../main.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';

class TransactionPage extends StatefulWidget {
  final String farmId;
  final bool showIncome; // New parameter
  const TransactionPage({
    super.key,
    required this.showIncome,
    required this.farmId,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  late DbForSale dbSale;
  late DbForExpense dbExpense;

  bool showIncome = true;
  List<Sale> incomeTransactions = [];
  List<Expense> expenseTransactions = [];

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> _fetchIncome() async {
    final snapshot = await dbSale.infoFromServerAllTransactions(widget.farmId);
    setState(() {
      incomeTransactions = snapshot
          .map((r) => Sale.fromDB(r))
          .where(
            (sale) =>
                (selectedStartDate == null ||
                    sale.saleDate.isAfter(
                      selectedStartDate!.add(Duration(days: -1)),
                    )) &&
                (selectedEndDate == null ||
                    sale.saleDate.isBefore(
                      selectedEndDate!.add(Duration(days: 1)),
                    )),
          )
          .toList();
    });
  }

  Future<void> _fetchExpense() async {
    final snapshot = await dbExpense.infoFromServerAllTransactions(
      widget.farmId,
    );
    setState(() {
      expenseTransactions = snapshot
          .map((r) => Expense.fromDB(r))
          .where(
            (expense) =>
                (selectedStartDate == null ||
                    expense.expenseDate.isAfter(
                      selectedStartDate!.add(Duration(days: -1)),
                    )) &&
                (selectedEndDate == null ||
                    expense.expenseDate.isBefore(
                      selectedEndDate!.add(Duration(days: 1)),
                    )),
          )
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    dbSale = DbForSale();
    dbExpense = DbForExpense();
    showIncome = widget.showIncome; // Set showIncome based on the parameter
    _fetchIncome();
    _fetchExpense();
  }

  Color filterColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WrapperHomePage()),
          ),
        ),
        backgroundColor: const Color.fromRGBO(13, 152, 186, 1.0),
        title: Text(
          currentLocalization['transactions'] ?? "",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined, color: Colors.black),
            onPressed: () async {
              await _showDateRangePicker(context);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.attach_money, color: Colors.black),
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
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                setState(() {
                  selectedStartDate = null;
                  selectedEndDate = null;
                  _fetchIncome();
                  _fetchExpense();
                });
              },
            ),
          ),
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
                            ? [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 1),
                                  blurRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          currentLocalization['income'] ?? "",
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
                        boxShadow: showIncome
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          currentLocalization['expenses'] ?? "",
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
                ? ListTileForSale(
                    farmId: widget.farmId,
                    data: incomeTransactions,
                  )
                : ListTileForExpense(
                    farmId: widget.farmId,
                    data: expenseTransactions,
                  ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
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
                          farmId: widget.farmId,
                        )
                      : AddExpenses(
                          onSubmit: () {
                            _fetchIncome();
                            _fetchExpense();
                          },
                          farmId: widget.farmId,
                        ),
                ),
              );
            },
            backgroundColor: const Color.fromRGBO(13, 166, 186, 1),
            tooltip: currentLocalization['add_transaction'],
            child: const Icon(Icons.add, color: Colors.black),
          );
        },
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
  final String farmId;
  final List<Sale> data;
  const ListTileForSale({super.key, required this.data, required this.farmId});

  @override
  State<ListTileForSale> createState() => _ListTileForSaleState();
}

class _ListTileForSaleState extends State<ListTileForSale> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final sale = widget.data[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 5, 8, 2),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.green.shade500.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                sale.saleType == "Milk Sale"
                    ? currentLocalization['milk_sale'] ?? ''
                    : sale.saleType == "Cattle Sale"
                    ? currentLocalization['cattle_sale'] ?? ''
                    : sale.saleType,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${currentLocalization['amount']}:  ${sale.amount.toStringAsFixed(2)}| ${currentLocalization['on_date']}: ${sale.saleDate.day}-${sale.saleDate.month}-${sale.saleDate.year}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTransaction(
                        farmId: widget.farmId,
                        showIncome: true,
                        sale: sale,
                        expense: null,
                      ),
                    ),
                  );
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
  final String farmId;
  final List<Expense> data;
  const ListTileForExpense({
    super.key,
    required this.data,
    required this.farmId,
  });

  @override
  State<ListTileForExpense> createState() => _ListTileForExpenseState();
}

class _ListTileForExpenseState extends State<ListTileForExpense> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final expense = widget.data[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 5, 8, 2),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.red.shade500.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                expense.expenseType != "Feed" &&
                        expense.expenseType != "Veterinary" &&
                        expense.expenseType != "Labor Costs" &&
                        expense.expenseType != "Equipment and Machinery"
                    ? expense.expenseType
                    : currentLocalization[expense.expenseType] ?? '',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${currentLocalization['amount']}:  ${expense.amount.toStringAsFixed(2)}| ${currentLocalization['on_date']}: ${expense.expenseDate.day}-${expense.expenseDate.month}-${expense.expenseDate.year}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTransaction(
                        farmId: widget.farmId,
                        showIncome: false,
                        sale: null,
                        expense: expense,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class TotalTransactionPage extends StatefulWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final List<Sale> incomeTransactions;
  final List<Expense> expenseTransactions;

  const TotalTransactionPage({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  @override
  State<TotalTransactionPage> createState() => _TotalTransactionPageState();
}

class _TotalTransactionPageState extends State<TotalTransactionPage> {
  late Map<String, dynamic> currentLocalization = {};

  late String languageCode = 'en';

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    // Calculate total income
    final totalIncome = widget.incomeTransactions
        .where(
          (sale) =>
              (widget.selectedStartDate == null ||
                  sale.saleDate.isAfter(
                    widget.selectedStartDate!.add(Duration(days: -1)),
                  )) &&
              (widget.selectedEndDate == null ||
                  sale.saleDate.isBefore(
                    widget.selectedEndDate!.add(Duration(days: 1)),
                  )),
        )
        .map((sale) => sale.amount)
        .fold<double>(0, (prev, amount) => prev + amount);

    // Calculate total expense
    final totalExpense = widget.expenseTransactions
        .where(
          (expense) =>
              (widget.selectedStartDate == null ||
                  expense.expenseDate.isAfter(
                    widget.selectedStartDate!.add(Duration(days: -1)),
                  )) &&
              (widget.selectedEndDate == null ||
                  expense.expenseDate.isBefore(
                    widget.selectedEndDate!.add(Duration(days: 1)),
                  )),
        )
        .map((expense) => expense.amount)
        .fold<double>(0, (prev, amount) => prev + amount);

    // Calculate net profit
    final netProfit = totalIncome - totalExpense;

    // Calculate total income per category
    final Map<String, double> incomePerCategory = {};
    for (final transaction in widget.incomeTransactions) {
      final category = transaction.saleType;
      incomePerCategory[category] =
          (incomePerCategory[category] ?? 0) + transaction.amount;
    }

    // Calculate total expense per category
    final Map<String, double> expensePerCategory = {};
    for (final transaction in widget.expenseTransactions) {
      final category = transaction.expenseType;
      expensePerCategory[category] =
          (expensePerCategory[category] ?? 0) + transaction.amount;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 152, 186, 1.0),
        title: Text(
          currentLocalization['total_transactions'] ?? '',
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
              '${currentLocalization["date_range"]} ${widget.selectedStartDate != null ? "${widget.selectedStartDate!.day}/${widget.selectedStartDate!.month}/${widget.selectedStartDate!.year}" : "${currentLocalization['start']}"} - ${widget.selectedEndDate != null ? "${widget.selectedEndDate!.day}/${widget.selectedEndDate!.month}/${widget.selectedEndDate!.year}" : "${currentLocalization['end']}"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              '${currentLocalization["total_income"]}: ₹${totalIncome.toPrecision(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${currentLocalization["income_per_category"]}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...incomePerCategory.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key != "Milk Sale" && entry.key != "Cattle Sale" ? entry.key : currentLocalization[entry.key]}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              '${currentLocalization["total_expense"]}: ₹${totalExpense.toPrecision(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${currentLocalization["expense_per_category"]}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...expensePerCategory.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key != "Feed" &&
                              entry.key != "Veterinary" &&
                              entry.key != "Labor Costs" &&
                              entry.key != "Equipment and Machinery"
                          ? entry.key
                          : currentLocalization[entry.key] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              netProfit >= 0
                  ? '${currentLocalization['net_profit']}:  ₹${netProfit.toPrecision(2)}'
                  : '${currentLocalization['net_loss']}:  ₹${netProfit.toPrecision(2)}',
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
