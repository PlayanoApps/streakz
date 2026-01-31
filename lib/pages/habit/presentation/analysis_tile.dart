import 'package:flutter/material.dart';

class AnalysisTile extends StatelessWidget {
  final void Function()? onTap;
  final EdgeInsets? padding;
  final Widget? child;
  final Color? backgroundColor;

  const AnalysisTile({
    super.key,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.child = const SizedBox(),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),

        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                backgroundColor ?? Theme.of(context).colorScheme.secondaryFixed,
            boxShadow: [tileShadow(context)],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

BoxShadow tileShadow(context) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);

  return BoxShadow(
    color: darkMode ? Colors.black.withAlpha(5) : Colors.black.withAlpha(15),
    blurRadius: darkMode ? 10 : 7,
    spreadRadius: 1,
    offset: Offset(0, 0), // (x,y)
  );
}
