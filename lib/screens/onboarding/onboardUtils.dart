import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardUtils {
  static Future<bool> checkFirstLaunch(String uid) async {
    bool showOnboarding = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstLaunch = prefs.getBool('first_launch_$uid');

    if (firstLaunch == false) {
      // Not the first launch
      showOnboarding = false;
    } else {
      // This is the first launch or the flag was not
      if (firstLaunch == null) {
        DatabaseServicesForUser userDB = DatabaseServicesForUser(uid);
        bool isFirstLaunch = await userDB.getIsFirstLaunch(uid);
        showOnboarding = (isFirstLaunch == true) ? true : false;
      } else {
        showOnboarding = true;
      }
    }
    return showOnboarding;
  }

  static Widget buildTextField(TextEditingController controller, String label,
      [bool? allowNumOnly, String? validatorMsg]) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: allowNumOnly == true
          ? [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.black)),
        filled: true,
        fillColor: Colors.white,
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
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.black)),
        filled: true,
        fillColor: Colors.white,
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

  static ElevatedButton buildElevatedButton(String label,
      {required void Function() onPressed}) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          minimumSize: const Size(120, 50),
          backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
          foregroundColor: Colors.white,
          elevation: 10,
          // adjust elevation value as desired
          side: const BorderSide(color: Colors.grey, width: 2),
        ),
        child: Text(label,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15)));
  }
}
