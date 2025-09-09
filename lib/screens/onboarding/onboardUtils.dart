
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardUtils {

  static Future<bool> checkFirstLaunch() async {
    bool showOnboarding = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstLaunch = prefs.getBool('first_launch');

    if (firstLaunch == null || firstLaunch == true) {
      // This is the first launch or the flag was not
      showOnboarding = true;
      await prefs.setBool(
          'first_launch', false); // Set to false after showing onboarding
    } else {
      // Not the first launch
      showOnboarding = false;
    }
    return true;
  }

  static Widget buildTextField(TextEditingController controller, String label,
      [bool? allowNumOnly, String? validatorMsg]) {
    return TextFormField(
      controller: controller,
      inputFormatters: allowNumOnly == true ? [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))
      ] : null,
      decoration: InputDecoration(
        labelText: label,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: const BorderSide(color: Colors.black)),
        filled: true,
        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
      ),
      validator: (value) {
        if (validatorMsg != null) {
          if (value == null || value.isEmpty) {
            return validatorMsg;
          }
          return null;
        }
        return null;
      },
    );
  }

  static Widget buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    var itemsList = items.entries.toList();
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.black)),
        filled: true,
        fillColor: Color.fromRGBO(240, 255, 255, 1),
      ),
      items: itemsList.map((item) {
        return DropdownMenuItem<String>(
          value: item.key,
          child: Text(item.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  static buildElevatedButton(String label,
      {required void Function() onPressed}) {
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
