import "package:isar/isar.dart";

/* 
  To store custom objects in Isar database, we need to create the g file with the following command: 
    >> flutter pub run build_runner build
*/
part "habit.g.dart";  

@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  late String name;

  String description = "";

  List<DateTime> completedDays = [
    // DateTime(year, month, day)
    // DateTime(year, month, day)
    // DateTime(year, month, day)
  ];

  int order = 0;
}