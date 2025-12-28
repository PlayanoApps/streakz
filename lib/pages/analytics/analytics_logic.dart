import 'dart:math';

import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';

class AnalyticsLogic {
  int getActiveDays(int month, int year, context) {
    List<Habit> habitsList = Provider.of<HabitDatabase>(context).habitsList;

    Set<DateTime> activeDays = {};

    for (var habit in habitsList) {
      List<DateTime> completedDays = habit.completedDays;

      for (var day in completedDays)
        if (day.month == month && day.year == year)
          activeDays.add(normalize(day));
    }

    return activeDays.length;
  }

  int daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  int getConsistency(int month, int year, context) {
    DateTime now = DateTime.now();

    int activeDays = getActiveDays(month, year, context);
    int totalDays =
        (month == now.month && year == now.year)
            ? now.day
            : daysInMonth(month, year);

    int consistency = (activeDays / totalDays * 100).round();

    return consistency;
  }

  int getMaxStreak(context) {
    List<Habit> habitsList = Provider.of<HabitDatabase>(context).habitsList;

    // Collect all completed days from all habits into a Set
    Set<DateTime> allCompletedDays = {};

    for (var habit in habitsList) {
      if (habit.isArchived) continue;
      for (var day in habit.completedDays) allCompletedDays.add(normalize(day));
    }

    // Convert to sorted list
    List<DateTime> sortedDays = allCompletedDays.toList();
    sortedDays.sort((a, b) => a.compareTo(b));

    if (sortedDays.isEmpty) return 0;

    int maxStreak = 0;
    int localStreak = 0;

    for (int i = 0; i < sortedDays.length - 1; i++) {
      DateTime currentDate = sortedDays[i];
      DateTime nextDate = sortedDays[i + 1];

      if (currentDate.add(Duration(days: 1)) == nextDate)
        localStreak++;
      else
        localStreak = 1;
      maxStreak = max(maxStreak, localStreak);
    }

    return maxStreak;
  }

  int getCurrentStreak(context) {
    List<Habit> habitsList = Provider.of<HabitDatabase>(context).habitsList;

    Set<DateTime> allCompletedDays = {};
    for (var habit in habitsList) {
      if (habit.isArchived) continue;
      for (var day in habit.completedDays) {
        allCompletedDays.add(normalize(day));
      }
    }

    if (allCompletedDays.isEmpty) return 0;

    int streak = 0;
    DateTime currentDay = normalize(DateTime.now());

    // Count backwards day by day until a day is missing
    while (allCompletedDays.contains(currentDay)) {
      streak++;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /* 
    M O N T H L Y  P R O G R E S S  B A R 
  */

  /* List<double> getMonthlySummary(
    int firstMonth,
    int lastMonth,
    int year,
    context,
  ) {
    List<double> monthlySummary = [];

    for (int i = firstMonth; i <= lastMonth; i++) {
      if (i == 12) {
        i = 1;
        year++;
      }

      double monthlyPorgress = getMonthProgressPercentage(i, year, context);
      monthlySummary.add(monthlyPorgress);
    }

    return monthlySummary;
  } */

  /* List<double> getMonthlySummary(
    int firstMonth,
    int lastMonth,
    int year, // year of last month
    context,
  ) {
    List<double> monthlySummary = [];

    int currentMonth = firstMonth;
    int currentYear = year;

    // If we're wrapping around (e.g., June to January), start from previous year
    if (firstMonth > lastMonth) {
      currentYear--;
    }

    // Loop exactly 7 times
    for (int i = 0; i < 7; i++) {
      double monthlyProgress = getMonthProgressPercentage(
        currentMonth,
        currentYear,
        context,
      );
      monthlySummary.add(monthlyProgress);

      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }

    return monthlySummary;
  } */

  List<double> getMonthlySummary(
    int firstMonth,
    int lastMonth,
    int lastYear, // The year corresponding to lastMonth
    context,
  ) {
    List<double> monthlySummary = [];

    // Determine the starting year based on whether we cross a year boundary
    int startYear = lastYear;
    if (firstMonth > lastMonth) {
      // Example: firstMonth = 10 (Oct), lastMonth = 3 (Mar)
      // We must have crossed from previous year
      startYear = lastYear - 1;
    }

    int currentMonth = firstMonth;
    int currentYear = startYear;

    // Loop exactly 7 months (or until we reach lastMonth if you ever make it variable)
    for (int i = 0; i < 7; i++) {
      double monthlyProgress = getMonthProgressPercentage(
        currentMonth,
        currentYear,
        context,
      );

      monthlySummary.add(monthlyProgress);

      // Advance to the next month
      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }

    return monthlySummary;
  }

  double getMonthProgressPercentage(int month, int year, context) {
    List<Habit> habitsList = Provider.of<HabitDatabase>(context).habitsList;

    // Filter out archived habits
    List<Habit> activeHabits =
        habitsList.where((habit) => !habit.isArchived).toList();

    if (activeHabits.isEmpty) return 0.0;

    int totalPossibleCompletions = 0;
    int actualCompletions = 0;

    for (var habit in activeHabits) {
      // Count how many days this habit could be completed (days in month)
      totalPossibleCompletions += daysInMonth(month, year);

      // Count how many days this habit was actually completed in this month
      for (var day in habit.completedDays) {
        if (day.month == month && day.year == year) actualCompletions++;
      }
    }

    if (totalPossibleCompletions == 0) return 0.0;

    double percentage = (actualCompletions / totalPossibleCompletions) * 100;

    return (percentage * 10).round() / 10; // Rounds to 1 decimal place
  }

  double getPercentageIncrease(int month, int lastMonth, year, context) {
    double newValue = getMonthProgressPercentage(month, year, context);
    double oldValue = getMonthProgressPercentage(lastMonth, year, context);

    double difference = newValue - oldValue;
    return (difference * 10).round() / 10;
  }

  /* 
    H A B I T  P R O G R E S S  B A R S
  */

  double getHabitProgressPercentage(Habit habit, int month, int year) {
    List<DateTime> completedDays = habit.completedDays;
    DateTime now = DateTime.now();

    int daysCompletedThisMonth = 0;

    for (var day in completedDays)
      if (day.month == month && day.year == year) daysCompletedThisMonth++;

    int totalDays =
        (month == now.month && year == now.year)
            ? now.day
            : daysInMonth(month, year);

    double percentage = (daysCompletedThisMonth / totalDays) * 100;
    return (percentage * 10).round() / 10; // Rounds to 1 decimal place
  }
}
