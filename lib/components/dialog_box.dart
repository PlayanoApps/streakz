import 'package:flutter/material.dart';
import 'package:habit_tracker/theme_provider.dart';
import 'package:provider/provider.dart';

void showCustomDialog({
  /* MAP */
  required BuildContext context,                  
  TextEditingController? controller, 

  String title = "",
  String text = "",
  String hintText = "",                       
  (void Function()?, void Function()?)? actions,          // Functions for buttons
  (String?, String?) labels = ("Cancel", "Save"),           // MaterialButton labels

  bool zoomTransition = false
}) {
  bool darkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

  /* showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: title == "" ? null : Text(title),
      content: hintText == "" ? null : TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: darkMode ? Colors.grey.shade800 : Theme.of(context).colorScheme.tertiary,
              width: 1.4
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.4
            )
          )
        )
      ),
      actions: [
        _button(context: context, text: labels.$1, onPressed: actions.$1),
        _button(context: context, text: labels.$2, onPressed: actions.$2)
      ]
    )
  ); */
  showGeneralDialog(
    context: context,
    barrierDismissible: true,   // Whether the user can dismiss the dialog by tapping outside it
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,

    pageBuilder: (context, x, y) {   // like showDialog builder but with animation
      return AlertDialog(
        title: title == "" ? null : Text(title),
        content: (hintText == "")
          ? (text == "" ? null : Text(text))
          : TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: darkMode ? Colors.grey.shade800 : Theme.of(context).colorScheme.tertiary,
                    width: 1.4,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        actions: actions == null ? [] : [
          _button(context: context, text: labels.$1, onPressed: () async {
            await Future.delayed(Duration(milliseconds: 50));
            actions.$1!();
          }),
          _button(context: context, text: labels.$2, onPressed: () async {
            await Future.delayed(Duration(milliseconds: 50));
            actions.$2!();
          }),
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: zoomTransition ? zoomInTransition() : moveUpTransition()
  ).then((value) => controller?.clear());  // Dialog dismissed
  
}

Widget _button({required context, required text, required onPressed}) {
  return MaterialButton(
    onPressed: onPressed,
    enableFeedback: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20)
    ),
    child: Text(text, style: TextStyle(color: Theme.of(context).    colorScheme.inversePrimary))
  );
}

RouteTransitionsBuilder moveUpTransition() {
  return (context, animation, secondaryAnimation, child) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Starts below the screen
      end: Offset.zero,           // Ends at the center
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return SlideTransition(
      position: offsetAnimation,
      child: child,     // Widget to be animated (in this case AlertDialog)
    );
  };
}

RouteTransitionsBuilder zoomInTransition() {
  return (context, animation, secondaryAnimation, child) {
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut, 
    );
    
    return ScaleTransition(
      scale: curvedAnimation,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  };
}