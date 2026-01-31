import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:showcaseview/showcaseview.dart';

Widget heatmapTooltip({required key, required child}) {
  return MyShowcase(
    globalKey: key, 
    description: "",
    title: "",
    child: child
  );
}

// Trigger slidable during onboarding
void triggerSlidableForShowcase(SlidableController controller) async {
  await Future.delayed(Duration(milliseconds: 500));
  controller.openEndActionPane();
}

class MyShowcase extends StatelessWidget {
  final GlobalKey globalKey;
  final String? title;
  final String description;
  final Widget child;

  const MyShowcase({
    super.key, 
    required this.globalKey,
    this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: globalKey, 
      title: title,
      description: description, 

      overlayOpacity: 0.25,
      blurValue: 3,
      showArrow: false,

      tooltipBackgroundColor: Theme.of(context).colorScheme.secondary,
      tooltipBorderRadius: BorderRadius.circular(22),
      targetBorderRadius: BorderRadius.circular(15),
      tooltipPadding: EdgeInsets.all(18),

      textColor: Theme.of(context).colorScheme.onPrimary,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Theme.of(context).colorScheme.onPrimary),
      titlePadding: EdgeInsets.only(bottom: 5),
      descTextStyle: TextStyle(fontSize: 14.5, color: Theme.of(context).colorScheme.inversePrimary),
      descriptionTextAlign: TextAlign.center,

      scaleAnimationCurve: Curves.ease,   // bounce
      scaleAnimationDuration: Duration(milliseconds: 300),

      child: child
    );
  }
}