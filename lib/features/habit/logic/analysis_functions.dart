import 'package:flutter/material.dart';
import 'package:habit_tracker/components/general/custom_dialog.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/features/home/home_page.dart';
import 'package:provider/provider.dart';

void editHabitName(
  BuildContext context,
  Habit habit,
  TextEditingController controller,
  VoidCallback clear,
) {
  controller.text = habit.name;

  void updateHabit() async {
    String newHabitName = controller.text;
    if (newHabitName != "") {
      Provider.of<HabitDatabase>(
        context,
        listen: false,
      ).updateHabitName(habit.id, newHabitName);
      await Future.delayed(Duration(milliseconds: 100));
      clear();
    }
  }

  showCustomDialog(
    context,
    controller: controller,
    title: "Edit Habit",
    hintText: "New habit name",
    actions: (clear, updateHabit),
    zoomTransition: false,
  );
}

void addHabitDescription(
  BuildContext context,
  Habit habit,
  TextEditingController controller,
  VoidCallback clear,
) {
  controller.text = habit.description;

  showCustomDialog(
    context,
    controller: controller,
    title: "Add description",
    hintText: "Add description",
    actions: (
      clear,
      () async {
        String description = controller.text;
        if (description != "") {
          await Provider.of<HabitDatabase>(
            context,
            listen: false,
          ).addDescription(habit.id, description);
          clear();
        }
      },
    ),
    zoomTransition: false,
  );
}

Future<void> deleteHabitDescription(BuildContext context, Habit habit) async {
  await Provider.of<HabitDatabase>(
    context,
    listen: false,
  ).deleteDecription(habit.id);
}

void archiveHabit(BuildContext context, Habit habit, VoidCallback clear) {
  showCustomDialog(
    context,
    title: "Archive habit?",
    text: "Archived habits can be found in settings. Your progress remains.",
    labels: ("Cancel", "Archive"),
    actions: (
      clear,
      () {
        Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).archiveHabit(habit.id, true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        showCustomDialog(
          context,
          title: "Successfully archived ${habit.name}",
          text: "To unarchive, go to settings",
          labels: ("", "Ok"),
          actions: (null, () => Navigator.pop(context)),
        );
      },
    ),
  );
}
