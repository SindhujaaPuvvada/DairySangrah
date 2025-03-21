import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/feed.dart';
import '../../services/database/feeddatabase.dart';

class feedUtils{
  static Widget buildTextField(TextEditingController controller, String label,) {
    return TextField(
      controller: controller,
      //onTap: () => controller.text = '',
      //onTapOutside: (val) => controller.text = (controller.text.isEmpty) ? '0.0' : controller.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      style: const TextStyle(fontSize: 14.0),
    );
  }

  static Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 12.0),
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
        backgroundColor: const Color.fromRGBO(4, 142, 161, 1.0),
        padding: const EdgeInsets.symmetric(
            horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),

    );
  }

  static List<double> calRateOrPrice(double price, double rate, double quantity) {
    if (rate != 0.0) {
      price = rate * quantity;
    }
    else if (price != 0.0 && quantity != 0.0) {
      rate = price / quantity;
    }
    return   [price,rate];;
  }


  static saveFeedDetails(Feed fd) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseServicesForFeed fdDB = DatabaseServicesForFeed(uid);
    if(fd.ratePerKg != 0.0) {
      fdDB.infoToServerFeed(fd);
    }
  }
}