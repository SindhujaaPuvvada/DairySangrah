import 'package:farm_expense_mangement_app/models/cattlegroups.dart';
import 'package:farm_expense_mangement_app/screens/analytics/analyticsUtils.dart';
import 'package:farm_expense_mangement_app/services/database/cattledatabase.dart';
import 'package:farm_expense_mangement_app/services/database/cattlegroupsdatabase.dart';
import 'package:farm_expense_mangement_app/services/database/feeddatabase.dart';
import 'package:farm_expense_mangement_app/services/database/milkdatabase.dart';
import 'package:farm_expense_mangement_app/services/database/transactiondatabase.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../logging.dart';
import '../../main.dart';
import '../../models/cattle.dart';
import '../../services/localizationService.dart';
import '../wrappers/wrapperhome.dart';

class AnalyticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnalyticsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentLocalization = {};
    String languageCode = 'en';

    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};

    return AppBar(
      leading: BackButton(
        color: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WrapperHomePage()),
        ),
      ),
      centerTitle: true,
      title: Text(
        currentLocalization['farm_analytics'] ?? "Farm Analytics",
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

class AnalyticsPage extends StatefulWidget {
  final String farmId;
  final String? viewType;
  final String? viewId;
  final String? bucket;

  const AnalyticsPage({
    super.key,
    required this.farmId,
    this.viewType,
    this.viewId,
    this.bucket,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';
  Map<String, String> allCattle = {};
  Map<String, String> allGroups = {};
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> milkProdChartData = [];
  List<Map<String, dynamic>> milkSaleChartData = [];
  List<Map<String, dynamic>> feedChartData = [];
  List<Map<String, dynamic>> transactionChartData = [];
  Map<String, dynamic>? milkProdAggregates = {};
  Map<String, String> showMilkSalesTypes = {};
  String selectedViewType = 'Whole-farm';
  String? selectedViewId;
  String? selectedDateRange = '7D';
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();

  final log = logger(AnalyticsPage);

  double? chartMinX;
  double? chartMinY;
  double? chartMaxX;
  double? chartMaxY;

  String selectedSection = 'Milk';
  String showMilkSaleIn = 'ltr';
  List<String> uniqueDates = [];

  @override
  void initState() {
    super.initState();
    selectedViewType = widget.viewType ?? selectedViewType;
    selectedViewId = widget.viewId ?? selectedViewId;
    List<Future> futures = [];

    futures.add(
      _fetchMilkProdChartData(
        selectedViewType,
        selectedViewId ?? '0',
        startDate,
        endDate,
      ),
    );
    futures.add(_fetchMilkSaleChartData(startDate, endDate));
    futures.add(
      _fetchMilkAggregates(
        selectedViewType,
        selectedViewId ?? '0',
        startDate,
        endDate,
      ),
    );
    futures.add(_fetchTransactionChartData(startDate, endDate));
    futures.add(_fetchFeedChartData(startDate, endDate));
    futures.add(_fetchAllGroups());
    futures.add(_fetchAllCattle());

    Future.wait(futures);
  }

  Future<void> _fetchAllGroups() async {
    final snapshot = await DbServicesForCattleGroups()
        .infoFromServerAllCattleGrps(widget.farmId);
    final allGroupsData = snapshot.map((r) => CattleGroup.fromDB(r)).toList();
    for (CattleGroup grp in allGroupsData) {
      allGroups.addAll({grp.grpId: "${grp.state}-${grp.breed ?? grp.type}"});
    }
    setState(() {
      allGroups;
    });
  }

  Future<void> _fetchAllCattle() async {
    final snapshot = await DbServicesForCattle().infoFromServerAllCattle(
      widget.farmId,
    );
    final allCattleData = snapshot.map((r) => Cattle.fromDB(r)).toList();
    for (Cattle c in allCattleData) {
      allCattle.addAll({c.cattleId: c.nickName ?? c.cattleId});
    }
    setState(() {
      allCattle;
    });
  }

  Future<void> _fetchMilkProdChartData(
    String viewType,
    String viewId,
    DateTime start,
    DateTime end,
  ) async {
    milkProdChartData = await DbServicesForMilk().getMilkLCSpots(
      viewType,
      viewId,
      widget.farmId,
      start,
      end,
    );
    setState(() {
      milkProdChartData;
    });
  }

  Future<void> _fetchMilkSaleChartData(DateTime start, DateTime end) async {
    milkSaleChartData = await DbServicesForMilk().getMilkSaleBCData(
      widget.farmId,
      start,
      end,
    );
    setState(() {
      milkSaleChartData;
    });
  }

  Future<void> _fetchTransactionChartData(DateTime start, DateTime end) async {
    transactionChartData = await DbForTransactions().getTransactionData(
      widget.farmId,
      start,
      end,
    );
    setState(() {
      transactionChartData;
    });
  }

  Future<void> _fetchFeedChartData(DateTime start, DateTime end) async {
    feedChartData = await DbServicesForFeed().getFeedCostByCategory(
      widget.farmId,
      start,
      end,
    );
    setState(() {
      feedChartData;
    });
  }

  Future<void> _fetchMilkAggregates(
    String viewType,
    String viewId,
    DateTime start,
    DateTime end,
  ) async {
    milkProdAggregates = await DbServicesForMilk().getMilkAggregates(
      viewType,
      viewId,
      widget.farmId,
      start,
      end,
    );
    setState(() {
      milkProdAggregates;
    });
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    currentLocalization = Localization().translations[languageCode] ?? {};
    Map<String, String> milkLevelTypesMap = {};
    for (var levType in milkReportLevels) {
      milkLevelTypesMap[levType] = currentLocalization[levType] ?? levType;
    }

    showMilkSalesTypes = {
      'ltr': currentLocalization['Litres'],
      'amount': currentLocalization['amount'],
    };

    return Column(
      children: [
        // The Row for the three sections
        Row(
          children: [
            Expanded(
              child: sectionButton('Milk', () {
                List<Future> futures = [];
                futures.add(
                  _fetchMilkAggregates(
                    selectedViewType,
                    selectedViewId ?? '0',
                    startDate,
                    endDate,
                  ),
                );
                futures.add(
                  _fetchMilkProdChartData(
                    selectedViewType,
                    selectedViewId ?? '0',
                    startDate,
                    endDate,
                  ),
                );
                Future.wait(futures);
              }),
            ),
            Expanded(
              child: sectionButton(
                'Feed',
                () => _fetchFeedChartData(startDate, endDate),
              ),
            ),
            Expanded(
              child: sectionButton('Transactions', (() {
                List<Future> futures = [];
                futures.add(_fetchMilkSaleChartData(startDate, endDate));
                futures.add(_fetchTransactionChartData(startDate, endDate));
                Future.wait(futures);
              })),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Display content based on the selected section
        Expanded(child: displaySelectedSectionContent(farmId: widget.farmId)),
      ],
    );
  } // Helper method to create a section button

  Widget sectionButton(String sectionName, Function() dataLoaderFunc) {
    final isSelected = selectedSection == sectionName;
    return GestureDetector(
      onTap: () async {
        selectedSection = sectionName;
        await dataLoaderFunc();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey[500] // Dark grey when selected
              : Colors.grey[200], // Light grey when unselected
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0), // No curves for rectangular shape
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Center(
          child: Text(
            currentLocalization[sectionName.toLowerCase()] ?? sectionName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Method to display the content based on the selected section
  Widget displaySelectedSectionContent({required String farmId}) {
    return Container(
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: switch (selectedSection) {
            'Milk' => displayMilkCharts(farmId),
            'Feed' => displayFeedCharts(farmId),
            'Transactions' => displayTransactionalCharts(farmId),
            _ => Container(),
          },
        ),
      ),
    );
  }

  Widget displayFeedCharts(String farmId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 8,
          children: dateRangesList.map((dRange) {
            return ChoiceChip(
              label: Text(currentLocalization[dRange.toLowerCase()] ?? dRange),
              selected: selectedDateRange == dRange,
              selectedColor: Color.fromRGBO(13, 166, 186, 1.0),
              labelStyle: TextStyle(
                color: selectedDateRange == dRange
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) async {
                selectedDateRange = dRange;
                if (selectedDateRange == 'Custom') {
                  DateTimeRange<DateTime>? picked =
                      await AnalyticsUtils.showTheDateRangePicker(
                        context,
                        startDate,
                        endDate,
                      );
                  if (picked != null) {
                    startDate = picked.start;
                    endDate = picked.end;
                  }
                  setState(() {});
                } else {
                  DateTime now = DateTime.now();
                  endDate = now;
                  startDate = now.subtract(
                    Duration(days: dateRangeIntervalMap[selectedDateRange]!),
                  );
                  setState(() {});
                }
                await _fetchFeedChartData(startDate, endDate);
                setState(() {});
              },
            );
          }).toList(),
        ),
        SizedBox(height: 20.0),
        Center(
          child: Card(
            child: SizedBox(
              height: 350,
              width: 350,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: feedChartData.isEmpty
                    ? Center(
                        child: Text(
                          currentLocalization['no_data_for_sel_range'] ??
                              "No data available!",
                        ),
                      )
                    : Column(
                        children: [
                          Text(
                            currentLocalization["feed_cost"] ?? "Feed Cost",
                            style: TextStyle(
                              color: Color.fromRGBO(165, 42, 42, 1.0),
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 10,
                                  centerSpaceRadius: 40,
                                  sections: showingSections(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget displayTransactionalCharts(String farmId) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 8,
              children: dateRangesList.map((dRange) {
                return ChoiceChip(
                  label: Text(
                    currentLocalization[dRange.toLowerCase()] ?? dRange,
                  ),
                  selected: selectedDateRange == dRange,
                  selectedColor: Color.fromRGBO(13, 166, 186, 1.0),
                  labelStyle: TextStyle(
                    color: selectedDateRange == dRange
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) async {
                    selectedDateRange = dRange;
                    if (selectedDateRange == 'Custom') {
                      DateTimeRange<DateTime>? picked =
                          await AnalyticsUtils.showTheDateRangePicker(
                            context,
                            startDate,
                            endDate,
                          );
                      if (picked != null) {
                        startDate = picked.start;
                        endDate = picked.end;
                      }
                      setState(() {});
                    } else {
                      DateTime now = DateTime.now();
                      endDate = now;
                      startDate = now.subtract(
                        Duration(
                          days: dateRangeIntervalMap[selectedDateRange]!,
                        ),
                      );
                      setState(() {});
                    }
                    await _fetchMilkSaleChartData(startDate, endDate);
                    await _fetchTransactionChartData(startDate, endDate);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),
            Card(
              child: SizedBox(
                height: 350,
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        currentLocalization["milk_sale"] ?? "Milk Sale",
                        style: TextStyle(
                          color: Color.fromRGBO(165, 42, 42, 1.0),
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (milkSaleChartData.isEmpty) ...[
                        SizedBox(height: 100),
                        Text(
                          currentLocalization['no_data_for_sel_range'] ??
                              "No data available!",
                        ),
                      ] else ...[
                        Transform.scale(
                          scale: 0.50,
                          child: SegmentedButton(
                            multiSelectionEnabled: false,
                            segments: showMilkSalesTypes.entries.map((entry) {
                              return ButtonSegment(
                                value: entry.key,
                                label: Text(entry.value),
                              );
                            }).toList(),
                            selected: {showMilkSaleIn},
                            onSelectionChanged: (Set<String> selection) {
                              showMilkSaleIn = selection.first;
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  '${showMilkSaleIn == 'ltr' ? currentLocalization['Litres'] : currentLocalization['rupees']}',
                                ),
                              ),
                              Expanded(child: BarChart(_getBarChartData())),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: SizedBox(
                height: 350,
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        currentLocalization["transactions"] ?? "Transactions",
                        style: TextStyle(
                          color: Color.fromRGBO(165, 42, 42, 1.0),
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (transactionChartData.isEmpty) ...[
                        SizedBox(height: 100),
                        Text(
                          currentLocalization['no_data_for_sel_range'] ??
                              "No data available!",
                        ),
                      ] else ...[
                        SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            children: [
                              RotatedBox(
                                quarterTurns: 3,
                                child: Text(currentLocalization['rupees']),
                              ),
                              Expanded(
                                child: BarChart(_getTransBarChartData()),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.square_rounded,
                                      color: Colors.blue.shade700,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      currentLocalization['income'],
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.square_rounded,
                                      color: Colors.red.shade900,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      currentLocalization['expenses'],
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currentLocalization['net_profit'],
                                  style: TextStyle(
                                    color: Color.fromRGBO(165, 42, 42, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentLocalization['rupees']} ${transactionChartData.fold(0.0, (sum, row) => sum + (row['trans_amount'] as num).toDouble()).toPrecision(2)}',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayMilkCharts(String farmId) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SegmentedButton(
              multiSelectionEnabled: false,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.white;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return Color.fromRGBO(13, 166, 186, 1.0);
                  }
                  return Colors.black87;
                }),
              ),
              segments: milkReportLevels.map((level) {
                return ButtonSegment(
                  value: level,
                  label: Text(currentLocalization[level]),
                );
              }).toList(),
              selected: {selectedViewType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  selectedViewType = selection.first;
                  selectedViewId = null;
                  selectedDateRange = null;
                  milkProdChartData.clear();
                  milkProdAggregates?.clear();
                });
              },
            ),
            const SizedBox(height: 10.0),
            if (selectedViewType != 'Whole-farm') ...[
              AnalyticsUtils.buildDropdown(
                label: currentLocalization['ID'] ?? "ID",
                value: selectedViewId,
                items: selectedViewType == 'Group-wise' ? allGroups : allCattle,
                valMsg: "",
                onChanged: (value) {
                  setState(() {
                    selectedViewId = value!;
                    selectedDateRange = null;
                    milkProdChartData.clear();
                    milkProdAggregates?.clear();
                  });
                },
              ),
              const SizedBox(height: 10.0),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 8,
              children: dateRangesList.map((dRange) {
                return ChoiceChip(
                  label: Text(
                    currentLocalization[dRange.toLowerCase()] ?? dRange,
                  ),
                  selected: selectedDateRange == dRange,
                  selectedColor: Color.fromRGBO(13, 166, 186, 1.0),
                  labelStyle: TextStyle(
                    color: selectedDateRange == dRange
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) async {
                    selectedDateRange = dRange;
                    if (selectedDateRange == 'Custom') {
                      DateTimeRange<DateTime>? picked =
                          await AnalyticsUtils.showTheDateRangePicker(
                            context,
                            startDate,
                            endDate,
                          );
                      if (picked != null) {
                        startDate = picked.start;
                        endDate = picked.end;
                      }
                      setState(() {});
                    } else {
                      DateTime now = DateTime.now();
                      endDate = now;
                      startDate = now.subtract(
                        Duration(
                          days: dateRangeIntervalMap[selectedDateRange]!,
                        ),
                      );
                      setState(() {});
                    }
                    List<Future<void>> futures = [];
                    futures.add(
                      _fetchMilkProdChartData(
                        selectedViewType,
                        selectedViewId ?? '0',
                        startDate,
                        endDate,
                      ),
                    );
                    futures.add(
                      _fetchMilkAggregates(
                        selectedViewType,
                        selectedViewId ?? '0',
                        startDate,
                        endDate,
                      ),
                    );
                    await Future.wait(futures);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10.0),
            AnalyticsUtils.buildCardRow(
              colHeader1: currentLocalization['Total Milk'] ?? 'Total Milk',
              colVal1:
                  '${milkProdAggregates?['tot_milk'] ?? '0'} ${currentLocalization['Litres']}',
              colHeader2: currentLocalization['Avg Milk'] ?? 'Avg Milk',
              colVal2:
                  '${milkProdAggregates?['avg_milk'] ?? '0'} ${currentLocalization['Litres']}',
            ),
            SizedBox(height: 10.0),
            AnalyticsUtils.buildCardRow(
              colHeader1: currentLocalization['Min Milk'] ?? 'Min Milk',
              colVal1:
                  '${milkProdAggregates?['min_milk'] ?? '0'} ${currentLocalization['Litres']}',
              colHeader2: currentLocalization['Max Milk'] ?? 'Max Milk',
              colVal2:
                  '${milkProdAggregates?['max_milk'] ?? '0'} ${currentLocalization['Litres']}',
            ),
            const SizedBox(height: 10.0),
            Center(
              child: Card(
                child: SizedBox(
                  height: 300,
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: (milkProdChartData.isEmpty)
                        ? Center(
                            child: Text(
                              currentLocalization['no_data_for_sel_range'] ??
                                  "No data available!",
                            ),
                          )
                        : (milkProdChartData.length == 1)
                        ? Center(
                            child: Text(
                              currentLocalization['no_sufficient_data'] ??
                                  "Sufficient data not available!",
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                currentLocalization["milk production"] ??
                                    "Milk Production",
                                style: TextStyle(
                                  color: Color.fromRGBO(165, 42, 42, 1.0),
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        '${currentLocalization['Litres']}',
                                      ),
                                    ),
                                    Expanded(child: LineChart(_getData())),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    int index = value.toInt();
    DateTime dateValue;

    if (selectedSection == 'Transactions' && index >= 0) {
      String dateString = '';
      if (index < milkSaleChartData.length) {
        dateString = milkSaleChartData[index]['milk_sale_date'];
      } else {
        dateString = uniqueDates[index];
      }
      dateValue = DateTime.parse(dateString);
    } else {
      dateValue = DateTime.fromMicrosecondsSinceEpoch(value.toInt());
    }

    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    String textDate = dateValue.toString().split(' ')[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 10, 0),
      child: Transform.rotate(
        angle: -0.45,
        child: Text(textDate, style: style),
      ),
    );
  }

  Widget _bottomTransTitleWidgets(double value, TitleMeta meta) {
    int index = value.toInt();
    DateTime dateValue;

    String dateString = uniqueDates[index];
    dateValue = DateTime.parse(dateString);

    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    String textDate = dateValue.toString().split(' ')[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 10, 0),
      child: Transform.rotate(
        angle: -0.45,
        child: Text(textDate, style: style),
      ),
    );
  }

  LineChartData _getData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: AnalyticsUtils.getBorderData(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) => Colors.white,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((s) {
              final xDate = DateTime.fromMicrosecondsSinceEpoch(s.x.toInt());
              final String strDate = xDate.toString().split(' ')[0];
              return LineTooltipItem(
                "$strDate,${s.y}",
                const TextStyle(
                  backgroundColor: Colors.white,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [_getLineBarsData()],
      minX: chartMinX,
      maxX: chartMaxX,
      minY: chartMinY,
      maxY: chartMaxY,
      titlesData: _getFlTilesData(),
    );
  }

  FlTitlesData _getFlTilesData() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          minIncluded: false,
          maxIncluded: false,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          minIncluded: false,
          maxIncluded: false,
          //interval: 1,
          getTitlesWidget: _bottomTitleWidgets,
        ),
      ),
    );
  }

  FlTitlesData _getTransFlTilesData() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          minIncluded: false,
          maxIncluded: false,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          minIncluded: false,
          maxIncluded: false,
          //interval: 1,
          getTitlesWidget: _bottomTransTitleWidgets,
        ),
      ),
    );
  }

  LineChartBarData _getLineBarsData() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.brown,
      spots: _getFlSpotsList(),
      belowBarData: BarAreaData(
        show: true,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green, Colors.lightGreen, Colors.white60],
        ),
      ),
    );
  }

  List<FlSpot> _getFlSpotsList() {
    List<FlSpot> spotsList = milkProdChartData
        .map(
          (r) => FlSpot(
            DateTime.parse(r['milk_date']).microsecondsSinceEpoch.toDouble(),
            r['tot_milk'].toDouble(),
          ),
        )
        .toList();
    final minX = spotsList.map((e) => e.x).reduce((a, b) => a < b ? a : b);
    final maxX = spotsList.map((e) => e.x).reduce((a, b) => a > b ? a : b);

    final minY = spotsList.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spotsList.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    // Ranges
    final yRange = maxY - minY;

    // Padding (10–20% is typical)
    final yPadding = yRange == 0 ? minY * 0.2 : yRange * 0.2;

    // Final chart bounds
    chartMinX = minX - (86400000 * 2);
    chartMaxX = maxX + (86400000 * 2);

    chartMinY = minY - yPadding;
    chartMaxY = maxY + yPadding;

    return spotsList;
  }

  BarChartData _getBarChartData() {
    return BarChartData(
      barGroups: _getBarGroups(),
      gridData: FlGridData(show: false),
      borderData: AnalyticsUtils.getBorderData(),
      titlesData: _getFlTilesData(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (BarChartGroupData group) => Colors.white,
          getTooltipItem: (grp, grpIndex, rod, rodIndex) {
            String xValue = milkSaleChartData[grpIndex]['milk_sale_date'];
            return BarTooltipItem(
              "$xValue, ${rod.toY}",
              const TextStyle(
                backgroundColor: Colors.white,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> barChartDataList = milkSaleChartData
        .asMap()
        .entries
        .map((r) {
          int index = r.key;
          var data = r.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              if (showMilkSaleIn == 'ltr') ...[
                BarChartRodData(
                  toY: data['tot_milk'].toDouble(),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue, Colors.lightBlue],
                  ),
                ),
              ] else ...[
                BarChartRodData(
                  toY: data['tot_amount'].toDouble(),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                ),
              ],
            ],
          );
        })
        .toList();

    return barChartDataList;
  }

  BarChartData _getTransBarChartData() {
    return BarChartData(
      barGroups: _getTransBarGroups(),
      gridData: FlGridData(show: false),
      borderData: AnalyticsUtils.getBorderData(),
      titlesData: _getTransFlTilesData(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (BarChartGroupData group) => Colors.white,
          getTooltipItem: (grp, grpIndex, rod, rodIndex) {
            String xValue = uniqueDates[grpIndex];
            return BarTooltipItem(
              "$xValue, ${rod.toY}",
              const TextStyle(
                backgroundColor: Colors.white,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _getTransBarGroups() {
    uniqueDates = transactionChartData
        .map((r) => r['trans_date'].toString())
        .toSet()
        .toList();
    setState(() {});
    List<BarChartGroupData> barChartDataList = uniqueDates.asMap().entries.map((
      r,
    ) {
      int index = r.key;
      String uDate = r.value;
      List<double> transAmt = [];
      for (var data in transactionChartData) {
        if (data['trans_date'].toString() == uDate) {
          transAmt.add(data['trans_amount'].toDouble());
        }
      }
      return BarChartGroupData(
        x: index,
        barsSpace: 5,
        barRods: [
          for (double amt in transAmt) ...[
            if (amt >= 0) ...[
              BarChartRodData(
                toY: amt,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade700, Colors.blue],
                ),
              ),
            ] else ...[
              BarChartRodData(
                toY: -amt,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red.shade900, Colors.red],
                ),
              ),
            ],
          ],
        ],
      );
    }).toList();

    return barChartDataList;
  }

  List<PieChartSectionData> showingSections() {
    List<Color> sliceColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    final double totSum = feedChartData.fold(
      0.0,
      (sum, row) => sum + (row['feed_cost'] as num).toDouble(),
    );

    List<PieChartSectionData> sectionDataList = feedChartData
        .asMap()
        .entries
        .map((r) {
          int index = r.key;
          Map<String, dynamic> dataRow = r.value;
          final fcName = dataRow['feed_category'].replaceAll(
            RegExp(r'(?<!^)(?=[A-Z])'),
            ' ',
          );
          final double percent = totSum > 0
              ? (dataRow['feed_cost'] / totSum) * 100
              : 0.0;

          return PieChartSectionData(
            color: sliceColors[index % sliceColors.length],
            value: dataRow['feed_cost'].toDouble(),
            title: '${percent.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
            badgeWidget: Text(currentLocalization[fcName]),
            badgePositionPercentageOffset: 1.6,
          );
        })
        .toList();
    return sectionDataList;
  }
}
