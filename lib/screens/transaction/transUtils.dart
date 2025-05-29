

import 'package:flutter/material.dart';

class TransUtils{

  static Widget buildTextField(TextEditingController controller, String label,[bool? isReadOnly]) {
    return TextField(
        controller: controller,
        readOnly: isReadOnly ?? false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color.fromRGBO(240, 255, 255, 1),
        )
    );
  }

  static Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14.0),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Color.fromRGBO(240, 255, 255, 1),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  static buildElevatedButton(String label, {required void Function() onPressed}) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
          minimumSize: const Size(120, 50),
          backgroundColor:
          const Color.fromRGBO(13, 166, 186, 1.0),
          foregroundColor: Colors.white,
          elevation: 10,
          // adjust elevation value as desired
          side: const BorderSide(color: Colors.grey, width: 2),
        ),
        child: Text(
            label,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15
            )
        )
    );
  }


}