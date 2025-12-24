import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/pages/analytics/analytics_logic.dart';
import 'package:habit_tracker/pages/analytics/habit%20progress/habit_entry.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

class HabitProgress extends StatelessWidget {
  final int month;
  final int year;

  HabitProgress({super.key, required this.month, required this.year});

  final AnalyticsLogic logic = AnalyticsLogic();

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 5, left: 18, right: 18),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow(context, darkMode),

          SizedBox(height: 6),

          _subtext(context, darkMode),

          SizedBox(height: 0),

          _habitList(context),
        ],
      ),
    );
  }

  Widget _habitList(context) {
    List<Habit> habitsList =
        Provider.of<HabitDatabase>(
          context,
        ).habitsList.where((habit) => !habit.isArchived).toList();

    return ListView.builder(
      shrinkWrap: true, // important
      physics: NeverScrollableScrollPhysics(),
      itemCount: habitsList.length,

      itemBuilder: (context, index) {
        Habit habit = habitsList[index];

        return HabitListEntry(
          habitName: habit.name,
          percentage: logic.getHabitProgressPercentage(habit, month, year),
        );
      },
    );
  }

  Widget _titleRow(context, darkMode) {
    return Row(
      children: [
        Icon(
          Icons.emoji_events,
          color: Theme.of(
            context,
          ).colorScheme.onPrimary.withOpacity(darkMode ? 0.7 : 0.35),
          size: 22,
        ),
        Text(
          "  Habits",
          style: GoogleFonts.roboto(
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withOpacity(darkMode ? 0.8 : 1),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _subtext(context, darkMode) {
    return Text(
      "Completion by habit (this month)",
      style: TextStyle(
        color: Theme.of(
          context,
        ).colorScheme.primary.withOpacity(darkMode ? 1 : 0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
