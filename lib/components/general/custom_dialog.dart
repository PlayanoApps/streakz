import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void createHabitDialog(
  context, {
  Widget? topWidget,
  String title = "",
  String description = "",

  TextEditingController? controller,
  String hintText = "",

  // Buttons
  (void Function()?, void Function()?)? actions,
  (String?, String?) labels = ("Cancel", "Save"),
  Color? buttonColor,
  Color? labelColor,

  // Rename
  rename = false,
  String? currentHabitName,
}) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(darkMode ? 0.7 : 0.55),
    pageBuilder: (context, x, y) {
      return StatefulBuilder(
        builder:
            (context, setState) => AlertDialog(
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 11),
                    topWidget ?? SizedBox(),
                    /* SizedBox(
                      width: 65,
                      child: LottieBuilder.asset("assets/streak4.json"),
                    ), */
                    title.isNotEmpty
                        ? Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                    description.isNotEmpty
                        ? Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                    SizedBox(height: 27),
                    controller != null
                        ? _textField(
                          context,
                          controller,
                          hintText,
                          setState: (_) => setState(() {}),
                        )
                        : SizedBox.shrink(),
                    SizedBox(height: controller != null ? 22 : 0),
                    (actions != null)
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _cancelButton(
                              context: context,
                              onPressed: () async {
                                await Future.delayed(
                                  Duration(milliseconds: 50),
                                );
                                actions.$1!();
                              },
                              label: labels.$1,
                            ),
                            _createHabitButton(
                              context: context,
                              onPressed: () async {
                                await Future.delayed(
                                  Duration(milliseconds: 50),
                                );
                                actions.$2!();
                              },
                              controller: controller,
                              label: labels.$2,
                              rename: rename,
                              currentHabitName: currentHabitName,
                              color: buttonColor,
                              labelColor: labelColor,
                            ),
                          ],
                        )
                        : SizedBox(),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: zoomInTransition(), //: moveUpTransition(),
  ).then((value) => controller?.clear()); // Dialog dismissed
}

Widget _createHabitButton({
  required context,
  required onPressed,
  required TextEditingController? controller,
  required label,

  // For rename
  bool rename = false,
  String? currentHabitName,

  // For delete
  Color? color,
  Color? labelColor,
}) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);
  bool enabled; // Condition for when habit is enabled

  if (controller == null)
    enabled = true;
  else
    enabled =
        (rename)
            ? (controller.text != currentHabitName)
            : (controller.text.isNotEmpty);

  return MaterialButton(
    onPressed: onPressed,
    enableFeedback: true,
    elevation: 0,
    highlightElevation: 0,

    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    color: enabled ? color ?? Theme.of(context).colorScheme.onPrimary : null,
    splashColor: Colors.transparent,
    highlightColor:
        enabled
            ? darkMode
                ? Colors.grey.shade400
                : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.35)
            : Colors.transparent,

    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 13),
      child: Text(
        label,
        style: TextStyle(
          color:
              enabled
                  ? darkMode
                      ? labelColor ?? Colors.black
                      : labelColor ?? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.primary,
          fontSize: 15.5,
        ),
      ),
    ),
  );
}

Widget _cancelButton({required context, required onPressed, required label}) {
  return MaterialButton(
    onPressed: onPressed,
    enableFeedback: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 13),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 15.5,
        ),
      ),
    ),
  );
}

void showCustomDialog(
  context, {

  /* MAP */
  //required BuildContext context,
  bool zoomTransition = false,
  String title = "",
  String text = "",

  String hintText = "",
  String secondHintText = "",
  TextEditingController? controller,
  TextEditingController? secondController,

  (void Function()?, void Function()?)? actions, // Functions for buttons
  (String?, String?) labels = ("Cancel", "Save"), // MaterialButton labels

  Widget? content,
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
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(darkMode ? 0.7 : 0.5),

    pageBuilder: (context, x, y) {
      // like showDialog builder but with animation
      return AlertDialog(
        title:
            (title == "")
                ? null
                : Text(
                  title,
                  style: GoogleFonts.lato(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
        titleTextStyle: TextStyle(
          color: darkMode ? Colors.white : Colors.black,
          fontSize: 24,
        ),
        content: _content(
          context,
          text,
          hintText,
          secondHintText,
          controller,
          secondController,
          content,
        ),

        actions:
            actions == null
                ? []
                : [
                  _button(
                    context: context,
                    text: labels.$1,
                    onPressed: () async {
                      await Future.delayed(Duration(milliseconds: 50));
                      actions.$1!();
                    },
                  ),
                  _button(
                    context: context,
                    text: labels.$2,
                    onPressed: () async {
                      await Future.delayed(Duration(milliseconds: 50));
                      actions.$2!();
                    },
                  ),
                ],
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: zoomTransition ? zoomInTransition() : moveUpTransition(),
  ).then((value) => controller?.clear()); // Dialog dismissed
}

dynamic _content(
  context,
  text,
  hintText,
  secondHintText,
  controller,
  secondController,
  content,
) {
  if (hintText == "")
    return text == ""
        ? null
        : Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        );

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
      if (text != "") ...[
        Padding(
          padding: EdgeInsets.only(top: 1, bottom: 20),
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 15,
            ),
          ),
        ),
      ],

      _textField(context, controller, hintText),

      if (secondController != null) ...[
        SizedBox(height: 10),
        _textField(context, secondController, secondHintText),
      ],

      (content == null) ? Container() : content,
    ],
  );
}

Widget _textField(context, controller, hintText, {setState}) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);

  return TextField(
    controller: controller,
    onChanged: setState,
    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.3, // new
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              darkMode
                  ? Colors.grey.shade800
                  : Theme.of(context).colorScheme.tertiary,
          width: 0.7, // 1.4
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              darkMode
                  ? Colors.grey.shade900
                  : Theme.of(context).colorScheme.tertiary,
          width: 0.1,
        ),
      ),
    ),
  );
}

Widget _button({required context, required text, required onPressed}) {
  return MaterialButton(
    onPressed: onPressed,
    enableFeedback: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
    ),
  );
}

RouteTransitionsBuilder moveUpTransition() {
  return (context, animation, secondaryAnimation, child) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Starts below the screen
      end: Offset.zero, // Ends at the center
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: offsetAnimation,
      child: child, // Widget to be animated (in this case AlertDialog)
    );
  };
}

/* RouteTransitionsBuilder zoomInTransition() {
  return (context, animation, secondaryAnimation, child) {
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    return ScaleTransition(
      scale: curvedAnimation,
      child: FadeTransition(opacity: curvedAnimation, child: child),
    );
  };
} */

RouteTransitionsBuilder zoomInTransition() {
  return (context, animation, secondaryAnimation, child) {
    const begin = 0.0;
    const end = 1.0;
    const curve = Curves.easeOutCubic;

    var scaleTween = Tween(
      begin: 0.85,
      end: 1.0,
    ).chain(CurveTween(curve: curve));

    var fadeTween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: curve));

    return ScaleTransition(
      scale: animation.drive(scaleTween),
      child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
    );
  };
}
