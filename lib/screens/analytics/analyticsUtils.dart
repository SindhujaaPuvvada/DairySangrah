import 'package:fl_chart/src/chart/base/base_chart/base_chart_data.dart';
import 'package:flutter/material.dart';

class AnalyticsUtils {
  static Widget buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required String valMsg,
    required ValueChanged<String?> onChanged,
  }) {
    var itemsList = items.entries.toList();
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        filled: true,
        fillColor: Colors.white70,
      ),
      dropdownColor: const Color.fromRGBO(240, 255, 255, 1),
      items: itemsList.map((item) {
        return DropdownMenuItem<String>(
          value: item.key,
          child: Text(item.value),
        );
      }).toList(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return valMsg;
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  static Widget buildInputBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(240, 255, 255, 0.7),
        border: Border.all(),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
      child: child,
    );
  }

  static Future<DateTimeRange<DateTime>?> showTheDateRangePicker(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate, end: endDate)
          : null,
    );
    return picked;
  }

  static FlBorderData? getBorderData() {
    return FlBorderData(
      show: true,
      border: const Border(
        left: BorderSide(),
        bottom: BorderSide(),
        top: BorderSide.none,
        right: BorderSide.none,
      ),
    );
  }

  static Widget buildCardRow({
    required colHeader1,
    required String colVal1,
    required colHeader2,
    required String colVal2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Card(
          color: Colors.white,
          elevation: 3,
          child: SizedBox(
            height: 80,
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    colHeader1,
                    style: TextStyle(
                      color: Color.fromRGBO(165, 42, 42, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(colVal1, style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ),
        Card(
          color: Colors.white,
          elevation: 3,
          child: SizedBox(
            height: 80,
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    colHeader2,
                    style: TextStyle(
                      color: Color.fromRGBO(165, 42, 42, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(colVal2, style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
