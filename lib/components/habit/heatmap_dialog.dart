import 'package:flutter/material.dart';
import 'package:habit_tracker/components/general/custom_dialog.dart';
import 'package:habit_tracker/components/habit/snackbar.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';

void showEditHeatmapDialog(date, context) {
  DateTime now = DateTime.now();

  if (date.day > now.day && date.month == now.month && date.year == now.year) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(mySnackBar(context, "Cannot edit future days", 1000));
    return;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    //barrierColor: Colors.black.withOpacity(darkMode ? 0.7 : 0.55),
    pageBuilder:
        (context, x, y) => Consumer<HabitDatabase>(
          builder:
              // Alert Dialog
              (context, value, child) => AlertDialog(
                // Title
                title: Text(
                  "${numberToMonth(date.month)} ${date.day}th",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                // List
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var habit in value.habitsList.where(
                      (habit) => !habit.isArchived,
                    ))
                      // One item
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap:
                            () => toggleDateInHabit(
                              context,
                              !habitCompleted(habit.completedDays, date),
                              habit,
                              date,
                            ),
                        // Checkbox + habit name
                        child: Row(
                          children: [
                            Checkbox(
                              value: habitCompleted(habit.completedDays, date),
                              onChanged:
                                  (value) => toggleDateInHabit(
                                    context,
                                    value,
                                    habit,
                                    date,
                                  ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  habit.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        ),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: zoomInTransition(),
  );
}

void toggleDateInHabit(context, value, habit, date) {
  if (value != null) {
    Provider.of<HabitDatabase>(
      context,
      listen: false,
    ).updateHabitCompletion(habit.id, value, date);
  }
}
