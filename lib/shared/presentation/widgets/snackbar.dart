import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context,
    {required String message, bool isError = false}) {
  final snackBar = SnackBar(
    backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    duration: Duration(seconds: 3),
    content: Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
        ),
        SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
      ],
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
