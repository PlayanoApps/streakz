import 'package:flutter/material.dart';

class MyGradient extends StatelessWidget {
  final double height;

  final bool top;

  const MyGradient({super.key, required this.height, this.top = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: top ? null : 0,
      top: top ? 0 : null,

      height: height,
      child: AbsorbPointer(
        // Block touches (vs IgnorePointer)
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(1),
                Theme.of(context).colorScheme.surface.withOpacity(0),
              ],
              stops: [0.25, 1],
            ),
          ),
        ),
      ),
    );
  }
}
