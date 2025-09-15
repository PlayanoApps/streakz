import 'package:flutter/material.dart';

SnackBar mySnackBar(context, text) {
  return SnackBar(
    content: Text(text),
    backgroundColor: Theme.of(context).colorScheme.onPrimary,
    duration: Duration(seconds: 1),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),

    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
}