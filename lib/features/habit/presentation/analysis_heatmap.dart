import 'package:flutter/material.dart';
import 'package:habit_tracker/_heatmap_calendar/src/data/heatmap_color_mode.dart';
import 'package:habit_tracker/_heatmap_calendar/src/heatmap.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/features/habit/presentation/analysis_tile.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class AnalysisHeatmap extends StatelessWidget {
  final Habit habit;

  const AnalysisHeatmap({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    double borderRadius = 16;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 18),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryFixed,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [tileShadow(context)],
            ),
            child: _heatMap(context, habit),
          ),

          // Left-side gradient
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 20,
            child: IgnorePointer(
              // Allows taps to pass through
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context).colorScheme.secondaryFixed,
                      Theme.of(
                        context,
                      ).colorScheme.secondaryFixed.withOpacity(0),
                    ],
                    stops: [0.1, 1],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ),

          // Right-side gradient
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 20,
            child: IgnorePointer(
              // Allows taps to pass through
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Theme.of(context).colorScheme.secondaryFixed,
                      Theme.of(
                        context,
                      ).colorScheme.secondaryFixed.withOpacity(0),
                    ],
                    stops: [0.1, 1],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, int> prepDataset(Habit habit) {
    Map<DateTime, int> dataset = {};

    for (var date in habit.completedDays) {
      dataset[date] = 1;
    }
    return dataset;
  }

  Widget _heatMap(context, habit) {
    final database = Provider.of<HabitDatabase>(context);

    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    MaterialColor accentColor =
        Provider.of<ThemeProvider>(context, listen: false).getAccentColor();

    int completeWeek() {
      // weekday: Monday = 1 ... Sunday = 7
      int weekday = DateTime.now().weekday;

      // Map so Sunday=1, Monday=2, ..., Saturday=7
      int sundayBasedWeekday = (weekday % 7) + 1;

      int remainingDays = 7 - sundayBasedWeekday; // days until Saturday
      return remainingDays;
    }

    return FutureBuilder(
      future: database.getFirstLaunchDate(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HeatMap(
            startDate: /* DateTime.now().subtract(Duration(days: 23)), */
                snapshot.data!,
            endDate: DateTime.now().add(
              Duration(days: completeWeek()),
            ), // add 30
            colorMode: ColorMode.color,
            showColorTip: false,
            scrollable: true,
            size: 34,
            showText: true,
            defaultColor:
                darkMode
                    ? Theme.of(context).colorScheme.secondary
                    : Color.fromARGB(255, 210, 210, 210),
            textColor: Theme.of(context).colorScheme.tertiary,
            borderRadius: 8.5,

            highlightedColor:
                !darkMode
                    ? Color.fromARGB(255, 230, 230, 230) // def. 38
                    : Theme.of(context).colorScheme.secondary,
            highlightedBorderColor:
                !darkMode
                    ? Color.fromARGB(255, 238, 238, 238)
                    : Color.fromARGB(255, 70, 70, 70),
            highlightedBorderWith: !darkMode ? 2 : 1.5,

            datasets: prepDataset(habit),

            colorsets: {
              // Lighter color for light mode
              1: darkMode ? accentColor : accentColor.shade300,
            },
          );
        } else
          return Container();
      },
    );
  }
}
