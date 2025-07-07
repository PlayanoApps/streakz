import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/theme_provider.dart';
import 'package:habit_tracker/util/helper_functions.dart';
import 'package:provider/provider.dart';

class HabitAnalysisPage extends StatelessWidget {
  final Habit habit;
  
  const HabitAnalysisPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {    
    // bool darkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Analysis - ${habit.name}", style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20
          )),
        ),
        leading: IconButton(
          onPressed: () async {
            await Future.delayed(Duration(milliseconds: 100));
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.inversePrimary)
        ),
        actions: [  // Placeholder Icon so that title centered
          IconButton(onPressed: null, icon: Icon(Icons.abc, color: Colors.transparent))
        ],
      ),

      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19, vertical: 10),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 0, top: 18, bottom: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryFixed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [_tileShadow()]
              ),
              child: Column(
                children: [
                  Transform.translate(
                    offset: Offset(0, 4),
                    child: Text("Last 30 Days",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        letterSpacing: 2
                      ),
                    ),
                  ),
                  _habitHeatMap(context, habit),
                ],
              )
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryFixed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [_tileShadow()],
              ),
              child: Column(
                children: [
                  Text(
                    "Streaks",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      letterSpacing: 2
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Current: ${currentStreak(habit.completedDays)} days",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Highest: ${highestStreak(habit.completedDays)} days",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 17,
                      letterSpacing: 1
                    ),
                  ),
                ],
              )
            ),
          )
        ]
      )
    );
  }
}

BoxShadow _tileShadow() {
  return BoxShadow(
    color: Colors.black.withAlpha(15),
    blurRadius: 10, 
    spreadRadius: 3, 
    offset: Offset(0, 1) // (x,y)
  );
}

Widget _habitHeatMap(context, habit) {
  final database =  Provider.of<HabitDatabase>(context);
  bool darkMode = (Theme.of(context).brightness == Brightness.dark); //Provider.of<ThemeProvider>(context).isDarkMode;
  MaterialColor accentColor = Provider.of<ThemeProvider>(context, listen: false).getAccentColor();

  return FutureBuilder(
    future: database.getFirstLaunchDate(),
    builder: (context, snapshot) 
    {    
      if (snapshot.hasData) {
        return HeatMap(
          startDate: DateTime.now().subtract(Duration(days: 23)),//snapshot.data!,
          endDate: DateTime.now().add(Duration(days: 0)),  // add 30
          colorMode: ColorMode.color,
          showColorTip: false,
          scrollable: true,
          size: 42,
          showText: true,
          defaultColor: darkMode ? Theme.of(context).colorScheme.secondary
            : Color.fromARGB(255, 210, 210, 210),
          textColor: Theme.of(context).colorScheme.tertiary,
          borderRadius: 8,
        
          datasets: prepDataset(habit),
                      
          colorsets: {
            // Lighter color for light mode
            1: darkMode ? accentColor : accentColor.shade300
          },
        );
      } 
      else 
        return Container();
    }
  );
}

Map<DateTime, int> prepDataset(Habit habit) {
  Map<DateTime, int> dataset = {};

  for (var date in habit.completedDays) {
    dataset[date] = 1; 
  }
  return dataset;
}

