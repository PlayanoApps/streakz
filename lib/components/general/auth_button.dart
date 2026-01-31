import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const MyButton({
    required this.text,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 25),
    this.padding = const EdgeInsets.all(25),
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        enableFeedback: true, 
    
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: padding,
          child: Center(
            child: Text(text,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary
              ),
            ),
          ),
        ),
      ),
    );
  }
}