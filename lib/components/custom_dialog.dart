import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/util/helper_functions.dart';
import 'package:provider/provider.dart';

void showCustomDialog(context, {
  /* MAP */
  //required BuildContext context,                  

  bool zoomTransition = false,
  String title = "",
  String text = "",

  String hintText = "",  
  String secondHintText = "",
  TextEditingController? controller, 
  TextEditingController? secondController,

  (void Function()?, void Function()?)? actions,          // Functions for buttons
  (String?, String?) labels = ("Cancel", "Save"),         // MaterialButton labels

  Widget? content
}) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);

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
        title: (title == "") ? null 
          : Text(title, style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary)),
        titleTextStyle: TextStyle(
          color: darkMode ? Colors.white : Colors.black,
          fontSize: 24,
        ),
        content: _content(context, text, hintText, secondHintText, controller, secondController, content),
    
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

dynamic _content(context, text, hintText, secondHintText, controller, secondController, content) {
  if (hintText == "")
    return text == "" ? null : Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),);
  
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
      if (text != "") ... [
        Padding(
          padding: EdgeInsets.only(top: 1, bottom: 20),
          child: Text(text, style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 15,
          )),
        ),
      ],

      _textField(context, controller, hintText),
      
      if (secondController != null) ...[
        SizedBox(height: 10),
        _textField(context, secondController, secondHintText),
      ],
      
      (content == null) ? Container() : content
    ],
  );
}

Widget _textField(context, controller, hintText) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);
  
  return TextField(
    controller: controller,
    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
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
  );
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

void showEditHeatmapDialog(date, context) {
  showDialog(
    context: context, 
    builder: (context) => Consumer<HabitDatabase> (
      builder: (context, value, child) => AlertDialog(
        title: Text("${numberToMonth(date.month)} ${date.day}th", style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary
        ),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var habit in value.habitsList) 
              InkWell(
                onTap: () => toggleDateInHabit(context, !habitCompleted(habit.completedDays, date), habit, date),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Checkbox(
                      value: habitCompleted(habit.completedDays, date), 
                      onChanged: (value) => toggleDateInHabit(context, value, habit, date)
                    ),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(habit.name, overflow: TextOverflow.ellipsis, style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary
                      ),),
                    ))
                  ],
                ),
              ),
          ],
        )
      )
    )
  );
}

void toggleDateInHabit(context, value, habit, date) {
  if (value != null) {
    Provider.of<HabitDatabase>(context, listen: false)
      .updateHabitCompletion(habit.id, value, date);
  }
}