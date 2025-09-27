import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';

void showEditHeatmapDialog(date, context) {
  showDialog(
    context: context,
    builder:
        (context) => Consumer<HabitDatabase>(
          builder:
              // Alert Dialog
              (context, value, child) => AlertDialog(
                // Title
                title: Text(
                  "${numberToMonth(date.month)} ${date.day}th",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
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
