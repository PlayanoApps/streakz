import "package:flutter/cupertino.dart";
import "package:habit_tracker/models/app_settings.dart";
import "package:habit_tracker/models/habit.dart";
import "package:habit_tracker/util/helper_functions.dart";
import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

/* 
  ISAR STORE CUSTOM OBJECTS
  - Create classes that should be stored and generate their g files
  - Isar.open(Schema)

  - Isar now has COLLECTIONS of the classes as properties
  - there can be multiple instances of a class with auto-incremente
    id's (--> storing multiple integers)

  - isar.className's.put(newObject)
      - if newObject already has an id, UPDATE this object in db
      - if newObject uses auto-increment, a new record is added
*/


class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /* -------------  S E T U P ------------- */  

  // Initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(  
      [HabitSchema, AppSettingsSchema],  // generated .g.dart classes
      directory: dir.path
    );
  }

  // Save first launch date (for heatmap)
  static Future<void> saveFirstLaunchSettings() async {  // MAKE STATIC AND OMIT () IN LINE 13 MAIN?

    // Check if any record exists
    final existingSettings = await isar.appSettings.get(0);//await isar.appSettings.where().findFirst();

    if (existingSettings == null)   // Nothing saved yet
    {
      // Save first launch date
      final settings = AppSettings()        // Initialize start date
        ..firstLaunchDate = DateTime.now(); 
      await isar.writeTxn(() => isar.appSettings.put(settings));

      // Add default habits
      final lastDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

      final defaultHabits = [
        Habit()..name = "Welcome! :)"..order = 0
          ..completedDays = List.generate(
            lastDayOfMonth.day,   // length
            (i) => DateTime(DateTime.now().year, DateTime.now().month, i + 1),
          ),
        Habit()..name = "Swipe left to edit or delete habits"..order = 1
          ..completedDays = List.generate(
            (lastDayOfMonth.day ~/ 3),     // add every third day
            (i) => DateTime(DateTime.now().year, DateTime.now().month, (i + 1) * 3),
          ),
        Habit()..name = "Long-press to reorder habits"..order = 2
        ..completedDays = List.generate(
            (lastDayOfMonth.day ~/ 5),     // add every third day
            (i) => DateTime(DateTime.now().year, DateTime.now().month, (i + 1) * 5),
          )
      ];

      await isar.writeTxn(() async {
        for (final habit in defaultHabits) {
          await isar.habits.put(habit);
        }
      });
    }
  }

  // Get first date of app starting (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.get(0);
    return settings?.firstLaunchDate; // otherwise return null
  }

  /* --------- O P E R A T I O N S --------- */

  // List of habits
  final List<Habit> habitsList = [];

  /* Sync habits list with db and update UI */
  Future<void> updateHabitList() async {
    // when fetching habits, sort by order
    // sortByOrder() generated specifically order variable
    List<Habit> habitsFromDb = await isar.habits.where().sortByOrder().findAll();

    // Update current habits list
    habitsList.clear();
    habitsList.addAll(habitsFromDb);

    notifyListeners(); 
  }

  /* Add a new habit to db, update the list */
  Future<void> addHabit(String habitName) async { 
    // Find the current highest order value
    final lastHabit = await isar.habits.where().sortByOrderDesc().findFirst();
    final newOrder = (lastHabit?.order ?? 0) + 1;

    final newHabit = Habit()
      ..name = habitName
      ..order = newOrder;

    // Isar creates a new habit with auto-incremented id 
    // (if newHabit already had an id, isar would update it)

    await isar.writeTxn(() => isar.habits.put(newHabit));

    updateHabitList();   
  }

  /* Update completedDays of a habit when checking it on and off */
  Future<void> updateHabitCompletion(int id, bool isCompleted, DateTime passedDate) async {
    final habit = await isar.habits.get(id);    // Find habit

    if (habit != null) {
      // if habit is completed, add current date to completedDays list
      if (isCompleted && !habitCompleted(habit.completedDays, passedDate)) {
        habit.completedDays.add(DateTime(
          passedDate.year,
          passedDate.month,
          passedDate.day,
        ));
      }
      // if not completed, remove current date from list
      else {
        habit.completedDays.removeWhere((date) => 
          date.year == passedDate.year &&
          date.month == passedDate.month &&
          date.day == passedDate.day
        );
      }
      // save habit back to database
      await isar.writeTxn(() => isar.habits.put(habit));
    }
    updateHabitList();
  }

  /* Edit habit name */
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      habit.name = newName;
      await isar.writeTxn(() => isar.habits.put(habit));
    }
    updateHabitList();   // Update habits list and UI
  }

  /* Delete habit */
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    updateHabitList();
  }  

  Future<void> clearDatabase() async {
    await isar.writeTxn(() async {
      await isar.habits.clear();
      await isar.appSettings.clear();
    });
    updateHabitList();
  }

  /* For reordering habits */
  Future<void> saveNewHabitOrder() async {
    await isar.writeTxn(() async {
      for (int i = 0; i < habitsList.length; i++) {
        // Update order field of each habit to match the udpated habitsList
        habitsList[i].order = i;
        // Save each habit
        await isar.habits.put(habitsList[i]); 
      }
    });
  }
}