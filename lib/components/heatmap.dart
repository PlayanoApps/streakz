import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/theme_provider.dart';
import 'package:habit_tracker/util/helper_functions.dart';
import 'package:provider/provider.dart';
import "../_heatmap_calendar/flutter_heatmap_calendar.dart";

class MyHeatmap extends StatelessWidget {
  final DateTime startDate;

  const MyHeatmap({
    super.key,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {

    //bool darkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    bool darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: HeatMapCalendar(
        datasets: prepDataset(context),
      
        colorMode: ColorMode.color,
        defaultColor: Theme.of(context).colorScheme.secondary,

        highlightedColor: !darkMode ? const Color.fromARGB(255, 230, 230, 230)  // def. 38
                                    : Theme.of(context).colorScheme.secondary,
        highlightedBorderColor: !darkMode ? Color.fromARGB(255, 238, 238, 238)
                                    : Color.fromARGB(255, 70, 70, 70),
        highlightedBorderWith: !darkMode? 2 : 1.5,

        textColor: Theme.of(context).colorScheme.tertiary,
        showColorTip: false,
        flexible: true,
        monthFontSize: 16,
        fontSize: 16,
        weekTextColor: Theme.of(context).colorScheme.primary,
        onClick: (date) => showEditHeatmapDialog(date, context),

        // borderRadius: 5,
      
        colorsets: prepColorsets(context),
      ),
    );
  }
}

void showEditHeatmapDialog(date, context) {
  showDialog(
    context: context, 
    builder: (context) => Consumer<HabitDatabase> (
      builder: (context, value, child) => AlertDialog(
        title: Text("Edit ${date.day}.${date.month}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var habit in value.habitsList) 
              InkWell(
                onTap: () => toggleDateInHabit(context, !habitCompleted(habit.completedDays, date), habit, date),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Checkbox(
                      value: habitCompleted(habit.completedDays, date), 
                      onChanged: (value) => toggleDateInHabit(context, value, habit, date)
                    ),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(habit.name, overflow: TextOverflow.ellipsis),
                    ))
                  ],
                ),
              )
              /* ListTile(
                title: Text(habit.name),
                leading: Checkbox(
                  value: habitCompleted(habit.completedDays, date), 
                  onChanged: (value) => toggleDateInHabit(context, value, habit, date)
                ),
              ), */
          ],
        )
      )
    )
  );
}

void toggleDateInHabit(context, value, habit, date) {
  if (value != null) {
    Provider.of<HabitDatabase>(context, listen: false)
      .updateHabitCompletion(habit.id, value, date);
  }
}

// Prepare heat map colorsets
Map<int, Color> prepColorsets(BuildContext context) {
  int habitsAmount = Provider.of<HabitDatabase>(context).habitsList.length;

  if (habitsAmount <= 0)
    return {};

  int alpha = 130 - (habitsAmount * 10);   // min alpha for first habit (more habits --> less)
  // if min alpha becomes negative, set to 0
  if (alpha < 0) alpha = 0;

  int maxAlpha = 230;                     // Don't exceed this value
  Color accentColor = Provider.of<ThemeProvider>(context).getAccentColor();

  if (habitsAmount == 1)
    return { 1: accentColor.withAlpha(maxAlpha) };

  Map<int, Color> colorset = {};
  int incrementStep = habitsAmount > 1 ? ((maxAlpha - alpha) / (habitsAmount - 1)).toInt() : 0;

  for (int i = 1; i <= habitsAmount; i++) {
    // Start first habit with initial alpha. Then, increment
    alpha = (i == 1) ? alpha : min(alpha + incrementStep, maxAlpha);
    colorset[i] = accentColor.withAlpha(alpha); 
  }
  return colorset;
}

// Prepare heat map dataset
Map<DateTime, int> prepDataset(BuildContext context) {
  List<Habit> habits = Provider.of<HabitDatabase>(context).habitsList;

  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      // Normalize date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // If the day already exists in the dataset, increment
      if (dataset.containsKey(normalizedDate))
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      else
        dataset[normalizedDate] = 1; 
    }
  }
  return dataset;
}