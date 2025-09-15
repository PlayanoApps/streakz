import 'package:flutter/material.dart';
import 'package:habit_tracker/components/custom_dialog.dart';
//import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import "../_heatmap_calendar/flutter_heatmap_calendar.dart";
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/util/helper_functions.dart';
import 'package:provider/provider.dart';

class HabitAnalysisPage extends StatelessWidget {
  final Habit habit;
  
  const HabitAnalysisPage({super.key, required this.habit});
  

  @override
  Widget build(BuildContext context) {    
    // bool darkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    TextEditingController nameTextController = TextEditingController();
    TextEditingController descriptionTextController = TextEditingController();


    void clear() {
      Navigator.pop(context);   // Close box
      nameTextController.clear();
      descriptionTextController.clear();
    }

    void editHabit(Habit habit) {
      nameTextController.text = habit.name;

      void editHabit(Habit habit) async {     // Update in db
        String newHabitName = nameTextController.text;
        if (newHabitName != "") {
          Provider.of<HabitDatabase>(context, listen: false).updateHabitName(habit.id, newHabitName);  
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
        zoomTransition: false
      );
    }

    void addHabitDescription(Habit habit) {
      void addDescription(Habit habit) async {
        String newDescription = descriptionTextController.text;
                  
        if (newDescription != "") {
          await Provider.of<HabitDatabase>(context, listen: false).addDescription(habit.id, newDescription);
          clear();
        }
      }
      descriptionTextController.text = habit.description;

      showCustomDialog(
        context,
        controller: descriptionTextController,
        title: "Add description",
        hintText: "Add description",
        actions: (clear, () => addDescription(habit)),
        zoomTransition: false
      );
    }

    void deleteHabitDescription(Habit habit) async {
      await Provider.of<HabitDatabase>(context, listen: false).deleteDecription(habit.id);
    }

    return Consumer<HabitDatabase>(
      builder: (context, db, child) {
        // Find the current habit from the database to get updated data
        final currentHabit = db.habitsList.firstWhere(
          (h) => h.id == habit.id,
          orElse: () => habit, // fallback to original habit if not found
        );

        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(currentHabit.name, style: TextStyle(
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
              //IconButton(onPressed: null, icon: Icon(Icons.abc, color: Colors.transparent))
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(onPressed: () => editHabit(habit), icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.inversePrimary.withAlpha(180), size: 23,)),
              ),
            ],
          ),
        
          body: ListView(
            children: [
              SizedBox(height: 10),

              _habitDescription(context, currentHabit, addHabitDescription, deleteHabitDescription),

              _habitHeatmap(context, currentHabit),

              _streaks(context, currentHabit),
            ]
          )
        );
      }
    );
  }
}

BoxShadow _tileShadow() {
  return BoxShadow(
    color: Colors.black.withAlpha(15),
    blurRadius: 7, 
    spreadRadius: 1, 
    offset: Offset(0, 0) // (x,y)
  );
}

Widget _habitDescription(context, currentHabit, add, delete) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 19, vertical: 6),

    child: GestureDetector(
      onTap: () => add(currentHabit),

      child: Container(
        padding: EdgeInsets.only(
          top: currentHabit.description.isEmpty ? 15 : 5,
          bottom: currentHabit.description.isEmpty ? 15 : 5,
          left: currentHabit.description.isEmpty ? 14 : 19, 
          right: 5
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryFixed,
          boxShadow: [_tileShadow()],
          borderRadius: BorderRadius.circular(16),
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
                onPressed: () => delete(currentHabit), icon: Icon(Icons.cancel_outlined), iconSize: 22, color: Theme.of(context).colorScheme.primary.withAlpha(150), padding: EdgeInsets.zero
              )
          ],
        ),
      ),
    ),
  );
}

Widget _habitHeatmap(context, habit) {
  double borderRadius = 16;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 19, vertical: 6),
    child: Stack(
      children: [
        Container(
          padding: EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryFixed,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [_tileShadow()],
          ),
          child: _heatMap(context, habit),
        ),

        // Left-side gradient 
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 20,
          child: IgnorePointer( // Allows taps to pass through
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).colorScheme.secondaryFixed,
                    Theme.of(context).colorScheme.secondaryFixed.withOpacity(0)
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
          child: IgnorePointer( // Allows taps to pass through
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Theme.of(context).colorScheme.secondaryFixed,
                    Theme.of(context).colorScheme.secondaryFixed.withOpacity(0)
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

Widget _streaks(context, habit) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 19, vertical: 6),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryFixed,
        borderRadius: BorderRadius.circular(16),
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
  );
}

Widget _heatMap(context, habit) {
  final database =  Provider.of<HabitDatabase>(context);

  bool darkMode = (Theme.of(context).brightness == Brightness.dark); 

  MaterialColor accentColor = Provider.of<ThemeProvider>(context, listen: false).getAccentColor();

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
    builder: (context, snapshot) 
    {    
      if (snapshot.hasData) {
        return HeatMap(
          startDate: /* DateTime.now().subtract(Duration(days: 23)), */ snapshot.data!,
          endDate: DateTime.now().add(Duration(days: completeWeek())),  // add 30 
          colorMode: ColorMode.color,
          showColorTip: false,
          scrollable: true,
          size: 34,
          showText: true,
          defaultColor: darkMode ? Theme.of(context).colorScheme.secondary
            : Color.fromARGB(255, 210, 210, 210),
          textColor: Theme.of(context).colorScheme.tertiary,
          borderRadius: 8.5,

          highlightedColor: !darkMode ? Color.fromARGB(255, 230, 230, 230)  // def. 38
                                    : Theme.of(context).colorScheme.secondary,
          highlightedBorderColor: !darkMode ? Color.fromARGB(255, 238, 238, 238)
                                      : Color.fromARGB(255, 70, 70, 70),
          highlightedBorderWith: !darkMode ? 2 : 1.5,
          

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

