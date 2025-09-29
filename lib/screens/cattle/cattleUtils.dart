import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/cattle.dart';
import '../../models/cattlegroups.dart';
import '../../services/database/cattledatabase.dart';
import '../../services/database/cattlegroupsdatabase.dart';

class CattleUtils {
  static Widget buildTextField(TextEditingController controller, String label,
      [bool? allowNumOnly, String? validatorMsg]) {
    return TextFormField(
      controller: controller,
      inputFormatters: allowNumOnly == true
          ? [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
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
        border: OutlineInputBorder(),
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

  static Widget buildReadonlyTextField(
      {required String initialValue, required String label}) {
    return TextFormField(
      readOnly: true,
      enabled: false,
      style: TextStyle(fontSize: 15, color: Colors.black),
      initialValue: initialValue,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          )),
    );
  }

  static Widget buildReadonlyTextFieldWithController(
      {required TextEditingController controller, required String label}) {
    return TextFormField(
      readOnly: true,
      enabled: false,
      style: TextStyle(fontSize: 15, color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          )),
    );
  }

  static Future<String> addCattleGroupToDB(
      String cattleType, String? breed, String status) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseServicesForCattleGroups cgrpDB =
        DatabaseServicesForCattleGroups(uid);

    int lastGrpId = int.parse(await cgrpDB.getLastUsedGrpId(uid));
    bool grpAlrdyExists =
        await cgrpDB.grpCriteriaExists(cattleType, breed, status);

    if (!grpAlrdyExists) {
      final cattleGrp = CattleGroup(
        grpId: (lastGrpId + 1).toString().padLeft(3, '0'),
        type: cattleType,
        breed: breed,
        state: status,
      );
      await cgrpDB.infoToServerSingleCattleGrp(cattleGrp);
      return 'Success';
    } else {
      return 'Already Exists';
    }
  }

  static Future<void> addNewCattleToDB(
      String cattleType, String? breed, String status,
      [String? sex]) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseServicesForCattle cattleDB = DatabaseServicesForCattle(uid);

    int lastRFId = int.parse(await cattleDB.getLastUsedRFId(uid));

    final cattle = Cattle(
      rfid: (lastRFId + 1).toString().padLeft(4, '0'),
      type: cattleType,
      breed: breed,
      state: status,
      sex: sex,
    );
    await cattleDB.infoToServerSingleCattle(cattle);
  }
}
