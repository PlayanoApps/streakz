// ignore_for_file: dead_code, unused_element

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/analysis_page.dart';
import 'package:habit_tracker/theme_provider.dart';
import 'package:provider/provider.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final void Function(bool?)? checkboxChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  
  const HabitTile({
    super.key, 
    required this.habit,
    required this.isCompleted,
    required this.checkboxChanged,
    required this.editHabit,
    required this.deleteHabit
  });

  /* @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(), 
          children: [
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            )
          ]
        ),
        child: GestureDetector(
          onTap: () => checkboxChanged!(!isCompleted),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Theme.of(context)
                  .colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(text, style: TextStyle(
                fontSize: 18, 
                color: isCompleted ? Colors.white : Colors.black)
              ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted, 
                onChanged: checkboxChanged
              ),
            ),
          ),
        ),
      ),
    );
  } */

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark); //Provider.of<ThemeProvider>(context).isDarkMode;
    MaterialColor accentColor = Provider.of<ThemeProvider>(context).getAccentColor();
    
    // cross completed habits instead of highlighting them
    bool crossCompletedHabit = Provider.of<ThemeProvider>(context).crossCompletedHabits;

    void navigateToHabitAnalysis({delay = 150}) async {
      HapticFeedback.mediumImpact(); 
      await Future.delayed(Duration(milliseconds: delay));
      Navigator.push(context, CupertinoPageRoute(
        builder: (context) => HabitAnalysisPage(habit: habit)
      ));
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(), 
          children: [
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: darkMode ? Colors.grey.shade800 : Colors.grey.shade600,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: darkMode ?Color.fromARGB(222, 198, 40, 40) : Color.fromARGB(233, 239, 83, 80),
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(10),
            )
          ]
        ),
        startActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: (BuildContext b) => navigateToHabitAnalysis(),
            backgroundColor: darkMode ?Color.fromARGB(190, 33, 149, 243) : Color.fromARGB(190, 33, 149, 243),
            icon: Icons.analytics,
            borderRadius: BorderRadius.circular(10),
          ),
        ]),

        // Habit Tile
        child: Material(
          child: InkWell(
            // Checkbox provides value to callback function automatically
            onTap: () => checkboxChanged!(!isCompleted),
            onLongPress: null,//() =>  navigateToHabitAnalysis(delay: 50),
            borderRadius: BorderRadius.circular(10),
            splashColor: crossCompletedHabit ? Colors.grey.withAlpha(0) : Colors.grey.withAlpha(30), // 30
            highlightColor: isCompleted ? (crossCompletedHabit ? null : accentColor[600]) : Colors.grey.withAlpha(50),
          
            // Container
            child: Ink(
              decoration: BoxDecoration(
                color: isCompleted ? (crossCompletedHabit ? Theme.of(context).colorScheme.surface : (darkMode ? accentColor[800] : accentColor[400])) : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 26, right: 24, top: 16, bottom: 16),

                child: _newTile(context, darkMode, navigateToHabitAnalysis, crossCompletedHabit)
              ) 
            ),
          ),
        ),
      ),
    );
  }

  Widget _newTile(context, darkMode, navigateToHabitAnalysis, bool crossCompleted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Leading
        Expanded(
          child: Row(
            children: [
              Checkbox(
                activeColor: crossCompleted ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                checkColor: crossCompleted ? Theme.of(context).colorScheme.primary : Colors.white,
                value: isCompleted, 
                onChanged: checkboxChanged
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(habit.name, //overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? (crossCompleted ? Theme.of(context).colorScheme.primary : Colors.white) : Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16.5,
                    letterSpacing: 0.5,
                    height: 1.4,
                    decoration: (isCompleted && crossCompleted) ? TextDecoration.lineThrough : null
                  )
                ),
              ),
            ]
          ),
        ),
        // Trailing
        !isCompleted ? IconButton(
          onPressed: navigateToHabitAnalysis,                   
          icon: Icon(Icons.arrow_forward, size: 24, 
            color: Theme.of(context).colorScheme.primary
          ) // else placeholder icon
        ) : IconButton(onPressed: null, icon: Icon(Icons.abc, color: Colors.transparent))
      ],
    );
  }

  Widget _oldTile(context, darkMode, navigateToHabitAnalysis) {
    return ListTile(
      title: Text(habit.name, style: TextStyle(
          fontSize: 16.5, 
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.white : Theme.of(context).colorScheme.onPrimary
        ),
      ),
      leading: Checkbox(
        activeColor: Colors.transparent,
        checkColor: Colors.white,
        value: isCompleted, 
        onChanged: checkboxChanged,
      ),

      trailing: !isCompleted ? IconButton(
        onPressed: navigateToHabitAnalysis,                   
        icon: Icon(Icons.arrow_forward, size: 24, 
          color: Theme.of(context).colorScheme.primary
        )
      ) : Padding(
        padding: EdgeInsets.only(bottom: 0),
        //child: Lottie.asset("assets/streak2.json"),
      ),
    );
  }
}