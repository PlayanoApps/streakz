// ignore_for_file: dead_code, unused_element

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/habit/presentation/analysis_page.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final void Function(bool?)? checkboxChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;

  final double borderRadius = 16;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.checkboxChanged,
    required this.editHabit,
    required this.deleteHabit,
  });

  /* @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(), 
          children: [
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            )
          ]
        ),
        child: GestureDetector(
          onTap: () => checkboxChanged!(!isCompleted),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Theme.of(context)
                  .colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(text, style: TextStyle(
                fontSize: 18, 
                color: isCompleted ? Colors.white : Colors.black)
              ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted, 
                onChanged: checkboxChanged
              ),
            ),
          ),
        ),
      ),
    );
  } */

  void navigateToHabitAnalysis(context, {delay = 150}) async {
    HapticFeedback.mediumImpact();
    await Future.delayed(Duration(milliseconds: delay));
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => HabitAnalysisPage(habit: habit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    MaterialColor accentColor =
        Provider.of<ThemeProvider>(context).getAccentColor();

    // Cross completed habits instead of highlighting them
    bool crossCompletedHabit =
        Provider.of<ThemeProvider>(context).crossCompletedHabits;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25), // vertical 5
      child: Slidable(
        endActionPane: _endActionPane(darkMode),

        // Habit Tile
        child: Material(
          child: InkWell(
            // Checkbox provides value to callback function automatically
            onTap: () => checkboxChanged!(!isCompleted),
            borderRadius: BorderRadius.circular(borderRadius), // 10, 18
            splashColor:
                crossCompletedHabit
                    ? Colors.grey.withAlpha(0)
                    : Colors.grey.withAlpha(30), // 30
            splashFactory:
                crossCompletedHabit
                    ? (isCompleted ? null : NoSplash.splashFactory)
                    : null,
            highlightColor:
                isCompleted
                    ? (crossCompletedHabit ? null : accentColor[600])
                    : Colors.grey.withAlpha(50),

            // Habit Container
            child: Ink(
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? (crossCompletedHabit
                            ? Theme.of(context).colorScheme.surface
                            : (darkMode ? accentColor[800] : accentColor[400]))
                        : Theme.of(context).colorScheme.secondary,
                // Border
                border: Border.all(
                  width: 0.9,
                  color:
                      isCompleted
                          ? (crossCompletedHabit
                              ? Colors.transparent
                              : (darkMode
                                  ? accentColor[700] ?? accentColor
                                  : accentColor[500] ?? accentColor))
                          : darkMode
                          ? Colors.grey.withAlpha(30)
                          : Colors.white.withAlpha(100),
                ),
                borderRadius: BorderRadius.circular(borderRadius), // 10
              ),
              // Row
              child: _tileContent(
                context,
                darkMode,
                navigateToHabitAnalysis,
                crossCompletedHabit,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tileContent(
    context,
    darkMode,
    navigateToHabitAnalysis,
    bool crossCompleted,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 26, right: 24, top: 16, bottom: 16),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading Checkbox & Text
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      activeColor:
                          crossCompleted
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                      checkColor:
                          crossCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                      value: isCompleted,
                      onChanged: checkboxChanged,
                    ),
                    SizedBox(width: 16),
                    // Text
                    Expanded(
                      child: Text(
                        habit.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isCompleted
                                  ? (crossCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white)
                                  : Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16.5,
                          letterSpacing: 0.5,
                          height: 1.4,
                          decoration:
                              (isCompleted && crossCompleted)
                                  ? TextDecoration.lineThrough
                                  : null,
                          decorationColor:
                              darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing Button
              !isCompleted
                  ? IconButton(
                    onPressed: () => navigateToHabitAnalysis(context),
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                  : IconButton(
                    onPressed: null,
                    icon: Icon(Icons.abc, color: Colors.transparent),
                  ),
            ],
          ),
          crossCompleted
              ? Positioned(
                right: 0,
                child: _showStreak(context, darkMode, crossCompleted),
              )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _showStreak(context, darkMode, crossCompleted) {
    int streak = currentStreak(habit.completedDays);

    if (streak < 2) return Container();

    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: Column(
        children: [
          SizedBox(
            width: 35,
            height: 30.2, // 30.2
            child: LottieBuilder.asset("assets/streak4.json"),
          ),
          Text(
            "$streak",
            style: GoogleFonts.roboto(
              color:
                  crossCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  ActionPane _endActionPane(bool darkMode) {
    return ActionPane(
      motion: StretchMotion(),
      children: [
        SizedBox(width: 7),

        SlidableAction(
          onPressed:
              (context) =>
                  navigateToHabitAnalysis(context, delay: 100), //editHabit,
          backgroundColor:
              darkMode ? Colors.grey.shade800 : Colors.grey.shade600,
          icon: Icons.settings,
          borderRadius: BorderRadius.circular(borderRadius),
        ),

        SizedBox(width: 7),

        SlidableAction(
          onPressed: (context) {
            deleteHabit!(context);
            HapticFeedback.mediumImpact();
          },
          backgroundColor:
              darkMode
                  ? Color.fromARGB(222, 198, 40, 40)
                  : Color.fromARGB(233, 239, 83, 80),
          icon: Icons.delete,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ],
    );
  }

  Widget _oldTile(context, darkMode, navigateToHabitAnalysis) {
    return ListTile(
      title: Text(
        habit.name,
        style: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color:
              isCompleted
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      leading: Checkbox(
        activeColor: Colors.transparent,
        checkColor: Colors.white,
        value: isCompleted,
        onChanged: checkboxChanged,
      ),

      trailing:
          !isCompleted
              ? IconButton(
                onPressed: navigateToHabitAnalysis,
                icon: Icon(
                  Icons.arrow_forward,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
              : Padding(
                padding: EdgeInsets.only(bottom: 0),
                //child: Lottie.asset("assets/streak2.json"),
              ),
    );
  }
}
