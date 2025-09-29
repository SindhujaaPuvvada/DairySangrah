import 'package:flutter/material.dart';

class MilkUtils {
  static Widget buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required String valMsg,
    required ValueChanged<String?> onChanged,
  }) {
    var itemsList = items.entries.toList();
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        filled: true,
        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
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
}
