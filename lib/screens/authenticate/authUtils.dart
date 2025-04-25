
import 'package:flutter/material.dart';

class AuthUtils {
  static AlertDialog buildAlertDialog({
    required String title,
    required String content,
    required String opt1,
    required void Function() onPressedOpt1,
    required String opt2,
    required void Function() onPressedOpt2}) {
    return AlertDialog(
      title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight
                .bold,
            color: Color.fromRGBO(
                13, 166, 186,
                0.9),)),
      content: Text(content),
      actions: [
        TextButton(
            style: TextButton
                .styleFrom(
                foregroundColor: const Color(
                    0xFF0DA6BA)),
            onPressed: onPressedOpt1,
            child: Text(opt1)),
        TextButton(
            style: TextButton
                .styleFrom(
                foregroundColor: const Color(
                    0xFF0DA6BA)),
            onPressed: onPressedOpt2,
            child: Text(opt2)),
      ],
    );
  }
}