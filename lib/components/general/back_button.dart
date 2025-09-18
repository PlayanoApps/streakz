import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async { 
        HapticFeedback.lightImpact(); 
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
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle
        ),
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 22,
        ),
      ),
    );
  }
}