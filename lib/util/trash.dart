/* Widget _habitDescription(context, currentHabit, add, delete) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 19, vertical: 6),

    child: GestureDetector(
      onTap: () => add(currentHabit),

      child: Container(
        padding: EdgeInsets.only(
          top: currentHabit.description.isEmpty ? 15 : 5,
          bottom: currentHabit.description.isEmpty ? 15 : 5,
          left: currentHabit.description.isEmpty ? 14 : 19,
          right: 5,
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
                  onPressed: () => delete(currentHabit),
                  icon: Icon(Icons.cancel_outlined),
                  iconSize: 22,
                  color: Theme.of(context).colorScheme.primary.withAlpha(150),
                  padding: EdgeInsets.zero,
                ),
          ],
        ),
      ),
    ),
  );
} */

/* Widget _streaks(context, habit) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 19, vertical: 6),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryFixed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [tileShadow()],
      ),
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
    ),
  );
} */

/* 
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
            boxShadow: [tileShadow()],
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
                    Theme.of(context).colorScheme.secondaryFixed.withOpacity(0),
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
                    Theme.of(context).colorScheme.secondaryFixed.withOpacity(0),
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
          endDate: DateTime.now().add(Duration(days: completeWeek())), // add 30
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

Map<DateTime, int> prepDataset(Habit habit) {
  Map<DateTime, int> dataset = {};

  for (var date in habit.completedDays) {
    dataset[date] = 1;
  }
  return dataset;
}


 */
