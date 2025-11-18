import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/services/database/milkdatabase.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:farm_expense_mangement_app/screens/reports/reportsUtils.dart';
import 'package:farm_expense_mangement_app/services/database/transactiondatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logging.dart';
import '../../main.dart';
import '../../models/milk.dart';
import '../../models/transaction.dart';
import '../../services/localizationService.dart';
import '../../shared/constants.dart';
import '../wrappers/wrapperhome.dart';

class ReportsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReportsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentLocalization = {};
    String languageCode = 'en';

    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode]!;

    return AppBar(
      leading: BackButton(
        color: Colors.white,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WrapperHomePage()),
            ),
      ),
      centerTitle: true,
      title: Text(
        currentLocalization['reports'] ?? "Reports",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF0DA6BA),
      // Tealish Blue
      elevation: 4.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  final formKey = GlobalKey<FormState>();
  late List<File> currentFilesList = [];

  String? selectedReport;
  DateTime? startDate;
  DateTime? endDate;

  final log = logger(ReportsPage);

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month, now.day);
    deleteOlderReports(30);
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode]!;

    Map<String, String> reportTypesMap = {};
    for (var report in reportTypes) {
      reportTypesMap[report] = currentLocalization[report] ?? report;
    }

    currentFilesList.sort(
      (a, b) => (b.lastModifiedSync()).compareTo(a.lastModifiedSync()),
    );

    return Container(
      color: Colors.white60,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              ReportsUtils.buildDropdown(
                label: currentLocalization['report_type'] ?? "",
                value: selectedReport,
                items: reportTypesMap,
                valMsg: "",
                onChanged: (value) {
                  setState(() {
                    selectedReport = value!;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              ReportsUtils.buildInputBox(
                child: InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  child: ReportsUtils.buildTextFieldWithCalender(
                    label: currentLocalization['start_date'] ?? 'Start Date',
                    reqDate: startDate,
                    valMsg: currentLocalization['please_choose_date'] ?? '',
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ReportsUtils.buildInputBox(
                child: InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  child: ReportsUtils.buildTextFieldWithCalender(
                    label: currentLocalization['end_date'] ?? 'End Date',
                    reqDate: endDate,
                    valMsg: currentLocalization['please_choose_date'] ?? '',
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ReportsUtils.buildElevatedButton(
                  currentLocalization['generate_report'] ?? 'Generate Report',
                  onPressed: () {
                    if (selectedReport != null && selectedReport!.isNotEmpty) {
                      generateReport();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            currentLocalization['select_report_type'] ??
                                'Select Report',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 50.0),
              if (currentFilesList.isNotEmpty) ...[
                Center(
                  child: Text(
                    currentLocalization['reports_available'] ??
                        'Reports Available',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentFilesList.length,
                    itemBuilder: (context, index) {
                      final file = currentFilesList[index];
                      String fileName = file.path.split('/').last;
                      DateTime lastModDate = file.lastModifiedSync();
                      DateTime now = DateTime.now();
                      int timeDiff = now.difference(lastModDate).inSeconds;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color:
                                (timeDiff <= 2)
                                    ? Color.fromRGBO(177, 243, 238, 0.4)
                                    : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.5),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: Offset(5, 10),
                              ),
                            ],
                            border: BoxBorder.all(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await OpenFilex.open(file.path);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'asset/excelIcon2.jpg',
                                  width: 35,
                                  height: 35,
                                ),
                                Text(fileName, style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> generateReport() async {
    List<String> name = selectedReport!.split(' ');
    String reportName = '';

    for (var l in name) {
      reportName += l[0].toUpperCase() + l.substring(1);
    }

    String targetFileName =
        '${reportName}_${startDate.toString().split(' ')[0]}_to_${endDate.toString().split(' ')[0]}.xlsx';

    bool fileExists = currentFilesList.any(
      (file) => file.path.endsWith(targetFileName),
    );

    if (fileExists) {
      final snackBar = SnackBar(
        content: const Text('This report already exists!'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      var excelFile = Excel.createExcel();
      Sheet sheetObject;
      String uid = FirebaseAuth.instance.currentUser!.uid;

      if (selectedReport != 'milk production') {
        DatabaseForSale saleDB = DatabaseForSale(uid: uid);

        final snapshot = await saleDB.infoFromSaleByDateRange(
          startDate!,
          endDate!,
        );
        List<Sale> incomeTrans =
            snapshot.docs.map((doc) => Sale.fromFireStore(doc, null)).toList();

        if (selectedReport == 'transactions') {
          DatabaseForExpense expenseDB = DatabaseForExpense(uid: uid);

          final snapshotExp = await expenseDB.infoFromExpenseByDateRange(
            startDate!,
            endDate!,
          );
          List<Expense> expenseTrans =
              snapshotExp.docs
                  .map((doc) => Expense.fromFireStore(doc, null))
                  .toList();

          excelFile.rename('Sheet1', 'Transactions');
          sheetObject = excelFile['Transactions'];
          sheetObject.appendRow([
            TextCellValue('Transaction Date'),
            TextCellValue('Transaction Type'),
            TextCellValue('Category'),
            TextCellValue('Amount (₹)'),
          ]);

          List<TransRecord> totTrans = [];
          double totValue = 0;

          for (Sale trans in incomeTrans) {
            totTrans.add(
              TransRecord(
                transDate: trans.saleOnMonth!,
                transType: 'Income',
                category: trans.name,
                value: trans.value,
              ),
            );
            totValue += trans.value;
          }

          for (Expense trans in expenseTrans) {
            totTrans.add(
              TransRecord(
                transDate: trans.expenseOnMonth!,
                transType: 'Expense',
                category: trans.name,
                value: -trans.value,
              ),
            );
            totValue -= trans.value;
          }

          totTrans.sort((a, b) => (a.transDate).compareTo(b.transDate));

          for (var trans in totTrans) {
            sheetObject.appendRow([
              DateCellValue(
                year: trans.transDate.year,
                month: trans.transDate.month,
                day: trans.transDate.day,
              ),
              TextCellValue(trans.transType),
              TextCellValue(trans.category),
              DoubleCellValue(trans.value),
            ]);
          }
          sheetObject.appendRow([TextCellValue(' ')]);
          sheetObject.appendRow([
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue('Net Profit/Loss (₹)'),
            DoubleCellValue(totValue.toPrecision(2)),
          ]);
        } else {
          excelFile.rename('Sheet1', 'Milk Sale');
          sheetObject = excelFile['Milk Sale'];
          sheetObject.appendRow([
            TextCellValue('Milk Sale Date'),
            TextCellValue('Milk Sale Quantity (ltrs)'),
            TextCellValue('Milk Sale Income (₹)'),
          ]);

          List<Sale> milkSale =
              incomeTrans.where((trns) => trns.name == 'Milk Sale').toList()
                ..sort((a, b) => (a.saleOnMonth!).compareTo(b.saleOnMonth!));
          double totIncome = 0;

          for (var income in milkSale) {
            sheetObject.appendRow([
              DateCellValue(
                year: income.saleOnMonth?.year ?? 00,
                month: income.saleOnMonth?.month ?? 00,
                day: income.saleOnMonth?.day ?? 00,
              ),
              TextCellValue(income.quantity.toString()),
              DoubleCellValue(income.value),
            ]);
            totIncome += income.value;
          }

          sheetObject.appendRow([TextCellValue(' ')]);
          sheetObject.appendRow([
            TextCellValue(''),
            TextCellValue('Total Income (₹)'),
            DoubleCellValue(totIncome.toPrecision(2)),
          ]);
        }
      } else {
        DateTime dt = startDate!;
        DatabaseForMilk milkDB = DatabaseForMilk(uid);
        excelFile.rename('Sheet1', 'Milk Production');
        sheetObject = excelFile['Milk Production'];
        sheetObject.appendRow([
          TextCellValue('Milking Date'),
          TextCellValue('Milk Entry ID'),
          TextCellValue('Morning Milk (ltrs)'),
          TextCellValue('Evening Milk (ltrs)'),
          TextCellValue('Milk (Morning+Evening) (ltrs)'),
        ]);

        var futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
        while (dt.difference(endDate!).inDays <= 0) {
          futures.add(milkDB.infoFromServerAllMilk(dt));
          dt = dt.add(Duration(days: 1));
        }

        var results = await Future.wait(futures);
        List<Milk> milkTotList = [];
        double totMilk = 0;
        for (var res in results) {
          milkTotList.addAll(
            res.docs.map((doc) => Milk.fromFireStore(doc, null)).toList(),
          );
        }

        for (Milk m in milkTotList) {
          sheetObject.appendRow([
            DateCellValue(
              year: m.dateOfMilk!.year,
              month: m.dateOfMilk!.month,
              day: m.dateOfMilk!.day,
            ),
            TextCellValue(m.id),
            DoubleCellValue(m.morning),
            DoubleCellValue(m.evening),
            DoubleCellValue(m.morning + m.evening),
          ]);
          totMilk += (m.morning + m.evening);
        }

        sheetObject.appendRow([TextCellValue(' ')]);
        sheetObject.appendRow([
          TextCellValue(' '),
          TextCellValue(' '),
          TextCellValue(' '),
          TextCellValue('Total Milk (ltrs)'),
          DoubleCellValue(totMilk.toPrecision(2)),
        ]);
      }

      CellStyle headerStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 12,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#0DA6BA"), // Teal
        fontColorHex: ExcelColor.white, // White text
      );

      // Loop through cells of the header row and apply the style
      var firstSheet = excelFile.tables.keys.first;
      var firstRow = excelFile.tables[firstSheet]!.rows.first;

      for (int i = 0; i < firstRow.length; i++) {
        firstRow[i]?.cellStyle = headerStyle;
      }

      // Save Excel to bytes and then to a file
      final List<int>? bytes = excelFile.save();

      if (bytes != null && bytes.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final Directory reportsDir = Directory('${dir.path}/MyAppReports_$uid');
        if (!await reportsDir.exists()) {
          await reportsDir.create(recursive: true);
        }

        final filePath = '${reportsDir.path}/$targetFileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        setState(() {
          currentFilesList = reportsDir.listSync().whereType<File>().toList();
        });
      }
    }
  }

  Future<void> deleteOlderReports(int days) async {
    final dir = await getApplicationDocumentsDirectory();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final reportsDir = Directory('${dir.path}/MyAppReports_$uid');
    if (!await reportsDir.exists()) {
      setState(() {
        currentFilesList = [];
      });
      return;
    } else {
      final filesList = reportsDir.listSync().whereType<File>().toList();
      DateTime today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      for (final file in filesList) {
        DateTime lastModDate = file.lastModifiedSync();
        String fileName = file.path.split('/').last;
        if (today.difference(lastModDate).inDays > days) {
          await file.delete();
          log.i("Deleted older report $fileName !!", time: DateTime.now());
        }
      }
      setState(() {
        currentFilesList = reportsDir.listSync().whereType<File>().toList();
      });
    }
  }
}

class TransRecord {
  final DateTime transDate;
  final String transType;
  final String category;
  final double value;

  TransRecord({
    required this.transDate,
    required this.transType,
    required this.category,
    required this.value,
  });
}
