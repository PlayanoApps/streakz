import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async { 
        await Future.delayed(Duration(milliseconds: 100));
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(100),
      splashFactory: InkSparkle.splashFactory,
      splashColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade700,
      enableFeedback: true,
    
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle
        ),
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.inversePrimary,
          size: 22,
        ),
      ),
    );
  }
}