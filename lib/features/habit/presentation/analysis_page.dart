import 'package:flutter/material.dart';
import 'package:habit_tracker/components/common/app_bar.dart';
import 'package:habit_tracker/features/habit/logic/analysis_functions.dart';
import 'package:habit_tracker/features/habit/presentation/analysis_heatmap.dart';
import 'package:habit_tracker/features/habit/presentation/analysis_tile.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';

class HabitAnalysisPage extends StatelessWidget {
  final Habit habit;

  const HabitAnalysisPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    void clear() {
      Navigator.pop(context); // Close box
      nameController.clear();
      descriptionController.clear();
    }

    /* void editHabit(Habit habit) {
      nameTextController.text = habit.name;

      void editHabit(Habit habit) async {
        // Update in db
        String newHabitName = nameTextController.text;
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
        controller: nameTextController,
        title: "Edit name",
        hintText: "New habit name",
        actions: (clear, () => editHabit(habit)),
        zoomTransition: false,
      );
    } */

    /* void addHabitDescription(Habit habit) {
      descriptionController.text = habit.description;

      showCustomDialog(
        context,
        controller: descriptionController,
        title: "Add description",
        hintText: "Add description",
        actions: (
          clear,
          () async {
            String description = descriptionController.text;
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

    void deleteHabitDescription(Habit habit) async {
      await Provider.of<HabitDatabase>(
        context,
        listen: false,
      ).deleteDecription(habit.id);
    } */

    /* void archiveHabit(Habit habit) async {
      showCustomDialog(
        context,
        title: "Archive habit?",
        text:
            "Archived habits can be found in settings. Your progress remains.",
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
              title: "Successfuly archived ${habit.name}",
              text: "To unarchive, go to settings",
              labels: ("", "Ok"),
              actions: (null, () => Navigator.pop(context)),
            );
          },
        ),
      );
    } */

    return Consumer<HabitDatabase>(
      builder: (context, db, child) {
        // Find the current habit from the database to get updated data
        final currentHabit = db.habitsList.firstWhere(
          (h) => h.id == habit.id,
          orElse: () => habit, // fallback to original habit if not found
        );

        return Scaffold(
          /* appBar: AppBar(
            title: Center(
              child: Text(
                currentHabit.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 20,
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () async {
                await Future.delayed(Duration(milliseconds: 100));
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            actions: [
              // Placeholder Icon so that title centered
              //IconButton(onPressed: null, icon: Icon(Icons.abc, color: Colors.transparent))
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed:
                      () =>
                          editHabitName(context, habit, nameController, clear),
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withAlpha(180),
                    size: 23,
                  ),
                ),
              ),
            ],
          ), */
          body: Column(
            children: [
              MyAppBar(
                title: currentHabit.name,
                bottomPadding: 5,
                endAction:
                    () => editHabitName(context, habit, nameController, clear),
                endIcon: Icons.edit,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: BouncingScrollPhysics(),
                  children: [
                    SizedBox(height: 10),

                    _habitDescription(
                      context,
                      currentHabit,
                      descriptionController,
                      clear,
                      /* addHabitDescription,
                    deleteHabitDescription, */
                    ),

                    AnalysisHeatmap(habit: currentHabit),

                    _streaks(context, currentHabit),

                    _archiveHabit(context, habit, clear),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _habitDescription(
  context,
  currentHabit,
  controller,
  clear,
  /* add, delete */
) {
  return AnalysisTile(
    key: ValueKey(currentHabit.description.isEmpty),
    onTap: () => addHabitDescription(context, currentHabit, controller, clear),
    //() => add(currentHabit),
    padding: EdgeInsets.only(
      top: currentHabit.description.isEmpty ? 15 : 5,
      bottom: currentHabit.description.isEmpty ? 15 : 5,
      left: currentHabit.description.isEmpty ? 14 : 19,
      right: 5,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            currentHabit.description.isEmpty
                ? "+ Add description"
                : currentHabit.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        SizedBox(width: 8),
        currentHabit.description.isEmpty
            ? Container()
            : IconButton(
              onPressed: () => deleteHabitDescription(context, currentHabit),
              //() => delete(currentHabit),
              icon: Icon(Icons.cancel_outlined),
              iconSize: 22,
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
              padding: EdgeInsets.zero,
            ),
      ],
    ),
  );
}

Widget _archiveHabit(context, habit, clear /* onTap */) {
  return AnalysisTile(
    onTap: () => archiveHabit(context, habit, clear),
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Archive",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 10),
        Icon(
          Icons.archive,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          size: 22,
        ),
      ],
    ),
  );
}

Widget _streaks(context, habit) {
  return AnalysisTile(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
    child: Column(
      children: [
        Text(
          "Streaks",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontWeight: FontWeight.w600,
            fontSize: 19,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Current: ${currentStreak(habit.completedDays)} days",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Highest: ${highestStreak(habit.completedDays)} days",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 17,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}
