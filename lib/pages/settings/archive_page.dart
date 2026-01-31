import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/components/general/app_bar.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/pages/habit/presentation/analysis_page.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: Center(
          child: Text(
            "A R C H I V E D",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () async {
            await Future.delayed(Duration(milliseconds: 120));
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        actions: [
          // Placeholder Icon so that title centered
          IconButton(
            onPressed: null,
            icon: Icon(Icons.abc, color: Colors.transparent),
          ),
        ],
      ), */
      body: Column(
        children: [
          MyAppBar(title: "Archived habits", bottomPadding: 20),
          Expanded(
            child: Consumer<HabitDatabase>(
              builder: (context, habitDatabase, child) {
                final archivedHabits =
                    habitDatabase.habitsList
                        .where((habit) => habit.isArchived)
                        .toList();

                if (archivedHabits.isEmpty) {
                  return Center(
                    child: Text(
                      "No archived habits",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: archivedHabits.length,
                  itemBuilder: (context, index) {
                    return _tile(context, archivedHabits[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Habit habit) {
    void navigateToHabitAnalysis(context) async {
      HapticFeedback.mediumImpact();
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => HabitAnalysisPage(habit: habit),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: InkWell(
        onLongPress: () => navigateToHabitAnalysis(context),
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),

        child: Ink(
          //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: ListTile(
            title: Text(
              habit.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 17,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                Provider.of<HabitDatabase>(
                  context,
                  listen: false,
                ).archiveHabit(habit.id, false);
              },
              icon: Icon(
                Icons.unarchive,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
