/* Given a completedDays list of a habit, check if this habit is completed today */
// For checking habit on and off (checkbox value)
import 'dart:math';

bool habitCompleted(List<DateTime> completedDays, DateTime dateToCheck) {
  DateTime today = DateTime.now();

  bool habitCompletedToday = completedDays.any((date) => 
    date.year == dateToCheck.year &&
    date.month == dateToCheck.month &&
    date.day == dateToCheck.day
  );

  return habitCompletedToday;
}

/* For analysis: return the current streak of a habit */
int currentStreak(List<DateTime> completedDays) {
  DateTime today = DateTime.now();
  int streak = 0;

  for (int i = 0; true; i++) {
    DateTime dayToCheck = today.subtract(Duration(days: i));

    dayToCheck = normalize(dayToCheck);

    if (completedDays.contains(dayToCheck))
      streak++;
    else
      return streak;
  }
}

int highestStreak(List<DateTime> completedDays) {
  completedDays.sort((a, b) => a.compareTo(b));

  int maxStreak = 1; 
  int localStreak = 1;

  for (int i = 0; i < completedDays.length-1; i++) {
    DateTime currentDate = normalize(completedDays[i]);
    DateTime nextDate = normalize(completedDays[i+1]);

    if (currentDate.add(Duration(days: 1)) == nextDate)
      localStreak++;
    else if (currentDate != nextDate) {
      localStreak = 1;
    }
    maxStreak = max(maxStreak, localStreak);
  }
  return maxStreak;
}

DateTime normalize(DateTime date) => DateTime(date.year, date.month, date.day);