import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class HabitListEntry extends StatelessWidget {
  final String habitName;
  final double percentage;

  const HabitListEntry({
    super.key,
    required this.habitName,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          _habitNameText(context, darkMode),

          SizedBox(width: 12),

          Expanded(child: _progressSlider(context, darkMode)),

          SizedBox(width: 15),

          _completionPercentage(context, darkMode),
        ],
      ),
    );
  }

  Widget _progressSlider(context, darkMode) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    Color accentColor =
        darkMode
            ? themeProvider.getAccentColor().shade500
            : themeProvider.getAccentColor().shade400;

    return LayoutBuilder(
      builder: (context, constraints) {
        double progress = percentage / 100; // 0-1

        double width = constraints.maxWidth * progress;

        double minOpacity = 0.5;
        double restOpacity = (1 - minOpacity);
        double opacity = (minOpacity) + restOpacity * progress;

        print("Opacity: $opacity, percentage: $percentage");

        accentColor = accentColor.withOpacity(min(opacity, 1));

        return Stack(
          children: [
            Container(
              height: 13,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(darkMode ? 0.6 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: 13,
              width: width, // proportional width
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _habitNameText(context, darkMode) {
    return SizedBox(
      width: 55,
      child: Text(
        habitName,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: GoogleFonts.roboto(
          color: Theme.of(
            context,
          ).colorScheme.onPrimary.withOpacity(darkMode ? 0.8 : 1),
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _completionPercentage(context, darkMode) {
    return Text(
      "${percentage.round()}%",
      style: TextStyle(
        color: Theme.of(
          context,
        ).colorScheme.onPrimary.withOpacity(darkMode ? 0.5 : 0.2),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
