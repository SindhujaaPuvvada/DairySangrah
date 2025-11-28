import 'package:flutter/material.dart';

class ReportsUtils {
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
        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
      ),
      dropdownColor: const Color.fromRGBO(240, 255, 255, 1),
      items:
          itemsList.map((item) {
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

  static Widget buildTextFieldWithCalender({
    required String label,
    required DateTime? reqDate,
    String? valMsg,
  }) {
    return IgnorePointer(
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text:
              reqDate != null
                  ? '${reqDate.year}-${reqDate.month}-${reqDate.day}'
                  : '',
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return valMsg;
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          suffixIcon: Icon(Icons.calendar_today),
          border: InputBorder.none,
        ),
      ),
    );
  }

  static ElevatedButton buildElevatedButton(
    String label, {
    required void Function() onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
