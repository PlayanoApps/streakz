import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habit_tracker/components/common/my_blur.dart';

/* SnackBar mySnackBar(context, text) {
  return SnackBar(
    content: Text(text),
    backgroundColor: Theme.of(context).colorScheme.onPrimary,
    duration: Duration(seconds: 1),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),

    /* action: SnackBarAction(
      label: 'Dismiss',
      textColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ), */
  );
}

 */

SnackBar mySnackBar(BuildContext context, String text) {
  return SnackBar(
    backgroundColor: Colors.transparent, // Important: no solid color
    elevation: 0,
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(13),
    padding: EdgeInsets.zero, // We’ll handle padding inside the blur box

    content: MyBlur(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
