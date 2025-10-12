import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppBar extends StatelessWidget {
  final String title;
  final double bottomPadding;
  final void Function()? endAction;
  final IconData? endIcon;

  const MyAppBar({
    super.key,
    required this.title,
    this.bottomPadding = 0,
    this.endAction,
    this.endIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 45,
        left: 20,
        right: 20,
        bottom: bottomPadding,
      ), // 60

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyIconButton(icon: Icons.arrow_back_rounded),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 21, // 22
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 20),
          MyIconButton(icon: endIcon, onTap: endAction),
        ],
      ),
    );
  }
}

class MyIconButton extends StatelessWidget {
  final IconData? icon;
  final void Function()? onTap;

  const MyIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          icon == null
              ? null
              : onTap != null
              ? () {
                //HapticFeedback.lightImpact();
                onTap!();
              }
              : () async {
                //HapticFeedback.lightImpact();
                await Future.delayed(Duration(milliseconds: 120));
                Navigator.pop(context);
              },
      borderRadius: BorderRadius.circular(100),
      splashFactory: InkSparkle.splashFactory,
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      enableFeedback: true,

      child: Ink(
        decoration: BoxDecoration(
          color:
              icon != null
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(10),
        child: Icon(
          // Icons.arrow_back_ios_new_rounded,
          // Icons.arrow_back_rounded,
          icon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 22, // 22
        ),
      ),
    );
  }
}
